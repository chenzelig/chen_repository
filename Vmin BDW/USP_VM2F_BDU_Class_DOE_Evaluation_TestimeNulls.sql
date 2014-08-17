USE MPDExploration
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_DOE_Evaluation_TestTimeNulls]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_DOE_Evaluation_TestTimeNulls]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USP_VM2F_BDU_Class_DOE_Evaluation_TestTimeNulls]
	 @DiscardMismatchedResults VARCHAR(20)=NULL
	,@ShowPredictionMismatch BIT=1
	,@UseTestimeNulls BIT=0
	,@Prefix VARCHAR(MAX)
	,@ClassTest VARCHAR(MAX)
	,@DebugMode BIT=0
	,@Description BIT=0
AS

BEGIN TRY     

IF @Description=1
PRINT('
Purpose:
--------
evalute the experiments results WP and NP.


Requirements:
-------------
1. Target_Values table.
2. Midas results, TestData Tables.
3. Class Test table.
')
------------------ Variable Declaration --------------------------------
DECLARE @SQL VARCHAR(MAX)
   	   ,@FailPoint  VARCHAR(MAX)
	   ,@FailMessage VARCHAR(MAX)
	   ,@FilteredUnitCount INT
	   ,@UnitCount INT
	   
	   	
------------------ Configuration Validation -----------------------------

SET @FailPoint='1'
SET @FailMessage=NULL

--------------
IF (@DiscardMismatchedResults IS NOT NULL) AND (@DiscardMismatchedResults NOT IN ('Test_Actual','Group_Actual','TestProgram_Actual','Group_Max','TestProgram_Max'))
	SET @FailMessage='@DiscardMismatchedResults must have one out of the following values: ''Test_Actual'',''Group_Actual'',''TestProgram_Actual'',''Group_Max'',''TestProgram_Max'''
---------------
IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @prefix+'_WP_TESTTIME_Results_String')
	SET @FailMessage=@prefix+'_WP_TESTTIME_Results_String Doesn''t Exist'

IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @prefix+'_NP_TESTTIME_Results_String')
	SET @FailMessage=@prefix+'_NP_TESTTIME_Results_String Doesn''t Exist'
--------------
IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @prefix+'_WP_TESTTIME_TestData')
	SET @FailMessage=@prefix+'_WP_TESTTIME_TestData Doesn''t Exist'

IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @prefix+'_NP_TESTTIME_TestData')
	SET @FailMessage=@prefix+'_NP_TESTTIME_TestData Doesn''t Exist'
---------------
IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @prefix+'_WP_Target_Values')
	SET @FailMessage=@prefix+'_WP_Target_Values Doesn''t Exist'

IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @prefix+'_NP_Target_Values')
	SET @FailMessage=@prefix+'_NP_Target_Values Doesn''t Exist'
---------------
IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @ClassTest)
	SET @FailMessage=@ClassTest+' Doesn''t Exist'


IF @FailMessage IS NOT NULL
	RAISERROR (@FailMessage, 16, 1) 
------------------ Create Tables -------------------------------------	
SET @FailPoint='2'

IF OBJECT_ID('tempdb..#TT') IS NOT NULL 
		DROP TABLE #TT
	
IF OBJECT_ID('tempdb..#Target') IS NOT NULL 
	DROP TABLE #Target

IF OBJECT_ID('tempdb..#FilteredUnits') IS NOT NULL 
	DROP TABLE #FilteredUnits

IF OBJECT_ID('tempdb..#Res1') IS NOT NULL 
	DROP TABLE #Res1

IF OBJECT_ID('tempdb..#Res2') IS NOT NULL 
	DROP TABLE #Res2

CREATE TABLE #Res1(
     [groupID] INT
	,[Domain] VARCHAR(100)
	,[Corner] VARCHAR(100)
	,[Flow] INT
	,[Unit Count] INT
	,[Steps Without Prediction] FLOAT
	,[Steps With Prediction] FLOAT
	,[Saved Steps] FLOAT
	,[Saved Steps Percent] FLOAT
	,[Overshoot Count] INT
	,[Overshoot Percent] FLOAT
	,[OS_10MV] INT
	,[OS_20MV] INT
	,[OS_30MV] INT
	,[OS_40MV] INT
	,[OS_50MV] INT
	,[OS_50PLUS] INT
	,[TT Per Unit Without Prediction] FLOAT
	,[TT Per Unit With Prediction] FLOAT
	,[TTR Per Unit] FLOAT
	,[Steps Per Unit Without Prediction] FLOAT
	,[Steps Per Unit With Prediction] FLOAT
	,[Saved Steps Per Unit] FLOAT
	,[Saved Steps Per Unit Percent] FLOAT
	,[Saved Steps Per Unit Overall Percent] FLOAT
)

CREATE TABLE #Res2(
	 [Number Of Units] INT 
	,[Saved Steps] FLOAT
	,[Saved Steps Percent] FLOAT
	,[TTR] FLOAT
	,[Overshoot Percent] FLOAT
)

CREATE TABLE #TT(
	 ProductID INT
	,UnitID BIGINT
	,GroupID INT
	,TestID INT 
	,TT_NP FLOAT
	,ST_NP FLOAT
	,TT_WP FLOAT
	,ST_WP FLOAT
)
		
CREATE TABLE #Target(
	 ProductID INT
	,GroupID INT
	,TestID INT 
	,UnitID BIGINT
	,Domain VARCHAR(100)
	,Corner VARCHAR(100)
	,Flow VARCHAR(100)
	,MaxValue_NP FLOAT
	,ActualValue_NP FLOAT
	,MinValue_NP FLOAT
	,Step_NP INT		 
	,TT_NP FLOAT
	,MaxValue_WP FLOAT
	,ActualValue_WP FLOAT
	,MinValue_WP FLOAT
	,Step_WP INT
	,TT_WP FLOAT
	,Resolution FLOAT
	,[Matched_Test_Actual] INT
	,[Matched_Group_Actual] INT
	,[Matched_TestProgram_Actual] INT
	,[Matched_Group_Max] INT
	,[Matched_TestProgram_Max] INT
)

CREATE TABLE #FilteredUnits(
	 UnitID BIGINT
)

PRINT ('--------- populate TESTTIME table ----------------')+CHAR(13)

SET @FailPoint='3'
SET @SQL='
	INSERT INTO #TT (ProductID,UnitID,GroupID,TestID,TT_NP,ST_NP,TT_WP,ST_WP)
	SELECT TT1.ProductID,TT1.UnitID,TT1.GroupID,TT1.TestID,TT2.TT,TT2.ST,TT1.TT,TT1.ST
	FROM (
		SELECT 
			 ProductID
			,UnitID
			,GroupID
			,TestID
			,TD.PartitionKey
			,TD.partitionColumn
			,TD.testName
			,Value
			,ST=CONVERT(FLOAT,SUBSTRING(Value,5,CHARINDEX(''_MAIN_'',Value)-7))
			,TT=CONVERT(FLOAT,LEFT(RIGHT(Value,LEN(value)-CHARINDEX(''_MAIN_'',Value)-5),LEN(RIGHT(Value,LEN(value)-CHARINDEX(''_MAIN_'',Value)-5))-2))
			,total=CONVERT(FLOAT,SUBSTRING(Value,5,CHARINDEX(''_MAIN_'',Value)-7))
						+CONVERT(FLOAT,LEFT(RIGHT(Value,LEN(value)-CHARINDEX(''_MAIN_'',Value)-5),LEN(RIGHT(Value,LEN(value)-CHARINDEX(''_MAIN_'',Value)-5))-2))
		FROM
		[dbo].['+@prefix+'_WP_TESTTIME_Results_String]
		UNPIVOT
		(Value FOR partitionColumn IN(
			col0,col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,col21,col22,col23,col24,col25,col26
			,col27,col28,col29,col30,col31,col32,col33,col34,col35,col36,col37,col38,col39,col40,col41,col42,col43,col44,col45,col46,col47,col48,col49,col50,col51,col52
			,col53,col54,col55,col56,col57,col58,col59,col60,col61,col62,col63,col64,col65,col66,col67,col68,col69,col70,col71,col72,col73,col74,col75,col76,col77,col78
			,col79,col80,col81,col82,col83,col84,col85,col86,col87,col88,col89,col90,col91,col92,col93,col94,col95,col96,col97,col98,col99,col100,col101,col102,col103,col104
			,col105,col106,col107,col108,col109,col110,col111,col112,col113,col114,col115,col116,col117,col118,col119,col120,col121,col122,col123,col124,col125,col126,col127,col128
			,col129,col130,col131,col132,col133,col134,col135,col136,col137,col138,col139,col140,col141,col142,col143,col144,col145,col146,col147,col148,col149,col150
			,col151,col152,col153,col154,col155,col156,col157,col158,col159,col160,col161,col162,col163,col164,col165,col166,col167,col168,col169,col170,col171,col172
			,col173,col174,col175,col176,col177,col178,col179,col180,col181,col182,col183,col184,col185,col186,col187,col188,col189,col190,col191,col192,col193,col194
			,col195,col196,col197,col198,col199)
		) AS unpvt
		INNER JOIN ['+@prefix+'_WP_TESTTIME_TestData] TD
		On TD.partitionKey=unpvt.partitionKey
		AND TD.partitionColumn=unpvt.partitionColumn
		AND colTypeID=2
		INNER JOIN (SELECT DISTINCT ProductID,GroupID,TestID,TestName FROM '+@ClassTest+') CT
		ON ''TESTTIME_''+CT.TestName=TD.testName
	) TT1
	INNER JOIN (
		SELECT 
			 unitID
			,GroupID
			,TestID
			,TD.PartitionKey
			,TD.partitionColumn
			,TD.testName
			,Value
			,ST=CONVERT(FLOAT,SUBSTRING(Value,5,CHARINDEX(''_MAIN_'',Value)-7))
			,TT=CONVERT(FLOAT,LEFT(RIGHT(Value,LEN(value)-CHARINDEX(''_MAIN_'',Value)-5),LEN(RIGHT(Value,LEN(value)-CHARINDEX(''_MAIN_'',Value)-5))-2))
			,total=CONVERT(FLOAT,SUBSTRING(Value,5,CHARINDEX(''_MAIN_'',Value)-7))
						+CONVERT(FLOAT,LEFT(RIGHT(Value,LEN(value)-CHARINDEX(''_MAIN_'',Value)-5),LEN(RIGHT(Value,LEN(value)-CHARINDEX(''_MAIN_'',Value)-5))-2))
		FROM
		[dbo].['+@prefix+'_NP_TESTTIME_Results_String]
		UNPIVOT
		(Value FOR partitionColumn IN(
			col0,col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,col21,col22,col23,col24,col25,col26
			,col27,col28,col29,col30,col31,col32,col33,col34,col35,col36,col37,col38,col39,col40,col41,col42,col43,col44,col45,col46,col47,col48,col49,col50,col51,col52
			,col53,col54,col55,col56,col57,col58,col59,col60,col61,col62,col63,col64,col65,col66,col67,col68,col69,col70,col71,col72,col73,col74,col75,col76,col77,col78
			,col79,col80,col81,col82,col83,col84,col85,col86,col87,col88,col89,col90,col91,col92,col93,col94,col95,col96,col97,col98,col99,col100,col101,col102,col103,col104
			,col105,col106,col107,col108,col109,col110,col111,col112,col113,col114,col115,col116,col117,col118,col119,col120,col121,col122,col123,col124,col125,col126,col127,col128
			,col129,col130,col131,col132,col133,col134,col135,col136,col137,col138,col139,col140,col141,col142,col143,col144,col145,col146,col147,col148,col149,col150
			,col151,col152,col153,col154,col155,col156,col157,col158,col159,col160,col161,col162,col163,col164,col165,col166,col167,col168,col169,col170,col171,col172
			,col173,col174,col175,col176,col177,col178,col179,col180,col181,col182,col183,col184,col185,col186,col187,col188,col189,col190,col191,col192,col193,col194
			,col195,col196,col197,col198,col199)
		) AS unpvt
		INNER JOIN ['+@prefix+'_NP_TESTTIME_TestData] TD
		On TD.partitionKey=unpvt.partitionKey
		AND TD.partitionColumn=unpvt.partitionColumn
		AND colTypeID=2
		INNER JOIN (SELECT DISTINCT GroupID,TestID,TestName FROM '+@ClassTest+') CT
		ON ''TESTTIME_''+CT.TestName=TD.testName
	) TT2
	ON TT1.groupID=TT2.groupID
	AND TT1.TestID=TT2.TestID
	AND TT1.UnitID=TT2.UnitID'


PRINT(@SQL)+CHAR(13)
EXEC(@SQL)

IF @debugMode=1 
	SELECT * FROM #TT



PRINT ('------------------ Populate Target Table ---------------------')+CHAR(13)

SET @FailPoint='4'
SET @SQL='
INSERT INTO #Target  
SELECT   WP.ProductID,WP.GroupID,WP.TestID,WP.UnitID,Domain,Corner,Flow
		,NP.MaxValue as MaxValue_NP
		,NP.ActualValue as ActualValue_NP
		,NP.MinValue as MinValue_NP
		--,[Step_NP] = CASE  WHEN WP.ActualValue=NP.ActualValue THEN NP.step
		--		WHEN WP.ActualValue>NP.ActualValue AND WP.step=0 THEN NP.step
		--		ELSE (WP.ActualValue-WP.MinValue)/Resolution END
		,[Step_NP]=NP.step
		,TT.TT_NP
		,WP.MaxValue as MaxValue_WP
		,WP.ActualValue as ActualValue_WP
		,WP.MinValue as MinValue_WP
		,WP.step as Step_WP
		,TT.TT_WP
		,C.Resolution
		,[Matched_Test_Actual] = CASE WHEN WP.ActualValue=NP.ActualValue THEN 1
				 		   	   WHEN WP.ActualValue>NP.ActualValue AND WP.step=0 THEN 1
				 		  ELSE 0 END
		,[Matched_Group_Actual]= MIN(CASE WHEN WP.ActualValue=NP.ActualValue THEN 1
				 					WHEN WP.ActualValue>NP.ActualValue AND WP.step=0 THEN 1
				 					ELSE 0 END) 
						       OVER (PARTITION BY WP.UnitID, WP.GroupID)
		,[Matched_TestProgram_Actual]= MIN(CASE WHEN WP.ActualValue=NP.ActualValue THEN 1
				 				WHEN WP.ActualValue>NP.ActualValue AND WP.step=0 THEN 1
				 				ELSE 0 END) 
						OVER (PARTITION BY WP.UnitID)
		,[Matched_Group_Max]= MIN(CASE WHEN NP.MaxValue=WP.MaxValue THEN 1 ELSE 0 END) 
						       OVER (PARTITION BY WP.UnitID, WP.GroupID)
		,[Matched_TestProgram_Max] = MIN(CASE WHEN NP.MaxValue=WP.MaxValue THEN 1 ELSE 0 END)
									 OVER (PARTITION BY WP.UnitID)
FROM  ['+@prefix+'_WP_Target_Values] WP
inner JOIN ['+@prefix+'_NP_Target_Values] NP
on WP.productid=NP.productid
and WP.groupid=NP.groupid
AND WP.testid=NP.testid
and WP.unitid=NP.unitid	
INNER JOIN (SELECT DISTINCT GroupID,TestID,domain,corner,flow,Resolution from '+@ClassTest+') C
ON WP.GroupID=C.GroupID 
AND WP.TestID=C.TestID 
'+CASE WHEN @UseTestimeNulls=1 THEN 'LEFT' ELSE +'INNER' END +' JOIN #TT TT
ON WP.GroupID=TT.GroupID
AND WP.TestID=TT.TestID
AND WP.UnitID=TT.UnitID'


PRINT(@SQL)+CHAR(13)
EXEC(@SQL)

IF @debugMode=1 
	SELECT * FROM #Target


PRINT ('--------- populate filtered units table -------------------')+CHAR(13)
SET @FailPoint='5'

INSERT INTO #FilteredUnits
SELECT DISTINCT UnitID
FROM #Target
WHERE [Matched_Test_Actual]=CASE WHEN @DiscardMismatchedResults='Test_Actual' THEN 1 ELSE [Matched_Test_Actual] END
AND   [Matched_Group_Actual]=CASE WHEN @DiscardMismatchedResults='Group_Actual' THEN 1 ELSE [Matched_Group_Actual] END
AND   [Matched_TestProgram_Actual]=CASE WHEN @DiscardMismatchedResults='TestProgram_Actual' THEN 1 ELSE [Matched_TestProgram_Actual] END
AND   [Matched_Group_Max]=CASE WHEN @DiscardMismatchedResults='Group_Max' THEN 1 ELSE [Matched_Group_Max] END
AND   [Matched_TestProgram_Max]=CASE WHEN @DiscardMismatchedResults='TestProgram_Max' THEN 1 ELSE [Matched_TestProgram_Max] END

IF @debugMode=1
	SELECT * FROM #FilteredUnits

PRINT ('--------- calculate Unit Count -------------------')+CHAR(13)
SET @FailPoint='6'

SELECT @UnitCount=COUNT(DISTINCT UnitID) FROM #Target
SELECT @FilteredUnitCount= COUNT(DISTINCT T.UnitID) FROM #Target T INNER JOIN #FilteredUnits F ON T.UnitID=F.UnitID

IF @UnitCount=0 
	RAISERROR ('Unit Count=0 Is Invalid for this operation', 16, 1) 

IF @FilteredUnitCount=0 
	RAISERROR ('Filtered Unit Count=0 Is Invalid for this operation', 16, 1) 

PRINT ('--------------------- Group Level Evaluation ---------------------------------------------------')+CHAR(13)
SET @FailPoint='7'

INSERT INTO #Res1
SELECT 
	 Res2.[groupID]
	,[Domain]
	,[Corner]
	,[Flow]
	,[Unit Count]
	,[Steps Without Prediction]
	,[Steps With Prediction]
	,[Saved Steps]=[Steps Without Prediction]-[Steps With Prediction]
	,[Saved Steps Percent]=ISNULL(CAST(1.00*([Steps Without Prediction]-[Steps With Prediction])/NULLIF([Steps Without Prediction],0) AS DECIMAL (18,4)),0)
	,[Overshoot Count]
	,[Overshoot Percent]=ISNULL(CAST(1.00*([Overshoot Count])/NULLIF([Unit Count],0) AS DECIMAL (18,4)),0)
	,[OS_10MV]
	,[OS_20MV]
	,[OS_30MV]
	,[OS_40MV]
	,[OS_50MV]
	,[OS_50PLUS]
	,[TT Per Unit Without Prediction]
	,[TT Per Unit With Prediction]
	,[TTR Per Unit]=[TT Per Unit Without Prediction]-[TT Per Unit With Prediction]
	,[Steps Per Unit Without Prediction]=CAST([Steps Per Unit Without Prediction] AS DECIMAL (18,2))
	,[Steps Per Unit With Prediction]=CAST([Steps Per Unit With Prediction] AS DECIMAL (18,2))
	,[Saved Steps Per Unit]= CAST([Steps Per Unit Without Prediction]-[Steps Per Unit With Prediction] AS DECIMAL (18,2))
	,[Saved Steps Per Unit Percent]= ISNULL(CAST(1.00*([Steps Per Unit Without Prediction]-[Steps Per Unit With Prediction])/NULLIF([Steps Per Unit Without Prediction],0) AS DECIMAL(18,4)),0)
	,[Saved Steps Per Unit Overall Percent]=CAST((1.00*[Steps Per Unit Without Prediction]-[Steps Per Unit With Prediction])/NULLIF((SUM([Steps Per Unit Without Prediction]-[Steps Per Unit With Prediction]) OVER()),0) AS DECIMAL (18,4))
FROM (
	SELECT 
	      --Per Group 
		  [productid]    
	     ,[groupID]
	     ,[Domain]
	     ,[Corner]
	     ,[Flow]
	     ,[Unit Count]=COUNT(DISTINCT T.unitID) -- Distinct because each unit has several rows (per test) in a group
	     ,[Steps Without Prediction]= SUM(Step_NP)/COUNT(DISTINCT F.UnitID)
	     ,[Steps With Prediction]=SUM(Step_WP)/COUNT(DISTINCT F.UnitID) 
	    
		 -- Per Test Program
	     ,[TT Per Unit Without Prediction]=SUM(TT_NP)/(1.0*@FilteredUnitCount)
		 ,[TT Per Unit With Prediction]=SUM(TT_WP)/(1.0*@FilteredUnitCount) 
		 ,[Steps Per Unit Without Prediction] = SUM(Step_NP)/(1.0*@FilteredUnitCount)
	     ,[Steps Per Unit With Prediction] = SUM(Step_WP)/(1.0*@FilteredUnitCount)
	FROM #Target T
	INNER JOIN #FilteredUnits F
	ON T.UnitID=F.UnitID
	GROUP BY productid, groupid, Domain,Corner,Flow
) Res2
INNER JOIN 
	(SELECT 
		 [GroupID]
		,[Overshoot Count]=SUM(T1.[Overshoot Count])
		,[OS_10MV]=SUM(T1.[OS_10MV])
		,[OS_20MV]=SUM(T1.[OS_20MV])
		,[OS_30MV]=SUM(T1.[OS_30MV])
		,[OS_40MV]=SUM(T1.[OS_40MV])
		,[OS_50MV]=SUM(T1.[OS_50MV])
		,[OS_50PLUS]=SUM(T1.[OS_50PLUS])
	FROM(
		SELECT  
 			 [GroupID]
			,T.[UnitID]
			,[Overshoot Count] = CASE WHEN MAX(MaxValue_WP)>MAX(MaxValue_NP) AND MAX(T.Step_WP)=0 THEN 1 ELSE 0 END
			,[OS_10MV]=CASE WHEN MAX(MaxValue_WP)>MAX(MaxValue_NP) AND MAX(MaxValue_WP)<= MAX(MaxValue_NP)+0.01 AND MAX(T.Step_WP)=0  THEN 1 ELSE 0 END
			,[OS_20MV]=CASE WHEN MAX(MaxValue_WP)>MAX(MaxValue_NP)+0.01 AND MAX(MaxValue_WP)<= MAX(MaxValue_NP)+0.02 AND MAX(T.Step_WP)=0 THEN 1 ELSE 0 END
			,[OS_30MV]=CASE WHEN MAX(MaxValue_WP)>MAX(MaxValue_NP)+0.02 AND MAX(MaxValue_WP)<= MAX(MaxValue_NP)+0.03 AND MAX(T.Step_WP)=0 THEN 1 ELSE 0 END
			,[OS_40MV]=CASE WHEN MAX(MaxValue_WP)>MAX(MaxValue_NP)+0.03 AND MAX(MaxValue_WP)<= MAX(MaxValue_NP)+0.04 AND MAX(T.Step_WP)=0 THEN 1 ELSE 0 END
			,[OS_50MV]=CASE WHEN MAX(MaxValue_WP)>MAX(MaxValue_NP)+0.04 AND MAX(MaxValue_WP)<= MAX(MaxValue_NP)+0.05 AND MAX(T.Step_WP)=0 THEN 1 ELSE 0 END
			,[OS_50PLUS]=CASE WHEN MAX(MaxValue_WP)>MAX(MaxValue_NP)+0.05 AND MAX(T.Step_WP)=0 THEN 1 ELSE 0 END
		FROM #Target T
		INNER JOIN #FilteredUnits F
		ON T.UnitID=F.UnitID
		GROUP BY GroupID,T.UnitID 
	) T1
	GROUP BY T1.GroupID
) Res3
ON Res2.GroupID=Res3.GroupID

SELECT * FROM #Res1

PRINT ('--------------------- TestProgram Level Evaluation ---------------------------------------------------')+CHAR(13)
SET @FailPoint='8'

INSERT INTO #Res2
SELECT 
	 [Number Of Units]=@FilteredUnitCount
	,[Saved Steps]=CAST(SUM([Steps Per Unit Without Prediction]-[Steps Per Unit With Prediction]) AS decimal (18,2))
	,[Saved Steps Percent]=CAST(1.0*SUM([Steps Per Unit Without Prediction]-[Steps Per Unit With Prediction])/NULLIF(SUM([Steps Per Unit Without Prediction]),0) AS DECIMAL (18,4))
	,[TTR]=CASE WHEN @UseTestimeNulls=1 THEN NULL ELSE CAST(SUM([TT Per Unit Without Prediction]-[TT Per Unit With Prediction])  AS decimal (18,2)) END
	,[Overshoot Percent]= CAST((1.0*SUM([Overshoot Count])/SUM([Unit Count])) AS decimal (18,4))
FROM #Res1

SELECT * FROM #Res2

PRINT ('--------------------- Prediction Mismatch Evaluation --------------------------------------------------')+CHAR(13)

SET @FailPoint='9'

IF 	@ShowPredictionMismatch=1
BEGIN

	SELECT 
			 [Results Total]= COUNT(*)
			,[Results Considered]=COUNT(F.UnitID) -- Won't count the Nulls due to left join
			,[Results Mismatched]=  COUNT(*)-COUNT(F.UnitID)
	FROM #Target T
	LEFT JOIN #FilteredUnits F
	ON T.UnitID=F.UnitID

	SELECT 
			 [Unit Total]= @UnitCount
			,[Unit Considered]=@FilteredUnitCount
			,[Unit Mismatched]= @UnitCount-@FilteredUnitCount
END

PRINT ('--------------------- validation - Group Evaluation table --------------------------------------------------')+CHAR(13)
SET @FailPoint='10'
IF @debugMode=1
SELECT
	 [GroupID]
	,[Unit Count > Overshoot count]=CASE WHEN [Unit Count]>=[Overshoot Count] THEN 1 ELSE 0 END
	,[saved steps = StepsNP-stepsWP]=CASE WHEN [Saved Steps]=[Steps Without Prediction]-[Steps With Prediction] THEN 1 ELSE 0 END
	,[saved steps precent = savedSteps/stepsNP]= CASE WHEN CAST(ISNULL(1.0*[Saved Steps]/NULLIF([Steps Without Prediction],0),0) AS decimal (18,4))=[Saved Steps Percent]  THEN 1 ELSE 0 END
	,[overshoot count= count all OS Deltas]=CASE WHEN [Overshoot Count] =[OS_10MV]+[OS_20MV]+[OS_30MV]+[OS_40MV]+[OS_50MV]+[OS_50PLUS] THEN 1 ELSE 0 END
	,[overshoot percent = overshoot count/unit count] = CASE WHEN [Overshoot Percent]=CAST(ISNULL(1.0*[Overshoot Count]/NULLIF([Unit Count],0),0) AS decimal (18,4)) THEN 1 ELSE 0 END
	,[TTR per Unit = TTR_NP - TTR_WP] = CASE WHEN [TTR Per Unit]=[TT Per Unit Without Prediction]-[TT Per Unit With Prediction] THEN 1 ELSE 0 END
	,[Saved steps Per Unit = Steps Per Unit NP - Steps Per Unit WP]= CASE WHEN [Saved Steps Per Unit]=CAST([Steps Per Unit Without Prediction]-[Steps Per Unit With Prediction] AS DECIMAL (18,2)) THEN 1 ELSE 0 END
FROM #Res1

END TRY

BEGIN CATCH  	
	PRINT ('Fail Point: '+ @FailPoint + ' - ' + ERROR_MESSAGE())
END CATCH 

GO
 