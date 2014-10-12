	
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

/*--------------------------------------- Assumptions ---------------------------------------
* product value belongs to parameterID 115
* Domain_Corner_Flow belongs to parameterID 115
* Feature_ActualValue belongs to index number [1] in the import string.
* Feature_MinValue belongs to index number [4] in the import string.
* Feature_Step belongs to index number [11] in the import string.
* Prediction TestName has the following pattern "DFF_PBIC_%"
*/

---------------------------------------- Declare Variables ----------------------------------- 
DECLARE  @SQL VARCHAR(MAX)=NULL   
		,@ImportQuery VARCHAR(MAX)=NULL
		,@ProductValue VARCHAR(MAX)=NULL
		,@FailPoint INT=NULL
		,@ErrorMessage VARCHAR(MAX)=NULL
		,@ProductValue_Parameter INT=115
		,@DomainCornerFlow_Parameter INT=116


------------------------------------------ Create Tables ---------------------------------

IF OBJECT_ID('tempdb..#Predictions') IS NOT NULL 
	DROP TABLE #Predictions

IF OBJECT_ID('tempdb..#Actuals') IS NOT NULL 
	DROP TABLE #Actuals

CREATE TABLE #Predictions(UnitID VARCHAR(MAX),Test_Program VARCHAR(MAX),ModelID INT ,[Model_Prediction] FLOAT)

CREATE TABLE #Actuals (UnitID VARCHAR(MAX),Test_Program VARCHAR(MAX),Test_Name VARCHAR(MAX),WW INT,Test_Date DATETIME, Feature_ActualValue FLOAT, Feature_MinValue FLOAT, Feature_Step INT, Feature_GB FLOAT
					  ,Model_MaxValue FLOAT ,Model_NumOfSteps INT, SolutionID INT ,ModelID INT,FeatureID INT)

----------------------------------- Create Clustered Index -------------------------------
SET @FailPoint=0

---- #ATM_GM_Indicators_RawData
IF NOT EXISTS(SELECT
				  TableName = t.name, 
				  ClusteredIndexName = i.name
			  FROM tempdb.sys.tables t
			  INNER JOIN tempdb.sys.indexes i 
			  ON t.object_id=OBJECT_ID('tempdb..#ATM_GM_Indicators_RawData')
			  AND t.object_id = i.object_id
			  AND i.name IS NOT null
			)
CREATE CLUSTERED INDEX  ATM_GM_Indicators_RawData_I1 ON #ATM_GM_Indicators_RawData (UnitID,Test_Program,Test_Name, WW, Test_Date);

------ #ATM_GM_ModelingParameters
IF NOT EXISTS(SELECT
				  TableName = t.name, 
				  ClusteredIndexName = i.name
			  FROM tempdb.sys.tables t
			  INNER JOIN tempdb.sys.indexes i 
			  ON t.object_id=OBJECT_ID('tempdb..#ATM_GM_ModelingParameters')
			  AND t.object_id = i.object_id
			  AND i.name IS NOT null
			)
CREATE CLUSTERED INDEX  ATM_GM_ModelingParameters_I1 ON #ATM_GM_ModelingParameters (SolutionID,ModelGroupID,ModelID,FeatureID,ParameterID)

--------------------------------------- select product value ---------------------------------
SET @FailPoint=1

SELECT @ProductValue= CONVERT(VARCHAR(10),Value)
FROM #ATM_GM_ModelingParameters
WHERE SolutionID=@SolutionID
AND ModelGroupID=@ModelGroupID
AND ParameterID=@ProductValue_Parameter 

------------------------------------- Populate #predictions table ---------------------------------
SET @FailPoint=2

INSERT INTO #Predictions
SELECT UnitID,Test_Program,ModelID,[Model_Prediction]
FROM(
	SELECT   *
			,[Model_Prediction]=CASE WHEN Place=1 THEN SUBSTRING(Value, CHARINDEX(':',Value)+1,LEN(Value)) 
											ELSE Value END

			,[flow]=place 
			,[DomainCornerFlow]=CASE WHEN LEN(SUBSTRING(Test_Name,13,100))=5 THEN LEFT(SUBSTRING(Test_Name,13,100),3)
																			 ELSE LEFT(SUBSTRING(Test_Name,13,100),2)
																			 END
								+'_'+RIGHT(SUBSTRING(Test_Name,13,100),2)+'_'+CONVERT(varchar(max),place)
	FROM(
		SELECT 
			 UnitID
			,Test_Program
			,Test_Name
			,Test_Result
			,PrePlace=place
			,PreValue=value
		FROM #ATM_GM_Indicators_RawData 
		CROSS APPLY UDF_GetStringTableFromList_New(Test_Result,'^',@ProductValue) -- @ProductValue --> select only the relevant product (e.g. place = ULT place) 
		where 1=1
		AND Test_Name LIKE 'DFF_PBIC%' --Include Only Predictions
	) Res1
	CROSS APPLY UDF_GetStringTableFromList_New(PreValue,'|',NULL) 
	WHERE 1=1
	AND Value!='' -- dont take in account units which dont have predictions 
)Res2
INNER JOIN  #ATM_GM_ModelingParameters MP -- Filter predictions only on the relevant modelID 
ON MP.SolutionID=@SolutionID
AND MP.ModelGroupID=@ModelGroupID
AND MP.ModelID=@ModelID
AND MP.ParameterID=@DomainCornerFlow_Parameter
AND MP.Value=Res2.DomainCornerFlow 
ORDER BY MP.ModelID,Res2.UnitID

IF @DebugMode=1
	SELECT * FROM #Predictions

------------------------------------- Populate #Actuals table ---------------------------------
SET @FailPoint=3

INSERT INTO #Actuals
SELECT 
	   Res2.UnitID 
	  ,Res2.Test_Program
	  ,Res2.Test_Name
	  ,Res2.WW
	  ,Res2.Test_Date
	  ,Res2.Feature_ActualValue
	  ,Res2.Feature_MinValue
	  ,Res2.Feature_Step
	  ,Res2.Feature_GB
	  ,Model_MaxValue=MAX(Res2.Feature_ActualValue) OVER (PARTITION BY Res2.Test_Program,MF.ModelID,Res2.UnitID)
	  ,Model_NumOfSteps=SUM(Res2.Feature_Step) OVER (PARTITION BY Res2.Test_Program,MF.ModelID,Res2.UnitID)
	  ,MF.SolutionID
	  ,MF.ModelID 
	  ,F.FeatureID
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
SET @FailPoint=4

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
SET @FailPoint=5

IF NOT EXISTS (SELECT TOP 1 * FROM #ATM_GM_Indicators_PreparedData)
	DELETE FROM #ATM_GM_ModelIndicators WHERE ModelID=@ModelID

------------------------------------- END proc ---------------------------------
END TRY
  	
BEGIN CATCH  	
	SET @ErrorMessage = 'Fail Point: ' + CONVERT(VARCHAR(3), @FailPoint) +' '+ ERROR_MESSAGE()
	SELECT @ErrorMessage
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_VM2F_BDU_Class_Indicators_DataPreparation', @EngineName = 'VM2F', 
							@ModuleName = 'Indicators', @LogEventMessage = @ErrorMessage, @LogEventType = 'E' 
	RAISERROR (N'USP_VM2F_BDU_Class_Indicators_DataPreparation::FailPoint- %d ERR-%s', 16,1, @FailPoint, @ErrorMessage)
END CATCH 
GO

