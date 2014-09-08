	
--USE MFG_Solutions
--GO

--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_Indicators_DataPreparation]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_Indicators_DataPreparation]

--GO

--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


--CREATE PROCEDURE USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID INT, @ModelGroupID INT,@ModelID INT ,@DebugMode INT=0

--AS 

--BEGIN TRY 

DECLARE @SolutionID INT=20
		,@WW VARCHAR(MAX)='All'
		,@Step VARCHAR(MAX)='All'
		,@DebugMode BIT=1

-------------------------
DECLARE  @SQL VARCHAR(MAX)=NULL
		,@P VARCHAR(MAX)=NULL
		,@FailPoint VARCHAR(MAX)=NULL

		,@IndicatorsList1 VARCHAR(MAX)=NULL
		,@IndicatorsList2 VARCHAR(MAX)=NULL
		,@IndicatorsList3 VARCHAR(MAX)=NULL
		,@IndicatorsList4 VARCHAR(MAX)=NULL

		,@DomainCornerBin_ParameterID VARCHAR(MAX)='117'
		,@VminBaseline_ParameterID VARCHAR(MAX)='121'
		,@NumOfStepsBaseline_ParameterID VARCHAR(MAX)='122'


IF @DebugMode=1
	SET @P=''
ELSE
	SET @P=NULL
----------------------------------------------------------------------------------------------------------------------
--										Create Tables
----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Models') IS NOT NULL 
	DROP TABLE #Models

IF OBJECT_ID('tempdb..#RawData') IS NOT NULL 
	DROP TABLE #RawData

IF OBJECT_ID('tempdb..#AggregatedData') IS NOT NULL 
	DROP TABLE #AggregatedData

IF OBJECT_ID('tempdb..#PreparedData_PerModel') IS NOT NULL 
	DROP TABLE #PreparedData_PerModel

IF OBJECT_ID('tempdb..#PreparedData_PerModelGroup') IS NOT NULL 
	DROP TABLE #PreparedData_PerModelGroup


CREATE TABLE #Models (BOMGROUP VARCHAR(MAX),ModelID INT ,Domain VARCHAR(MAX), Corner VARCHAR(MAX), Bin INT, Vmin Float, NumOfSteps FLOAT)

CREATE TABLE #RawData (BOMGROUP VARCHAR(MAX),[Indicator] VARCHAR(MAX),[Test_Program] VARCHAR(MAX), Domain VARCHAR(MAX), Corner VARCHAR(MAX), Bin INT, [WW] INT ,[Test_Date] DATE ,[Value] FLOAT)

CREATE TABLE #AggregatedData( [BOMGROUP] VARCHAR(MAX),[Domain] VARCHAR(MAX),[Corner] VARCHAR(MAX),[Bin] INT)

CREATE TABLE #PreparedData_PerModel( [BOMGROUP] VARCHAR(MAX),[Domain] VARCHAR(MAX),[Corner] VARCHAR(MAX),[Bin] INT,[Vmin (Baseline)] FLOAT,[Number of Steps (Baseline)] FLOAT, [Vmin Count] INT,[Tests Results Count] INT, [Vmin Sum] FLOAT,Vmin FLOAT,[VMin Change Percent] FLOAT,[Number of Steps] FLOAT, [Saved Steps] FLOAT, [Saved Steps Percent] FLOAT, [Potential OverShoot] INT,[Certain OverShoot] INT
									 ,[OverShoot] INT, [OverShoot Percent] FLOAT, [Prediction Calculated Count] INT, [Prediction Calculated Percent] FLOAT, [Prediction Used Count] INT, [Prediction Used Percent] FLOAT, [Prediction Justified Unused Count] INT
								 	 ,[Prediction Unjustified Unused Count] INT, [Prediction Unexplained Unused Count] INT )

CREATE TABLE #PreparedData_PerModelGroup ( [BOMGROUP] VARCHAR(MAX),[Vmin Count] INT,[Tests Results Count] INT, [Saved Steps] FLOAT, [Saved Steps Percent] FLOAT, [Potential OverShoot] INT,[Certain OverShoot] INT
									 ,[OverShoot] INT, [OverShoot Percent] FLOAT, [Prediction Calculated Percent] FLOAT, [Prediction Used Percent] FLOAT)


----------------------------------------------------------------------------------------------------------------------
--										Populate #Models
----------------------------------------------------------------------------------------------------------------------
-- holds model data (BOMGROUP,domain,corner,flow,Vmin baseline, Number Of Step Baseline)
SET @FailPoint='1'

INSERT INTO  #Models
SELECT
	 BOMGROUP=M.[Version]
	,Res1.*
	,CAST(MP1.Value AS FLOAT)
	,CAST(MP2.Value AS FLOAT)
FROM(
	SELECT	 [ModelID]
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
ON M.ModelID=Res1.ModelID
INNER JOIN GM_F_ModelingParameters MP1
ON Res1.ModelID=MP1.ModelID
AND MP1.ParameterID=@VminBaseline_ParameterID
INNER JOIN GM_F_ModelingParameters MP2
ON Res1.ModelID=MP2.ModelID
AND MP2.ParameterID=@NumOfStepsBaseline_ParameterID

----------------------------------------------------------------------------------------------------------------------
--										Populate #RawData
----------------------------------------------------------------------------------------------------------------------
-- Holds the Indicators raw data
--    1.Pivoted Indicators
--	  2.Filtered according to users input
SET @FailPoint='2'

SET @WW=''''+@WW+''''
SET @Step=''''+@Step+''''

SET @SQL='
INSERT INTO #RawData
SELECT [BOMGROUP] 
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
	SELECT BOMGROUP
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
		SELECT [BOMGROUP]
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
		INNER JOIN [dbo].[GM_R_ModelIndicatorValues] MIV
		ON ILI.IndicatorLevelID=MIV.IndicatorLevelID
		AND ILI.ModelID=MIV.ModelID
		AND ILI.IndicatorLevelInstanceID= MIV.IndicatorLevelInstanceID
		INNER JOIN GM_D_Indicators I
		ON I.IndicatorID=MIV.IndicatorID
		INNER JOIN #Models M
		ON M.ModelID=ILI.ModelID
		CROSS APPLY dbo.UDF_GetStringTableFromList_New(ComponentValues,'','',NULL)
	)Res1
	PIVOT
	(MAX(Res1.ParsedKey) FOR place IN ([1],[2],[3],[4])) as PVT
)Res2
WHERE 1=1'+CHAR(13)
+CASE WHEN @WW!='''All''' THEN 'AND WW IN (SELECT value from UDF_GetStringTableFromList_New('+@WW+','','',NULL))' +CHAR(13)  ELSE ''  END 
+CASE WHEN @Step!='''All''' THEN 'AND SUBSTRING(Test_Program,10,1) IN (SELECT value from UDF_GetStringTableFromList_New('+@Step+','','',NULL))' +CHAR(13)  ELSE ''  END 
+'ORDER BY IndicatorID'

PRINT(@SQL+@P)
EXEC(@SQL)

----------------------------------------------------------------------------------------------------------------------
--										Populate #AggregatedData 
----------------------------------------------------------------------------------------------------------------------
-- Holds Indicators Aggregated data Per - BOMGROUP,Domain,Corner,Bin
SET @FailPoint='3'
------------ Create Supportive strings
SELECT @IndicatorsList1=ISNULL(@IndicatorsList1+','+'['+IndicatorName+']',' ['+IndicatorName+']')
	  ,@IndicatorsList2=ISNULL(@IndicatorsList2+CHAR(13)+','+'['+IndicatorName+']'+'='+'['+IndicatorName+']',' ['+IndicatorName+']'+'='+'['+IndicatorName+']')
	  ,@IndicatorsList3=ISNULL(@IndicatorsList3+CHAR(13)+','+'['+IndicatorName+']'+' '+'FLOAT',' ['+IndicatorName+']'+' '+'FLOAT')
	  ,@IndicatorsList4=ISNULL(@IndicatorsList4+CHAR(13)+','+'['+IndicatorName+']'+'='+'SUM(['+IndicatorName+'])',' ['+IndicatorName+']'+'='+'SUM(['+IndicatorName+'])')
FROM(
	SELECT DISTINCT IndicatorName
	FROM [GM_F_ModelIndicators] MI
	INNER JOIN [GM_D_Indicators] I
	ON I.IndicatorID=MI.IndicatorID
	AND MI.SolutionID=@SolutionID
) Res1

PRINT @IndicatorsList1+char(13)+@P
PRINT @IndicatorsList2+char(13)+@P
PRINT @IndicatorsList3+char(13)+@P
PRINT @IndicatorsList4+char(13)+@P

------------ Add columns to table ------------------
SET @FailPoint='4'

SET @SQL='
ALTER TABLE #AggregatedData
ADD '+@IndicatorsList3

PRINT (@SQL+@P)
EXEC(@SQL)
-------------------
ALTER TABLE #AggregatedData
ADD Vmin_Baseline FLOAT,NumOfSteps_Baseline FLOAT

------------ Populate table ------------------
SET @FailPoint='5'

SET @SQL='
INSERT INTO #AggregatedData
SELECT  Res2.*
	   ,M.Vmin 
	   ,M.NumOfSteps 
FROM(
	SELECT  BOMGROUP
		   ,Domain
		   ,Corner
		   ,Bin
		   ,'+@IndicatorsList4+'
	FROM(
		SELECT  BOMGROUP
			   ,Test_Program
			   ,Domain
			   ,Corner
			   ,Bin
			   ,WW
			   ,Test_Date
			   ,'+@IndicatorsList2+'
		FROM #RawData 
		PIVOT
		(MAX(Value) FOR Indicator IN ('+@IndicatorsList1+')) PVT
	)Res1
	GROUP BY BOMGROUP,Domain,Corner,Bin
)Res2
INNER JOIN #Models M
ON M.Domain=Res2.Domain
AND M.Corner=Res2.Corner
AND M.Bin=Res2.Bin
'

PRINT (@SQL+@P)
EXEC(@SQL)


----------------------------------------------------------------------------------------------------------------------
--										Populate #PreparedData_PerModel - Output Table 
----------------------------------------------------------------------------------------------------------------------
SET @FailPoint='6'

INSERT INTO #PreparedData_PerModel
SELECT	 [BOMGROUP]
		,[Domain]
		,[Corner]
		,[Bin]
		,[VMin (Baseline)]=Vmin_Baseline
		,[Number of Steps (Baseline)]=NumOfSteps_Baseline
		,[Vmin Count]=Vmin_CNT
		,[Tests Results Count]=[TestsResults_CNT]
		,[Vmin Sum]=Vmin_SUM
		,[Vmin]=1.0*Vmin_SUM/Vmin_CNT
		,[VMin Change Percent]=1.0*(1.0*Vmin_SUM/Vmin_CNT-Vmin_Baseline)/Vmin_Baseline
		,[Number of Steps]=1.0*[Steps_WP_CNT]/[Vmin_CNT]
		,[Saved Steps]=NumOfSteps_Baseline-(1.0*[Steps_WP_CNT]/[Vmin_CNT])
		,[Saved Steps Percent]=1.0*(NumOfSteps_Baseline-(1.0*[Steps_WP_CNT]/[Vmin_CNT]))/(NumOfSteps_Baseline)
		,[Potential OverShoot]=[Potential_OS_CNT]
		,[Certain OverShoot]=[Certain_OS_CNT]
		,[Overshoot]=[Total_OS_CNT]
		,[Overshoot Percent]=1.0*[Total_OS_CNT]/[Vmin_CNT]
		,[Prediction Calculated Count]=[Prediction_Calculated_CNT]
		,[Prediction Calculated Percent]=CAST(1.0*[Prediction_Calculated_CNT]/[Vmin_CNT] AS decimal(18,4))
		,[Prediction Used Count]=[Prediction_Used_CNT]
		,[Prediction Used Percent]=1.0*[Prediction_Used_CNT]/[TestsResults_CNT]
		,[Prediction Justified Unused Count]=[Prediction_Justified_Unused_CNT]
		,[Prediction Unjustified Unused Count]=[Prediction_Unjustified_Unused_CNT]
		,[Prediction Unexplained Unused Count]=[Prediction_Unexplained_Unused_CNT]
FROM #AggregatedData

----------------------------------------------------------------------------------------------------------------------
--										Populate #PreparedData_PerModelGroup - Output Table 
----------------------------------------------------------------------------------------------------------------------
SET @FailPoint='7'

INSERT INTO #PreparedData_PerModelGroup
SELECT	 [BOMGROUP]
		,[Vmin Count]=SUM([Vmin Count])
		,[Tests Results Count]=SUM([Tests Results Count])
		,[Saved Steps]=1.0*SUM([Saved Steps]*[Vmin Count])/SUM([Vmin Count])
		,[Saved Steps Percent] =1.0*SUM([Saved Steps Percent]*[Vmin Count])/SUM([Vmin Count])
		,[Potential OverShoot]=1.0*SUM([Potential OverShoot]*[Vmin Count])/SUM([Vmin Count])
		,[Certain OverShoot]=1.0*SUM([Certain OverShoot]*[Vmin Count])/SUM([Vmin Count]) 
		,[OverShoot]=1.0*SUM([OverShoot]*[Vmin Count])/SUM([Vmin Count]) 
		,[OverShoot Percent] =1.0*SUM([OverShoot Percent]*[Vmin Count])/SUM([Vmin Count]) 
		,[Prediction Calculated Percent] =CAST(1.0*SUM(1.0*[Prediction Calculated Percent]*[Tests Results Count])/SUM([Tests Results Count])  AS decimal(18,4))
		,[Prediction Used Percent]=1.0*SUM([Prediction Used Percent]*[Tests Results Count])/SUM([Tests Results Count]) 
FROM #PreparedData_PerModel
GROUP BY BOMGROUP


-- Output
DROP table PreparedData_PerModel
DROP table PreparedData_PerModelGroup
SELECT * INTO PreparedData_PerModel FROM #PreparedData_PerModel
SELECT * INTO PreparedData_PerModelGroup FROM #PreparedData_PerModelGroup

------------------------------------- END proc ---------------------------------
--END TRY
--BEGIN CATCH  	
--	PRINT ('Fail Point: '+ @FailPoint + ' - ' + ERROR_MESSAGE())
--END CATCH 
--GO