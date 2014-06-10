USE MFG_Solutions
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_DataExtraction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_DataExtraction]

GO

/*******************************************************           
* Procedure:		[USP_DataExtraction]  
*                                                              
* Description:		Creating a table of configuration for each solution, model group and model that are in the data base
* 
* ----------------------------------------------------------     
*                                                                    
* Modification Log:                                            
* Date			Modified By			Modification:                         
* ----			-----------			--------------------         
* 2014-6-09		Gil Ben Shalom		Creating the SP 
*******************************************************/ 

CREATE PROCEDURE USP_DataExtraction

@ModelGroupID int

AS

BEGIN TRY
-------------------------------------------------------------------------
-- Declare Variables
-------------------------------------------------------------------------
DECLARE

@xmlQuery xml,
@SourceType VARCHAR(20),
@ConnUser varchar(50),
@ConnPass varchar(50),
@ServerName varchar(100),
@SerivceName varchar(200),
@PortNo int,
@QueryNum varchar(20),
@MinQueryNum varchar(20),
@ImportQuery varchar(max),
@CMD varchar(max),
@SQL varchar(max),
@ConnectionString varchar(1000),
@FailPoint int,
@StartTime datetime=GETUTCDATE(),
@EndTime datetime,
@ErrorMessage varchar(1000),
@ModelGroupName varchar(100),
@LogMessage varchar(1000),
@ConnectionType int

-------------------------------------------------------------------------
-- Taking all queries for this model group from the configurations and putting them in a temp table
-------------------------------------------------------------------------
Set @FailPoint=1

SET @ModelGroupName = (SELECT TOP 1 ModelGroupDescription FROM 
							[dbo].[GM_D_ModelGroups]
							WHERE ModelGroupID = @ModelGroupID)

CREATE TABLE #ImportQueries
(
 QueryNum varchar(20),
 Query varchar(max)
 )

 SELECT @xmlQuery = value
 FROM #ATM_GM_ModelingParameters
 WHERE ModelGroupID = @ModelGroupID
 AND ParameterID=1 --ParameterID 1 is the query template

INSERT INTO #ImportQueries (QueryNum,Query)
SELECT QueryNum=DS.value('(QueryNum)[1]','varchar(20)'),
	   Query=DS.value('(Query)[1]','varchar(max)')
from @xmlQuery.nodes('Queries/Row') T(DS)

SET @MinQueryNum=(SELECT min(QueryNum)FROM #ImportQueries)

-------------------------------------------------------------------------
-- Taking all openrowset details from the configuration table
-------------------------------------------------------------------------
Set @FailPoint=2

SELECT @SourceType = C.SourceType, @ServerName = C.ServerName, 
	@ConnUser = C.ConnUser, @ConnPass = C.ConnPass, @PortNo=C.PortNo,@ConnectionString=ConnectionString 
FROM [dbo].[GM_D_DE_Connections] C
WHERE ConnectionId = (SELECT Convert(int,max(Value)) from  #ATM_GM_ModelingParameters
						WHERE ModelGroupID = @ModelGroupID
						AND ParameterID = 2 )--ParameterID 2 is the connectionID

-------------------------------------------------------------------------
-- Creating a table with columns names and data type for #ATM_GM_RawData table, using the query data
-------------------------------------------------------------------------

CREATE TABLE #AddColumns (name varchar(256),DataType varchar(256),max_length int,precision int)

-------------------------------------------------------------------------
-- This loop is executing all queries for this model group and fills #ATM_GM_RawData table
-------------------------------------------------------------------------

WHILE EXISTS(SELECT 1 FROM #ImportQueries)
BEGIN

Set @FailPoint=3

	SET @QueryNum= (SELECT min(QueryNum)
						FROM #ImportQueries)
	
	SET @ImportQuery = (SELECT Query
					FROM #ImportQueries WHERE  QueryNum = @QueryNum)

	SET @ImportQuery = REPLACE(@ImportQuery,'''','''''')

	Print (@ImportQuery)

	SET @ConnectionType= (SELECT Convert(int,max(Value)) from  #ATM_GM_ModelingParameters
						WHERE ModelGroupID = @ModelGroupID
						AND ParameterID = 6) -- Parameter 6 is the connection type 

	IF @ConnectionType=1 --Connection by credentials
	BEGIN
Set @FailPoint=4
		IF @QueryNum = @MinQueryNum --Means we need to create the schema of the table
		BEGIN
			
			SELECT @CMD = 'ALTER TABLE #ATM_GM_RawData ADD '+MAX(Value)
			FROM #ATM_GM_ModelingParameters
			WHERE ModelGroupID = @ModelGroupID
			and ParameterId=7 -- Parameter 7 is Raw Data Attributes

			PRINT(@CMD)
			EXEC(@CMD)

			ALTER TABLE #ATM_GM_RawData
			DROP COLUMN Dummy
		END
Set @FailPoint=5
		SET @CMD = 'EXEC [AdvancedBIsystem].[dbo].[USP_VM2F_ImportDataFromMIDAS] @sqlCommand='''+@ImportQuery+''',@password=''b3563823-f1ae-40c6-b236-deaa478c873a'' , @receiveTimeout=5000000, 
		@module=''iBI''' ---TO DO!!!! Change the "iBI" to be configurable. In the Vmin solution we will use the exact same connection with a different @module

		PRINT('INSERT INTO #ATM_GM_RawData'+char(13)+@CMD)

		INSERT INTO #ATM_GM_RawData
		EXEC(@CMD)
				
	END
	ELSE --Connection by OpenRowSet
	BEGIN
Set @FailPoint=6
		IF @QueryNum = @MinQueryNum ---TO DO!!!! find a better soulution for this
		BEGIN

				SET @CMD = '  
						SELECT * INTO #T FROM
						(SELECT  *
						FROM OPENROWSET('''+@SourceType+''','''+@ConnectionString+''',''' + @ImportQuery + '''
									) A ) B
					
					
						INSERT INTO #AddColumns			
						SELECT c.name,y.name DataType,c.max_length,c.precision
						FROM tempdb.sys.tables t
							INNER JOIN tempdb.sys.columns c
							   ON t.object_id=c.object_id
							INNER JOIN tempdb.sys.types y
							   ON     c.user_type_id=y.user_type_id
									  AND t.object_id=OBJECT_ID(''tempdb..#T'')

								DECLARE @SQL varchar(max)=NULL
								SELECT @SQL=ISNULL(@SQL+'','','''')+ ''[''+name+''] ''+ CASE WHEN DataType=''text'' then ''varchar'' else DataType END + case when DataType in (''varchar'',''text'') then ''(''+case when max_length=-1 then ''max'' else convert(varchar(max),CASE WHEN max_Length<4000 then 2*max_length else ''max'' end) end+'')''
																																						when  DataType= ''numeric'' then ''(''+convert(varchar(max),max_length)+'',''+convert(varchar(max),precision)+'')''
																																						else '''' end
								FROM #AddColumns

								SET @SQL=''ALTER TABLE #ATM_GM_RawData
								ADD ''+@SQL


								PRINT(@SQL)
								EXEC(@SQL)

								ALTER TABLE #ATM_GM_RawData
								DROP COLUMN Dummy

								INSERT INTO #ATM_GM_RawData
								SELECT * FROM #T
						'
		END

		ELSE BEGIN
Set @FailPoint=7
			SET @CMD = '  
						INSERT INTO #ATM_GM_RawData  
						SELECT  *
						FROM OPENROWSET('''+@SourceType+''','''+@ConnectionString+''',''' + @ImportQuery + '''
									) A' 
		END

		PRINT(@CMD)
		EXEC(@CMD)
	END

DELETE FROM #ImportQueries WHERE QueryNum = @QueryNum
		
END ----END of QueryLoop

SET @EndTime = GETUTCDATE()
SET @LogMessage = 'Sucsses'
EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_DataExtraction', @SectionName=@ModelGroupName,
						@EngineName = 'MFG_Solutions', @ModuleName = 'DataExtraction', @LogEventMessage = @LogMessage, 
						@StartDate = @StartTime, @EndDate = @EndTime, @LogEventType = 'I'	

END TRY

BEGIN CATCH

SET @ErrorMessage = 'Fail Point: ' + CONVERT(VARCHAR(3), @FailPoint) + ERROR_MESSAGE()
EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_DataExtraction', @EngineName = 'MFG_Solutions', 
						@ModuleName = 'DataExtraction', @LogEventMessage = @ErrorMessage, @LogEventType = 'E' 
RAISERROR (N'USP_EASY_CalculateMonitors::FailPoint- %d ERR-%s', 16,1, @FailPoint, @ErrorMessage)

END CATCH
