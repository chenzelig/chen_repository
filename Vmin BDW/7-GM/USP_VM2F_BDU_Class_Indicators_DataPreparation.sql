	
USE MFG_Solutions
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_Indicators_DataPreparation]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_Indicators_DataPreparation]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID INT, @ModelGroupID INT,@ModelID INT ,@DebugMode INT=0

AS 

BEGIN TRY 

---------------------------------------- Declare Variables ----------------------------------- 
DECLARE  @SQL VARCHAR(MAX)=NULL   
		,@ImportQuery VARCHAR(MAX)=NULL
		,@ParameterValue VARCHAR(MAX)=NULL
		,@FailPoint VARCHAR(MAX)=NULL

------------------------------------------ Create Tables ---------------------------------

IF OBJECT_ID('tempdb..#Predictions') IS NOT NULL 
	DROP TABLE #Predictions

IF OBJECT_ID('tempdb..#Actuals') IS NOT NULL 
	DROP TABLE #Actuals

--------------------------------------- select product value ---------------------------------
SET @FailPoint='1'

SELECT @ParameterValue= CONVERT(VARCHAR(10),Value)
FROM #ATM_GM_ModelingParameters
WHERE ModelGroupID=@ModelGroupID
AND ParameterID=115

------------------------------------- Populate #predictions table ---------------------------------
SET @FailPoint='2'

SELECT UnitID,Test_Program,ModelID,[Model_Prediction]
INTO #Predictions
FROM(
	SELECT   *
			,[Model_Prediction]=CASE WHEN Place=1 THEN SUBSTRING(Value, CHARINDEX(':',Value)+1,LEN(Value)) 
											ELSE Value END

			,[flow]=place 
			,[DomainCornerFlow]=SUBSTRING(Test_Name,13,2)+'_'+SUBSTRING(Test_Name,15,10)+'_'+CONVERT(varchar(max),place)
	FROM(
		SELECT 
			 UnitID
			,Test_Program
			,Test_Name
			,Test_Result
			,PrePlace=place
			,PreValue=value
		FROM #ATM_GM_Indicators_RawData 
		CROSS APPLY UDF_GetStringTableFromList_New(Test_Result,'^',@ParameterValue) -- @ParameterValue --> select only the relevant product (e.g. place = ULT place) 
		where 1=1
		AND Test_Name LIKE 'DFF_PBIC%' --Include Only Predictions
	) Res1
	CROSS APPLY UDF_GetStringTableFromList_New(PreValue,'|',NULL) 
	WHERE 1=1
	--AND Value!='' -- we do want to take in account units which dont have predictions (that' why it appears as a comma)
)Res2
INNER JOIN  [GM_F_ModelingParameters] MP 
ON MP.SolutionID=@SolutionID
AND MP.ModelGroupID=@ModelGroupID
AND MP.ModelID=@ModelID -- Create Indicators only on the relevant ModelID
AND MP.ParameterID=116 --Predictions - Domain_Corner_Flow
AND MP.Value=Res2.DomainCornerFlow -- compare modelID's Names (e.g. CLR_P1_1)
ORDER BY MP.ModelID,Res2.UnitID

IF @DebugMode=1
	SELECT * FROM #Predictions

------------------------------------- Populate #Actuals table ---------------------------------
SET @FailPoint='3'

SELECT Res2.*
	  ,Model_MaxValue=MAX(Feature_ActualValue) OVER (PARTITION BY Res2.Test_Program,MF.ModelID,Res2.UnitID)
	  ,Model_NumOfSteps=SUM(Feature_Step) OVER (PARTITION BY Res2.Test_Program,MF.ModelID,Res2.UnitID)
	  ,MF.SolutionID
	  ,MF.ModelID 
	  ,F.FeatureID
INTO #Actuals
FROM(
	SELECT
		 UnitID 
		,Test_Program
		,Test_Name
		,WW
		,Test_Date
		,Feature_ActualValue=[1]
		,Feature_MinValue=[4]
		,Feature_Step=[11]
		,Feature_GB=CAST([2]-[1] AS decimal(18,2))
	FROM(
			SELECT 
			  UnitID
			 ,Test_Program
			 ,Test_Name
			 ,WW
			 ,Test_Date
			 ,Test_Result
			 ,place
			 ,Value=CASE WHEN ISNUMERIC(Value)=1 THEN CONVERT(FLOAT,Value) ELSE NULL END
			FROM #ATM_GM_Indicators_RawData 
			CROSS APPLY UDF_GetStringTableFromList_New(Test_Result,'|',null)
			WHERE 1=1
			AND Test_Name NOT LIKE 'DFF_%' --Include Only Vmin Tests
			AND Place IN (1,2,4,11) 
	)Res1
	PIVOT
	(MAX(value) FOR place IN ([1],[2],[4],[11]))
	AS PVT
	WHERE [1] IS NOT NULL -- igonre null values 
)Res2
INNER JOIN GM_D_Features(nolock) F
ON F.Test_Name=Res2.Test_Name
AND F.SolutionID=@SolutionID
INNER JOIN GM_F_ModelingFeatures(nolock) MF
ON F.FeatureID=MF.FeatureID
AND F.SolutionID=MF.SolutionID
AND MF.ModelID=@ModelID -- Create Indicators only on the relevant ModelID
ORDER by ModelID,UnitID,F.FeatureID

IF @DebugMode=1
	SELECT * FROM #Actuals

------------------------------------- Populate #PreparedData table ---------------------------------
SET @FailPoint='3'

INSERT INTO #ATM_GM_Indicators_PreparedData 
SELECT A.UnitID
	  ,A.Test_Program
	  ,A.WW
	  ,A.Test_Date
	  ,A.ModelID
	  ,A.FeatureID
	  ,A.Feature_ActualValue
	  ,A.Feature_MinValue
	  ,A.Feature_Step
	  ,A.Feature_GB
	  ,A.Model_MaxValue
	  ,A.Model_NumOfSteps
	  ,[Model_PotentialOS]=CASE WHEN P.Model_Prediction=A.Model_MaxValue AND A.Model_NumOfSteps=0 THEN 1 ELSE 0 END
	  ,[Model_CertainOS]=CASE WHEN P.Model_Prediction>A.Model_MaxValue THEN 1 ELSE 0 END
	  ,P.Model_Prediction
FROM #Actuals A
LEFT JOIN #Predictions P  
ON A.unitID=P.UnitID
AND A.ModelID=P.ModelID
AND A.Test_Program=P.Test_Program
ORDER BY A.UnitID,A.Test_Program,A.ModelID,A.FeatureID

IF @DebugMode=1
	SELECT * FROM #ATM_GM_Indicators_PreparedData

--------------- Prevent trying to create indicators when there is no data ----------------------

IF NOT EXISTS (SELECT TOP 1 * FROM #ATM_GM_Indicators_PreparedData)
	DELETE FROM #ATM_GM_ModelIndicators WHERE ModelID=@ModelID

------------------------------------- END proc ---------------------------------
END TRY
BEGIN CATCH  	
	PRINT ('Fail Point: '+ @FailPoint + ' - ' + ERROR_MESSAGE())
END CATCH 
GO

