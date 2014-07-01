USE MFG_Solutions
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_GM_DataExtraction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_GM_DataExtraction]


GO

/*******************************************************           
* Procedure:		[USP_GM_DataExtraction]  
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

CREATE PROCEDURE USP_GM_DataExtraction

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
@ConnPass varchar(1000),
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
@LogMessage varchar(max),
@ConnectionType int,
@Module VARCHAR(20),
@ConnectionID int,
@i int,
@DistributionField varchar(1000),
@NumDistributionGroups int

-------------------------------------------------------------------------
-- Taking all queries for this model group from the configurations and putting them in a temp table
-------------------------------------------------------------------------
Set @FailPoint=1

SET @ModelGroupName = (SELECT TOP 1 ModelGroupDescription FROM 
							[dbo].[GM_D_ModelGroups]
							WHERE ModelGroupID = @ModelGroupID)

CREATE TABLE #ImportQueries(
	 QueryNum int,
	 ConnectionID int,
	 Query varchar(max),
	 DistributionField varchar(1000),
	 NumDistributionGroups int
)

SELECT @xmlQuery = value
FROM #ATM_GM_ModelingParameters
WHERE ModelGroupID = @ModelGroupID
 AND ParameterID=1 --ParameterID 1 is the query template

INSERT INTO #ImportQueries(QueryNum,ConnectionID,Query,DistributionField,NumDistributionGroups)
SELECT QueryNum=DS.value('(QueryNum)[1]','int'),
	   ConnectionID=DS.value('(ConnectionID)[1]','int'),
	   Query=DS.value('(Query)[1]','varchar(max)'),
	   DistributionField=DS.value('(DistributionField)[1]','varchar(100)'),
	   NumDistributionGroups=DS.value('(NumDistributionGroups)[1]','int')
FROM @xmlQuery.nodes('Queries/Row') T(DS)

SET @MinQueryNum=(SELECT MIN(QueryNum)FROM #ImportQueries)

Set @FailPoint=2
----------------------------------------------------------------------------------------------------------------------------
-- Creating a table with columns names and data type for adaptation of #ATM_GM_RawData table schema, using the query data
----------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #AddColumns (name varchar(256),DataType varchar(256),max_length int,precision int)

-------------------------------------------------------------------------------------------
-- This loop is executing all queries for this model group and fills #ATM_GM_RawData table
-------------------------------------------------------------------------------------------

WHILE EXISTS(SELECT 1 FROM #ImportQueries)
BEGIN

Set @FailPoint=3

	SET @QueryNum= (SELECT MIN(QueryNum) FROM #ImportQueries)
	
	--Get the query and connection details
	SELECT @ImportQuery = REPLACE(I.Query,'''',''''''),
		   @ConnectionID = I.ConnectionID,
		   @ConnectionType = C.ConnectionTypeID,
		   @DistributionField = ISNULL(I.DistributionField,'1'),
		   @NumDistributionGroups = ISNULL(I.NumDistributionGroups,1)
	FROM #ImportQueries I
	INNER JOIN [dbo].[GM_D_DE_Connections](nolock) C
	ON I.ConnectionID=C.ConnectionID
	WHERE QueryNum = @QueryNum
	
	--Print (@ImportQuery)

	IF @ConnectionType=2 --Connection by credentials
	BEGIN

		Set @FailPoint=4
		IF @QueryNum = @MinQueryNum --Means we need to create the schema of the table
		BEGIN
			
			SELECT @CMD = 'ALTER TABLE #ATM_GM_RawData ADD '+MAX(Value)
			FROM #ATM_GM_ModelingParameters
			WHERE ModelGroupID = @ModelGroupID
			and ParameterId=7 -- Parameter 7 is the Raw Data table schema

			--PRINT(@CMD)
			EXEC(@CMD)
			
			--Dropping the dummy column from the table
			ALTER TABLE #ATM_GM_RawData
			DROP COLUMN Dummy
		END

		Set @FailPoint=5

		-------------------------------------------------------------------------------------
		-- Taking all relevant details for credentials connection from the connections table
		-------------------------------------------------------------------------------------
		SELECT @Module = Module,	
			   @ConnPass = convert(varchar(1000),DecryptByPassPhrase('select',ConnPass))
		FROM [dbo].[GM_D_DE_Connections]
		WHERE ConnectionId = @ConnectionID

		--split the import into @NumDistributionGroups batches
		SET @i=0
		WHILE @i<@NumDistributionGroups
		BEGIN
			SET @CMD = 'EXEC [AdvancedBIsystem].[dbo].[USP_VM2F_ImportDataFromMIDAS] @sqlCommand=''select * from('+@ImportQuery+')Q where '+@DistributionField+'%'+convert(varchar(max),@NumDistributionGroups)+'='+convert(varchar(max),@i)+''',@password='''+@ConnPass+''' , @receiveTimeout=50000000, 
			@module='''+@Module+'''' + ',@numTries=1'

			--PRINT (@CMD)

			INSERT INTO #ATM_GM_RawData
			EXEC(@CMD)
			SELECT @LogMessage = ISNULL(@LogMessage+', ','brought ')+convert(varchar(1000),@@ROWCOUNT)+' rows for QueryNum '+convert(varchar(1000),@QueryNum)+' batch no.'+convert(varchar(1000),@i)
			
			SET @i=@i+1
		END
	END
	
	ELSE --Connection by OpenRowSet
	BEGIN
		Set @FailPoint=6
		-------------------------------------------------------------------------
		-- Taking all openrowset details from the connections table
		-------------------------------------------------------------------------
		SELECT @SourceType = SourceType, 
			   @ServerName = ServerName, 
			   @ConnUser = ConnUser, 
			   @ConnPass = ConnPass, 
			   @PortNo = PortNo,
			   @ConnectionString = ConnectionString 
		FROM [dbo].[GM_D_DE_Connections]
		WHERE ConnectionId = @ConnectionID

		IF @QueryNum = @MinQueryNum
		BEGIN

				SET @CMD = '  
						SELECT *
						INTO #T
						FROM OPENROWSET('''+@SourceType+''','''+@ConnectionString+''',''' + @ImportQuery + ''') 
					
						--get all the details for the columns needed to add to the table
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


								--PRINT(@SQL)
								EXEC(@SQL)

								--Dropping the dummy column from the table
								ALTER TABLE #ATM_GM_RawData
								DROP COLUMN Dummy
								
								INSERT INTO #ATM_GM_RawData
								SELECT * FROM #T
						'				

		END

		ELSE BEGIN -- #ATM_GM_RawData table is already in the expected schema

			Set @FailPoint=7
			SET @CMD = '  
						INSERT INTO #ATM_GM_RawData  
						SELECT  *
						FROM OPENROWSET('''+@SourceType+''','''+@ConnectionString+''',''' + @ImportQuery + ''')' 
		END

		--PRINT(@CMD)
		EXEC(@CMD)
		SELECT @LogMessage = ISNULL(@LogMessage+', ','brought ')+convert(varchar(1000),@@ROWCOUNT)+' rows for QueryNum '+convert(varchar(1000),@QueryNum)
	END

DELETE FROM #ImportQueries WHERE QueryNum = @QueryNum
		
END ----END of QueryLoop

SET @EndTime = GETUTCDATE()
SET @LogMessage = 'Sucssesfully '+@LogMessage
EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_DataExtraction', @SectionName=@ModelGroupName,
						@EngineName = 'MFG_Solutions', @ModuleName = 'DataExtraction', @LogEventMessage = @LogMessage, 
						@StartDate = @StartTime, @EndDate = @EndTime, @LogEventType = 'I'	

END TRY

BEGIN CATCH

SET @ErrorMessage = 'Fail Point: ' + CONVERT(VARCHAR(3), @FailPoint) +' '+ ERROR_MESSAGE()
EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_DataExtraction', @EngineName = 'MFG_Solutions', 
						@ModuleName = 'DataExtraction', @LogEventMessage = @ErrorMessage, @LogEventType = 'E' 
RAISERROR (N'USP_GM_DataExtraction::FailPoint- %d ERR-%s', 16,1, @FailPoint, @ErrorMessage)

END CATCH
