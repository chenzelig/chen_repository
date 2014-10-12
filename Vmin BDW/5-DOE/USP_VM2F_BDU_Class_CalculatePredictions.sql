USE MPDExploration
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_CalculatePredictions]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_CalculatePredictions]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USP_VM2F_BDU_Class_CalculatePredictions]
 @UnitID BIGINT=NULL
,@groupTable  NVARCHAR(1000)
,@FlatTable NVARCHAR(1000)
,@Description BIT=0

AS

BEGIN TRY 

IF @Description=1
BEGIN
	PRINT('
	Purpose:
	--------
	Calculate Predictions for each unit in a group according to DFF data.


	Requirements:
	-------------
	* Midas results, TestData Tables.
	* Class Test table.
	')
	
	GOTO FINISH
END

---------------- variable Declarations --------------------------
DECLARE @Equation VARCHAR (MAX),@CMD VARCHAR(MAX),@Test sysname,@SQLString NVARCHAR(MAX),
             @DFF_LIST VARCHAR(MAX), @DFF_MISSING VARCHAR(MAX), @FailPoint VARCHAR(MAX), @GroupID INT,@FailMessage VARCHAR(MAX)

------------------ Configuration Validation -----------------------------

SET @FailPoint='1'
SET @FailMessage=NULL

---------------
IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @groupTable)
	SET @FailMessage=@groupTable+' Doesn''t Exist'

IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @FlatTable)
	SET @FailMessage=@FlatTable+' Doesn''t Exist'
-------------------

IF @FailMessage IS NOT NULL
	RAISERROR (@FailMessage, 16, 1) 

--------------- Create tables ----------------------
IF OBJECT_ID('tempdb..#EQ_DATA','U') IS NOT NULL
				DROP TABLE #EQ_DATA

IF OBJECT_ID('tempdb..#groups','U') IS NOT NULL
				DROP TABLE #groups

CREATE TABLE #groups (groupID INT)

CREATE TABLE #EQ_DATA (UnitID BIGINT, GroupID INT,Domain VARCHAR(10),Corner VARCHAR(10),Flow INT,EQ FLOAT,EQ_RND NUMERIC(18,6), DFF_Missing INT)    
	 
------------------------------------------------------
SET @SQLString='INSERT INTO  #Groups SELECT DISTINCT groupID FROM '+@groupTable
PRINT(@SQLString)
EXEC (@SQLString)

DECLARE CUROSOR_I1 CURSOR FOR 
SELECT DISTINCT GroupID 
FROM #groups

OPEN CUROSOR_I1

FETCH NEXT FROM CUROSOR_I1 INTO @GroupID

WHILE @@FETCH_STATUS=0
	BEGIN
		SET @Equation=NULL
		SET @CMD=NULL
		SET @Test =NULL
		SET @SQLString=NULL
        SET @DFF_LIST=NULL
		SET @DFF_MISSING=NULL

		SET @SQLString = 'select @Equation =  [Equation] + ''+-'' + cast(isnull(shift,0) as varchar(10))
		from  ' + @groupTable + ' where groupid = ' + cast(@GroupID as varchar)
		PRINT(@SQLString)+char(13)
		EXEC sp_executeSql @SQLString, N'@Equation NVARCHAR(max) OUTPUT', @Equation OUTPUT

		PRINT @Equation+char(13)
		PRINT '------------------------------------'+char(13)
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

		PRINT '------------------------------------'+char(13)
		-------------------------------------------------------------------

		SET @FailPoint=1 --get data for calculations
				--CREATE THE #EQUATIO UNIT LEVEL DATA
	               
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

       
		SET @CMD ='(SELECT unitID, GroupID ,Domain ,Corner ,Flow, '+CHAR(13)+
							@DFF_MISSING+CHAR(13)+
							+@DFF_LIST+'
		FROM ' + @FlatTable + ' A
		CROSS JOIN (SELECT DISTINCT GroupID,Domain,Corner,Flow FROM '+@groupTable+' WHERE GroupID='+CONVERT(VARCHAR(MAX),@GroupID)+') G
		CROSS JOIN '+@CMD+'
		WHERE UnitID='+CASE WHEN @UnitID IS NULL THEN 'unitID' ELSE +CONVERT(VARCHAR(MAX),@UnitID) END+')A'

		PRINT @CMD+char(13)

      
		SET @CMD='SELECT unitID, GroupID ,Domain ,Corner ,Flow,'+CHAR(13)+
					'EQ='+@Equation+','+CHAR(13)+
					'EQ_RND=NULL,'+CHAR(13)+
					'DFF_MISSING'+CHAR(13)+
					'FROM '+@CMD
       
		PRINT @CMD+char(13)
      
		INSERT INTO #EQ_DATA 
		EXEC (@CMD) 
 
		PRINT '**************** END OF group '+CONVERT(VARCHAR(MAX),@GroupID)+' Iteration****************************'+char(13)
		------------------------------------
		FETCH NEXT FROM CUROSOR_I1 INTO @GroupID
	END

CLOSE CUROSOR_I1
DEALLOCATE CUROSOR_I1

UPDATE #EQ_DATA SET EQ_RND=FLOOR(EQ*100)/100.0	 		

select E.UnitID,E.GroupID,E.Domain,E.Corner,E.Flow,F.Flow as [XML-Flow],E.[EQ_RND],E.DFF_Missing
from #EQ_DATA E
INNER JOIN  VM2F_BDU_Class_flows F
on E.flow=F.bin

FINISH:
END TRY

BEGIN CATCH  	
	PRINT ('Fail Point: '+ @FailPoint + ' - ' + ERROR_MESSAGE())
END CATCH 

GO
