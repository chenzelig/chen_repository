USE MPDExploration
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_AggregatedEvaluation]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_AggregatedEvaluation]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USP_VM2F_BDU_Class_AggregatedEvaluation]
	 @groupTable  NVARCHAR(1000)
	,@FlatTable NVARCHAR(1000)
	,@TargetTable NVARCHAR(1000) 
	,@GroupsList NVARCHAR(MAX) 
AS

--------------------------

DECLARE @Equation VARCHAR (MAX),@CMD VARCHAR(MAX),@Test sysname,@SQLString NVARCHAR(MAX),
		@DFF_LIST VARCHAR(MAX), @DFF_MISSING VARCHAR(MAX), @FailPoint int=0--init
		
-----------------------		               
IF OBJECT_ID('tempdb..#EQ_DATA_allGroups','U') IS NOT NULL
        DROP TABLE #EQ_DATA_allGroups

CREATE TABLE #EQ_DATA_allGroups (GroupID INT, UnitID bigint,EQ FLOAT,EQ_RND NUMERIC(18,6),
                                               DFF_MISSING INT,MAX_V FLOAT)
------------------------
IF OBJECT_ID('tempdb..#GroupsList','U') IS NOT NULL
				DROP TABLE #GroupsList
       
CREATE TABLE #GroupsList (GroupID INT )
       
INSERT INTO #GroupsList (GroupID)
SELECT CONVERT(int,value) as GroupID
FROM [dbo].[UDF_GetStringTableFromList](@GroupsList)	
-----------------------
DECLARE @currentGroupID INT

DECLARE GroupCursor CURSOR FOR
SELECT GroupID
FROM #GroupsList

OPEN GroupCursor

FETCH NEXT FROM GroupCursor 
INTO @currentGroupID

WHILE @@FETCH_STATUS = 0
BEGIN

		SET @SQLString = 'select @Equation =  [Equation] + ''+-'' + cast(isnull(shift,0) as varchar(10))
		from  ' + @groupTable + ' where groupid = ' + cast(@currentGroupID as varchar)
		PRINT(@SQLString)+char(13)
		EXEC sp_executeSql @SQLString, N'@Equation NVARCHAR(max) OUTPUT', @Equation OUTPUT

		PRINT @Equation+char(13)
		PRINT '********************************************'+char(13)
		-------------------------------------------------------------------

		--GET @DFF_LIST
		IF OBJECT_ID('tempdb..#DFF','U') IS NOT NULL
				DROP TABLE #DFF
       
		CREATE TABLE #DFF (DFF     VARCHAR(1000))
       
		INSERT INTO #DFF (DFF)
		SELECT DFF=LEFT(VALUE, CASE WHEN CHARINDEX('+',VALUE)=0 THEN 1000 ELSE CHARINDEX('+',VALUE)-1 END)
		FROM [dbo].[UDF_GetStringTableFromList](REPLACE(@Equation,'*',','))
		WHERE VALUE LIKE 'DFF%' 		      

		SET @SQLString = 'SELECT @Test=''MAX_''+MAX(Domain)+ MAX(''_''+Corner)+ MAX(''_''+Flow)
						  FROM ' + @groupTable + ' WHERE GroupID=' + cast(@currentGroupID as varchar)
		PRINT(@SQLString)+char(13)
		EXEC sp_executeSql @SQLString, N'@Test NVARCHAR(max) OUTPUT', @Test OUTPUT

		PRINT @Test+char(13)
		
		PRINT '********************************************'+char(13)
		-------------------------------------------------------------------

		SET @FailPoint=1 --get data for calculations
		--CREATE THE #EQUATIO UNIT LEVEL DATA
		IF OBJECT_ID('tempdb..#EQ_DATA','U') IS NOT NULL
				DROP TABLE #EQ_DATA
   	  
		CREATE TABLE #EQ_DATA (UnitID bigint,EQ FLOAT,EQ_RND NUMERIC(18,6),
													DFF_MISSING INT,MAX_V FLOAT)

      
		--BUILD INSERT
		SELECT @DFF_LIST =ISNULL(@DFF_LIST+','+CHAR(13),'')+DFF+'=CASE WHEN '+DFF+'=-999  OR '
															+DFF+' IS NULL  THEN AVG_'+DFF+' ELSE '+DFF+' END'
		FROM #DFF

		PRINT @DFF_LIST+char(13)
				
		SELECT @DFF_MISSING=ISNULL(@DFF_MISSING,'CASE WHEN ')+'ISNULL('+DFF+',-999)=-999 OR '
		FROM #DFF
		SET @DFF_MISSING ='DFF_MISSING='+@DFF_MISSING+'1=2 THEN 1 ELSE 0 END,'

		PRINT @DFF_MISSING+char(13)

		SELECT @CMD =ISNULL(@CMD+',','')+'AVG(CASE WHEN '+DFF+'<>-999 THEN '+DFF+' END) AS AVG_'+DFF FROM #DFF
		SET @CMD ='(SELECT '+ @CMD +CHAR(13)+'FROM ' + @FlatTable + ') D'
       
		PRINT @CMD+char(13)

		SET @CMD ='(SELECT unitID,'+CHAR(13)+
							@DFF_MISSING+CHAR(13)+
							'MAX_V='+@Test+','+
							+@DFF_LIST+
		' FROM ' + @FlatTable + ' A'+CHAR(13)    +	  
		' CROSS JOIN '+@CMD+CHAR(13)+
		' WHERE 0=IsTrain'+@Test+')A'
       
		PRINT @CMD+char(13)

      
		SET @CMD='SELECT unitID,'+CHAR(13)+
					'EQ='+@Equation+','+CHAR(13)+
					'EQ_RND=NULL,DFF_MISSING,MAX_V FROM '+@CMD
       
		PRINT @CMD+char(13)
      
		INSERT INTO #EQ_DATA 
		EXEC (@CMD) 

		UPDATE #EQ_DATA SET EQ_RND=FLOOR(EQ*100)/100.0	
	   
		INSERT INTO #EQ_DATA_allGroups
		SELECT @currentGroupID as groupID, *
		FROM #EQ_DATA

		SET  @Equation=NULL
		SET @CMD=NULL
		SET @Test=NULL
		SET @SQLString=NULL
		SET @DFF_LIST=NULL
		SET @DFF_MISSING=NULL
		SET @FailPoint=0
					
		PRINT '********************************************'+char(13)

	FETCH NEXT FROM GroupCursor 
	INTO @currentGroupID
END 

CLOSE GroupCursor;
DEALLOCATE GroupCursor;

-- Aggregation in a unitID level, cross Groups
SET @CMD='
SELECT  sum(UnitSumSteps_WP)/(select count(distinct unitID) from '+@TargetTable+') as [NumSteps_WP],
              sum(UnitSumSteps_NP)/(select count(distinct unitID) from '+@TargetTable+') as [NumSteps_NP]
FROM
       (SELECT UnitID, 
                     Sum(SumSteps_WP) as UnitSumSteps_WP, sum(SumSteps_NP) as UnitSumSteps_NP
       FROM  (SELECT 
                            T.groupID
                           ,T.UnitID
                           ,SUM(CASE WHEN EQ_RND>[ActualValue] THEN 0 
                                         WHEN EQ_RND BETWEEN [MinValue] AND [ActualValue]  THEN CEILING(round(([ActualValue]-EQ_RND),3)/resolution)
                                         WHEN EQ_RND< [MinValue] THEN [step] END) AS SumSteps_WP
                           ,SUM(step) as SumSteps_NP
                     FROM '+@TargetTable+' T
                           INNER JOIN #EQ_DATA_allGroups E
                           ON T.GroupID=E.GroupID
                           AND T.UnitID=E.UnitID
                           INNER JOIN ' + @groupTable + ' G 
                           ON G.groupID=T.groupID
                           AND G.TestId = T.TestId
                     GROUP BY T.groupID,T.UnitID) Res1
         GROUP BY UnitID) Res2' 

PRINT(@CMD)
EXEC(@CMD)

-- Aggregation in a unitID level, per Group
SET @CMD='
SELECT groupID, 
                     Sum(SumSteps_WP)/(select count(distinct unitID) from '+@TargetTable+' WHERE 0=IsTrain) as [NumSteps_WP] , 
                     sum(SumSteps_NP)/(select count(distinct unitID) from '+@TargetTable+' WHERE 0=IsTrain) as [NumSteps_NP] 
        FROM  (SELECT 
                            T.groupID
                           ,T.UnitID
                           ,SUM(CASE WHEN EQ_RND>[ActualValue] THEN 0 
                                         WHEN EQ_RND BETWEEN [MinValue] AND [ActualValue]  THEN CEILING(round(([ActualValue]-EQ_RND),3)/resolution)
                                         WHEN EQ_RND< [MinValue] THEN [step] END) AS SumSteps_WP
                           ,SUM(step) as SumSteps_NP
                     FROM '+@TargetTable+' T
                           INNER JOIN #EQ_DATA_allGroups E
                           ON T.GroupID=E.GroupID
                           AND T.UnitID=E.UnitID
                           INNER JOIN ' + @groupTable + ' G 
                           ON G.groupID=T.groupID
                           AND G.TestId = T.TestId
                     GROUP BY T.groupID,T.UnitID) Res1
         GROUP BY groupID'+CHAR(13)

PRINT(@CMD)
EXEC(@CMD)

GO