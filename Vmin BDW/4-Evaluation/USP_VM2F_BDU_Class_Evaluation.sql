USE [MPDExploration]
GO

/****** Object:  StoredProcedure [dbo].[USP_VM2F_BDU_Class_Evaluation]    Script Date: 7/22/2014 3:35:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USP_VM2F_BDU_Class_Evaluation]  
@GroupID int
,@groupTable  NVARCHAR(1000)
,@TargetTable NVARCHAR(1000)
,@FlatTable NVARCHAR(1000)
AS
------------------------------------
DECLARE @Equation VARCHAR (MAX),@CMD VARCHAR(MAX),@Test sysname,@SQLString NVARCHAR(MAX),
			 @TEST_IDS VARCHAR(MAX),@TEST_LIST VARCHAR(MAX), @TEST_LIST2 VARCHAR(MAX),@TEST_LIST3 VARCHAR(MAX),
             @DFF_LIST VARCHAR(MAX), @DFF_MISSING VARCHAR(MAX), @FailPoint int=0--init


SET @SQLString = 'select @Equation =  [Equation] + ''+-'' + cast(isnull(shift,0) as varchar(10))
from  ' + @groupTable + ' where groupid = ' + cast(@GroupID as varchar)
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
				  FROM ' + @groupTable + ' WHERE GroupID=' + cast(@GroupID as varchar)
PRINT(@SQLString)+char(13)
EXEC sp_executeSql @SQLString, N'@Test NVARCHAR(max) OUTPUT', @Test OUTPUT

PRINT @Test+char(13)
SELECT * FROM #DFF
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
PRINT '********************************************'+char(13)
-------------------------------------------------------------------

SET @FailPoint=2 --TEST LEVL SUMMARY

	   SET @SQLString = 'UPDATE T
       SET T.CNT=E.CNT,
             T.AVG_STEPS_WP=E.AVG_STEPS_WP,
             T.AVG_STEPS_NP=E.AVG_STEPS_NP,
             T.OS_CNT=E.OS_CNT,
             T.OS_10MV=E.OS_10MV,
             T.OS_20MV=E.OS_20MV,
             T.OS_30MV=E.OS_30MV,
             T.OS_40MV=E.OS_40MV,
             T.OS_50MV=E.OS_50MV,
             T.OS_50PLUS=E.OS_50PLUS,
             T.TTR=(E.AVG_STEPS_NP-E.AVG_STEPS_WP)*T.StepCost
       FROM (SELECT V.testId,CNT=COUNT(1),
                                        AVG_STEPS_WP=AVG(
                                               CASE WHEN EQ_RND>V.[ActualValue] THEN 0 
                                                     WHEN EQ_RND BETWEEN V.[MinValue] AND V.[ActualValue]  THEN CEILING(round((V.[ActualValue]-EQ_RND),3)/resolution)
                                                     WHEN EQ_RND< V.[MinValue] THEN V.[step] END),
                                        AVG_STEPS_NP=AVG(V.[step]),
                                        OS_CNT=SUM(CASE WHEN EQ_RND>V.[ActualValue] THEN 1 ELSE 0 END),
                                        OS_10MV=SUM(CASE WHEN EQ_RND>V.[ActualValue] AND EQ_RND<= V.[ActualValue]+0.01 THEN 1 ELSE 0 END),
                                        OS_20MV=SUM(CASE WHEN EQ_RND>V.[ActualValue]+0.01 AND EQ_RND<= V.[ActualValue]+0.02 THEN 1 ELSE 0 END),
                                        OS_30MV=SUM(CASE WHEN EQ_RND>V.[ActualValue]+0.02 AND EQ_RND<= V.[ActualValue]+0.03 THEN 1 ELSE 0 END),
                                        OS_40MV=SUM(CASE WHEN EQ_RND>V.[ActualValue]+0.03 AND EQ_RND<= V.[ActualValue]+0.04 THEN 1 ELSE 0 END),
                                        OS_50MV=SUM(CASE WHEN EQ_RND>V.[ActualValue]+0.04 AND EQ_RND<= V.[ActualValue]+0.05 THEN 1 ELSE 0 END),
                                        OS_50PLUS=SUM(CASE WHEN EQ_RND>V.[ActualValue]+0.05  THEN 1 ELSE 0 END)
                           FROM #EQ_DATA E
                INNER JOIN ' + @TargetTable + ' V ON V.UnitID=E.UnitID
				INNER JOIN ' + @groupTable + ' T ON T.TestId = V.TestId
		WHERE V.GroupID='+cast(@GroupID as varchar(10))+'
                    GROUP BY V.testId
       ) E INNER JOIN ' + @groupTable + ' T ON T.testId=E.testId'
	   PRINT @SQLString+char(13)
       EXEC (@SQLString)

SET @SQLString = 'SELECT T.* FROM ' + @groupTable + ' T WHERE T.GroupID='+cast(@GroupID as varchar(10))
PRINT @SQLString
EXEC (@SQLString)

PRINT '********************************************'+char(13)


--*****************************************************************
SET @FailPoint=3 --TEST LEVL SUMMARY
       

       SET @SQLString = '
    MERGE ' + @groupTable + 'Summary AS target
    USING (SELECT GroupID, E.*,AVG_STEPS_WP,AVG_STEPS_NP,TTR	   	   
       FROM (SELECT CNT=COUNT(MAX_V),
                           OS_CNT=SUM(CASE WHEN EQ_RND > MAX_V THEN 1 ELSE 0 END),
                           OS_10MV=SUM(CASE WHEN EQ_RND>MAX_V AND EQ_RND<= MAX_V+0.01 THEN 1 ELSE 0 END),
                           OS_20MV=SUM(CASE WHEN EQ_RND>MAX_V+0.01 AND EQ_RND<= MAX_V+0.02 THEN 1 ELSE 0 END),
                           OS_30MV=SUM(CASE WHEN EQ_RND>MAX_V+0.02 AND EQ_RND<= MAX_V+0.03 THEN 1 ELSE 0 END),
                           OS_40MV=SUM(CASE WHEN EQ_RND>MAX_V+0.03 AND EQ_RND<= MAX_V+0.04 THEN 1 ELSE 0 END),
                           OS_50MV=SUM(CASE WHEN EQ_RND>MAX_V+0.04 AND EQ_RND<= MAX_V+0.05 THEN 1 ELSE 0 END),
                           OS_50PLUS=SUM(CASE WHEN EQ_RND>MAX_V+0.05  THEN 1 ELSE 0 END)
                    FROM #EQ_DATA )E
             CROSS JOIN (SELECT GroupID, AVG_STEPS_WP= SUM(AVG_STEPS_WP),
                                               AVG_STEPS_NP=SUM(AVG_STEPS_NP) ,
                                               TTR=SUM((AVG_STEPS_NP-AVG_STEPS_WP)*StepCost)
                                               FROM ' + @groupTable + ' 
											   WHERE GroupID='+cast(@GroupID as varchar(10))+'
											   GROUP BY GroupID) T) AS source (GroupID,CNT,OS_CNT,OS_10MV,OS_20MV,OS_30MV,OS_40MV,OS_50MV,OS_50PLUS,AVG_STEPS_WP,AVG_STEPS_NP,TTR)
    ON (target.GroupID = source.GroupID)
    WHEN MATCHED THEN 
        UPDATE SET CNT = source.CNT
		,OS_CNT = source.OS_CNT
		,OS_10MV = source.OS_10MV
		,OS_20MV = source.OS_20MV
		,OS_30MV = source.OS_30MV
		,OS_40MV = source.OS_40MV
		,OS_50MV = source.OS_50MV
		,OS_50PLUS = source.OS_50PLUS
		,AVG_STEPS_WP = source.AVG_STEPS_WP
		,AVG_STEPS_NP = source.AVG_STEPS_NP
		,TTR = source.TTR
	WHEN NOT MATCHED THEN	
	    INSERT (GroupID,CNT,OS_CNT,OS_10MV,OS_20MV,OS_30MV,OS_40MV,OS_50MV,OS_50PLUS,AVG_STEPS_WP,AVG_STEPS_NP,TTR)
	    VALUES (source.GroupID,source.CNT,source.OS_CNT,source.OS_10MV,source.OS_20MV,source.OS_30MV,source.OS_40MV,source.OS_50MV,source.OS_50PLUS,source.AVG_STEPS_WP,source.AVG_STEPS_NP,source.TTR);
	   '
       PRINT @SQLString
       EXEC (@SQLString)


SET @SQLString = 'SELECT T.* FROM ' + @groupTable + 'Summary T WHERE T.GroupID='+cast(@GroupID as varchar(10))
PRINT @SQLString
EXEC (@SQLString)



GO