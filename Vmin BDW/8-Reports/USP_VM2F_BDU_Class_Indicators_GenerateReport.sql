	
USE MFG_Solutions
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_Indicators_GenerateReport]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_Indicators_GenerateReport]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE USP_VM2F_BDU_Class_Indicators_GenerateReport @SolutionID INT 

AS 

BEGIN TRY 

SET NOCOUNT ON; -- In Order to use temp tables in PoPAI

-------------------------
DECLARE  @SQL VARCHAR(MAX)=NULL
		,@FailPoint INT=NULL
		,@ErrorMessage VARCHAR(MAX)=NULL

		,@IndicatorsList1 VARCHAR(MAX)=NULL
		,@IndicatorsList2 VARCHAR(MAX)=NULL
		,@IndicatorsList3 VARCHAR(MAX)=NULL

		,@DomainCornerBin_ParameterID INT=117
		,@VminBaseline_ParameterID INT=121
		,@NumOfStepsBaseline_ParameterID INT=122


----------------------------------------------------------------------------------------------------------------------
--										Create Tables
----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Models') IS NOT NULL 
	DROP TABLE #Models

IF OBJECT_ID('tempdb..#RawData') IS NOT NULL 
	DROP TABLE #RawData


CREATE TABLE #Models (DieStructure VARCHAR(MAX), BOMGROUP VARCHAR(MAX),SolutionID INT, ModelGroupID INT, ModelID INT ,Domain VARCHAR(MAX), Corner VARCHAR(MAX), Bin INT, [Vmin_Baseline] Float, [NumOfSteps_Baseline] FLOAT)

CREATE TABLE #RawData (DieStructure VARCHAR(MAX), BOMGROUP VARCHAR(MAX),[Indicator] VARCHAR(MAX),[Test_Program] VARCHAR(MAX), Domain VARCHAR(MAX), Corner VARCHAR(MAX), Bin INT, [WW] INT ,[Test_Date] DATE ,[Value] FLOAT)


----------------------------------------------------------------------------------------------------------------------
--										Populate #Models
----------------------------------------------------------------------------------------------------------------------
-- holds model data (BOMGROUP,domain,corner,flow,Vmin baseline, Number Of Step Baseline)
SET @FailPoint=1

INSERT INTO  #Models
SELECT
	 DieStructure 
	,BOMGROUP=M.[Version]
	,Res1.[SolutionID]
	,Res1.[ModelGroupID]
	,Res1.[ModelID]
	,Res1.[Domain]
	,Res1.[Corner]
	,Res1.[Bin]
	,CAST(MP1.Value AS FLOAT)
	,CAST(MP2.Value AS FLOAT)
FROM(
	SELECT	 [SolutionID]
			,[ModelGroupID]
			,[ModelID]
			,[Domain]=[1]
			,[Corner]=[2]
			,[Bin]=[3]
	FROM [GM_F_ModelingParameters] 
	CROSS APPLY dbo.UDF_GetStringTableFromList_New(Value,'_',NULL)
	PIVOT 
	(MAX(UDF_GetStringTableFromList_New.Value) FOR place IN ([1],[2],[3])) PVT
	WHERE ParameterID=@DomainCornerBin_ParameterID
	AND SolutionID=@SolutionID
)Res1
INNER JOIN GM_D_Models M
ON M.SolutionID=Res1.SolutionID
AND M.ModelID=Res1.ModelID
INNER JOIN GM_F_ModelingParameters MP1
ON Res1.SolutionID=MP1.SolutionID
AND Res1.ModelGroupID=MP1.ModelGroupID
AND Res1.ModelID=MP1.ModelID
AND MP1.ParameterID=@VminBaseline_ParameterID
INNER JOIN GM_F_ModelingParameters MP2
ON Res1.SolutionID=MP2.SolutionID
AND Res1.ModelGroupID=MP2.ModelGroupID
AND Res1.ModelID=MP2.ModelID
AND MP2.ParameterID=@NumOfStepsBaseline_ParameterID

----------------------------------------------------------------------------------------------------------------------
--										Populate #RawData
----------------------------------------------------------------------------------------------------------------------
-- Holds the Indicators raw data
--    1.Pivoted Indicators
--	  2.Filtered according to users input
SET @FailPoint=2

INSERT INTO #RawData
SELECT 
	   [DieStructure]
	  ,[BOMGROUP] 
	  ,[Indicator]
	  ,[Test_Program]
	  ,[Domain]
	  ,[Corner]
	  ,[Bin]
--	  ,[ModelID]
	  ,[WW]
	  ,[Test_Date]
	  ,[Value]
FROM (
	SELECT
		   DieStructure 
		  ,BOMGROUP
		  ,Domain
		  ,Corner
		  ,Bin  
	      ,Indicator
		  ,IndicatorID
		  ,[Key]
		  ,Test_Program=[1]
		  ,ModelID=[2]
		  ,WW=[3]
		  ,Test_Date=CAST([4] AS date)
		  ,Value
	FROM(
		SELECT
			   [M].[DieStructure]
		      ,[BOMGROUP]
			  ,[Domain]
			  ,[Corner]
			  ,[Bin]
			  ,[Indicator]=I.IndicatorName
			  ,I.IndicatorID
			  ,[Key]=ComponentValues
			  ,[Value]=MIV.Value
			  ,place
			  ,[ParsedKey]=UDF_GetStringTableFromList_New.Value
		FROM [dbo].[GM_R_IndicatorLevelInstances] ILI
		INNER JOIN (SELECT *,Max_TimeStamp= MAX(TimeStamp) OVER (partition by ModelID,IndicatorLevelID,IndicatorLevelInstanceID,IndicatorID)
					FROM [GM_R_ModelIndicatorValues]) MIV
		ON MIV.Max_TimeStamp=MIV.Timestamp -- select only the last calculation per instance
		AND ILI.IndicatorLevelID=MIV.IndicatorLevelID
		AND ILI.ModelID=MIV.ModelID
		AND ILI.IndicatorLevelInstanceID= MIV.IndicatorLevelInstanceID
		INNER JOIN GM_D_Indicators I
		ON I.IndicatorID=MIV.IndicatorID
		INNER JOIN #Models M
		ON M.ModelID=ILI.ModelID
		CROSS APPLY dbo.UDF_GetStringTableFromList_New(ComponentValues,',',NULL)
	)Res1
	PIVOT
	(MAX(Res1.ParsedKey) FOR place IN ([1],[2],[3],[4])) as PVT
)Res2
ORDER BY IndicatorID


---------------------------------------- Output -------------------------------------

SET @FailPoint=3

SELECT  Res1.*
   --  ,[vcntXbaselineMstepswpcnt]=[Vmin_CNT]*[NumOfSteps_Baseline]-[Steps_WP_CNT]
	   ,M.[Vmin_Baseline] 
	   ,M.[NumOfSteps_Baseline] 
	   
	FROM(
		SELECT  
				DieStructure 
			   ,BOMGROUP
			   ,Domain
			   ,Corner
			   ,Bin
			   ,Test_Program
			   ,Step=SUBSTRING(Test_Program,10,1)			   
			   ,WW
			   ,Test_Date
			   ,[Certain_OS_CNT]=[Certain_OS_CNT]
,[Potential_OS_CNT]=[Potential_OS_CNT]
,[Prediction_Calculated_CNT]=[Prediction_Calculated_CNT]
,[Prediction_Justified_Unused_CNT]=[Prediction_Justified_Unused_CNT]
,[Prediction_Unexplained_Unused_CNT]=[Prediction_Unexplained_Unused_CNT]
,[Prediction_Unjustified_Unused_CNT]=[Prediction_Unjustified_Unused_CNT]
,[Prediction_Used_CNT]=[Prediction_Used_CNT]
,[Steps_WP_CNT]=[Steps_WP_CNT]
,[TestsResults_CNT]=[TestsResults_CNT]
,[Total_OS_CNT]=[Total_OS_CNT]
,[Vmin_CNT]=[Vmin_CNT]
,[Vmin_SUM]=[Vmin_SUM]
,[Vmin_SUMsq]=[Vmin_SUMsq]
		FROM #RawData 
		PIVOT
		(MAX(Value) FOR Indicator IN ( [Certain_OS_CNT],[Potential_OS_CNT],[Prediction_Calculated_CNT],[Prediction_Justified_Unused_CNT],[Prediction_Unexplained_Unused_CNT],[Prediction_Unjustified_Unused_CNT],[Prediction_Used_CNT],[Steps_WP_CNT],[TestsResults_CNT],[Total_OS_CNT],[Vmin_CNT],[Vmin_SUM],[Vmin_SUMsq])) PVT
	)Res1
INNER JOIN #Models M
ON M.Domain=Res1.Domain
AND M.Corner=Res1.Corner
AND M.Bin=Res1.Bin
ORDER BY M.DieStructure, M.BOMGROUP,M.ModelID

END TRY

BEGIN CATCH  	
	SET @ErrorMessage = 'Fail Point: ' + CONVERT(VARCHAR(3), @FailPoint) +' '+ ERROR_MESSAGE()
	SELECT @ErrorMessage
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_VM2F_BDU_Class_Indicators_GenerateReport', @EngineName = 'VM2F', 
							@ModuleName = 'Indicators', @LogEventMessage = @ErrorMessage, @LogEventType = 'E' 
	RAISERROR (N'USP_VM2F_BDU_Class_Indicators_GenerateReport::FailPoint- %d ERR-%s', 16,1, @FailPoint, @ErrorMessage)
END CATCH 

GO
