	
USE MPDExploration
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_EvaluationWrapper]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_EvaluationWrapper]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------

CREATE PROCEDURE USP_VM2F_BDU_Class_EvaluationWrapper @Prefix VARCHAR(MAX)

AS 

BEGIN TRY 


---------------------------------------- create a summary table -------------------------------------

IF OBJECT_ID (N'[MPDExploration]..'+@Prefix+'_ClassTestsSummary', N'U') IS NOT NULL
BEGIN
	SET @SQL='DROP TABLE [MPDExploration]..'+@Prefix+'_ClassTestsSummary;'+CHAR(13)
	PRINT(@SQL)
	EXEC(@SQL)
END

SET @SQL='
SELECT TOP 0 GroupID,CNT,OS_CNT,OS_10MV,OS_20MV,OS_30MV,OS_40MV,OS_50MV,OS_50PLUS,AVG_STEPS_WP,AVG_STEPS_NP,TTR
INTO '+@Prefix+'_ClassTestsSummary
FROM '+@Prefix+'_ClassTests'+CHAR(13)

PRINT(@SQL)
EXEC(@SQL)

-------------------------------------------- Evalutaion ------------------------------------------------

DECLARE @currentGroupID int

DECLARE GroupCursor CURSOR FORWARD_ONLY  READ_ONLY 
     FOR select distinct GroupID from VM2F_BDU_Class_UT_ClassTests order by GroupID 

OPEN GroupCursor

FETCH NEXT FROM GroupCursor 
INTO @currentGroupID

WHILE @@FETCH_STATUS = 0
BEGIN

	Print '------------- START: group-'+@currentGroupID+' --------------------'+CHAR(13)
	EXEC [dbo].[USP_VM2F_BDU_Class_Evaluation]  
	 @GroupID = @currentGroupID
	,@groupTable = @Prefix+'_ClassTests'
	,@TargetTable  = @Prefix+'_Target_Values'
	,@FlatTable =@Prefix+'_FLat_Table'

	FETCH NEXT FROM GroupCursor 
	INTO @currentGroupID

	Print '------------- FINISH: group-'+@currentGroupID+' --------------------'+CHAR(13)
END 

CLOSE GroupCursor;
DEALLOCATE GroupCursor;

END TRY
BEGIN CATCH  	
	PRINT (ERROR_MESSAGE())
END CATCH 
GO
