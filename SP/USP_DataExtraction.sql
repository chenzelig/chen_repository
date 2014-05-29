ALTER PROCEDURE USP_DataExtraction

@SolutionID int,
@ModelGroupID int

AS


-------------------------------------------------------------------------
-- Declare Variables
-------------------------------------------------------------------------
DECLARE

@xmlQuery xml, @SourceType VARCHAR(20), @ConnUser varchar(50),@ConnPass varchar(50),@ServerName varchar(100),@SerivceName varchar(200),@PortNo int,@QueryNum varchar(20),@ImportQuery varchar(max),@CMD varchar(max),@SQL varchar(max)

-------------------------------------------------------------------------
-- Taking all queries for this model group from the configurations and putting them in a temp table
-------------------------------------------------------------------------

CREATE TABLE #ImportQueries
(
 QueryNum varchar(20),
 Query varchar(max)
 )

 SELECT @xmlQuery = value
 FROM
 #ATM_GM_ModelingParameters
 WHERE SolutionID=@SolutionID
 AND ModelGroupID = @ModelGroupID
 AND ParameterID=1 --ParameterID 1 is the query template

INSERT INTO #ImportQueries (QueryNum,Query)
SELECT QueryNum=DS.value('(QueryNum)[1]','varchar(20)'),
Query=DS.value('(Query)[1]','varchar(max)')
from @xmlQuery.nodes('Queries/Row') T(DS)

-------------------------------------------------------------------------
-- Taking all openrowset details from the configuration table
-------------------------------------------------------------------------

SELECT @SourceType = C.SourceType, @ServerName = C.ServerName, 
	@ConnUser = C.ConnUser, @ConnPass = C.ConnPass, @PortNo=C.PortNo --@ExecQuery = I.ExecQuery,
--	,@ParametersDomainID = ParametersDomainID, @ProcessID = I.ProcessID,
FROM [dbo].[GM_D_DE_Connections] C
WHERE ConnectionId = (SELECT Convert(int,max(Value)) from  #ATM_GM_ModelingParameters
						WHERE SolutionID = @SolutionID
						AND ModelGroupID = @ModelGroupID
						AND ParameterID = 2 )--ParameterID 2 is the connectionID )

-------------------------------------------------------------------------
-- Creating a table with columns names and data type for #ATM_GM_RawData table, using the query data
-------------------------------------------------------------------------

CREATE TABLE #AddColumns (name varchar(256),DataType varchar(256),max_length int,precision int)

-------------------------------------------------------------------------
-- This loop is executing all queries for this model group and fills #ATM_GM_RawData table
-------------------------------------------------------------------------

WHILE EXISTS(SELECT 1 FROM #ImportQueries)
BEGIN

	SET @QueryNum= (SELECT min(QueryNum)
						FROM #ImportQueries)
	
	SET @ImportQuery = (SELECT Query
					FROM #ImportQueries WHERE  QueryNum = @QueryNum)

	SET @ImportQuery = REPLACE(@ImportQuery,'''','''''')

	SELECT @queryNum

	Print (@ImportQuery)

	IF @QueryNum like '%1%' ---TO DO!!!! find a better soulution for this
	BEGIN
		
		SET @CMD = '  
					SELECT * INTO #T FROM
					(SELECT  *
					FROM OPENROWSET('''+@SourceType+''',''' + @ServerName +','+CAST(@PortNo AS VARCHAR(20))+''';''' + @ConnUser +''';'''+ @ConnPass + ''',''' + @ImportQuery + '''
								) A ) B'
	END

	ELSE BEGIN

		SET @CMD = '  
					INSERT INTO #ATM_GM_RawData  
					SELECT  *
					FROM OPENROWSET('''+@SourceType+''',''' + @ServerName +','+CAST(@PortNo AS VARCHAR(20))+''';''' + @ConnUser +''';'''+ @ConnPass + ''',''' + @ImportQuery + '''
								) A' 
	END

	PRINT(@CMD)
--	EXEC(@CMD)

	IF @QueryNum like '%1%'
	BEGIN
		
		SET @SQL = 'SELECT c.name,y.name DataType,c.max_length,c.precision
					FROM tempdb.sys.tables t
						INNER JOIN tempdb.sys.columns c
						   ON t.object_id=c.object_id
						INNER JOIN tempdb.sys.types y
						   ON     c.user_type_id=y.user_type_id
							      AND t.object_id=OBJECT_ID(''tempdb..#T'')
								'

		PRINT(@SQL)

	--	INSERT INTO #AddColumns
	--	EXEC(@SQL)
		
		SET @SQL=NULL
		SELECT @SQL=ISNULL(@SQL+',','')+ '['+name+'] '+DataType+ case DataType when 'varchar' then '('+case when max_length=-1 then 'max' else convert(varchar(max),max_length) end+')'
																																when 'numeric' then '('+convert(varchar(max),max_length)+','+convert(varchar(max),precision)+')'
																																else '' end
		FROM #AddColumns

		SET @SQL='ALTER TABLE #ATM_GM_RawData
		ADD '+@SQL


		PRINT(@SQL)
	--	EXEC(@SQL)

	--	ALTER TABLE #ATM_GM_RawData
	--	DROP COLUMN Dummy

	--	INSERT INTO #ATM_GM_RawData
	--	SELECT * FROM #T

	END -- End of Query = 1

DELETE FROM #ImportQueries WHERE QueryNum = @QueryNum
		
END ----END of QueryLoop
