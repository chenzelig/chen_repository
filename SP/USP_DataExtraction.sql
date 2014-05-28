CREATE PROCEDURE USP_DataExtraction

@SolutionID int,
@ModelGroupID int

AS
-------------------------------------------------------------------------
-- Declare Variables
-------------------------------------------------------------------------
DECLARE

@xmlQuery xml

-------------------------------------------------------------------------
-- Taking all queries for this model group from the configurations and putting them in a table
-------------------------------------------------------------------------

CREATE TABLE #ImportQueries
(
 QueryNum varchar(20),
 Query varchar(max),
 Done BIT Default 0
 )

 SELECT @xmlQuery = value
 FROM
 #GM_ModelingParametes
 WHERE SolutionID=@SolutionID
 AND ModelGroupID = @ModelGroupID
 AND ParmeterID=1 --ParameterID 1 is the query template

INSERT INTO #ImportQueries (QueryNum,Query)
SELECT QueryNum=DS.value('(QueryNum)[1]','varchar(20)'),
Query=DS.value('(Query)[1]','varchar(max)')
from @xmlQuery.nodes('Queries/Row') T(DS)



CREATE TABLE #local_input_table (Dummy int)
CREATE TABLE #AddColumns (name varchar(256),DataType varchar(256),max_length int,precision int)
       
set @SQL='
select top 1000 *
into #T
from '+@InputTable+'

SELECT c.name,y.name DataType,c.max_length,c.precision
FROM tempdb.sys.tables t
INNER JOIN tempdb.sys.columns c
       ON t.object_id=c.object_id
INNER JOIN tempdb.sys.types y
       ON     c.user_type_id=y.user_type_id
              AND t.object_id=OBJECT_ID(''tempdb..#T'')
'

INSERT INTO #AddColumns
EXEC(@SQL)


SET @SQL=NULL
SELECT @SQL=ISNULL(@SQL+',','')+ '['+name+'] '+DataType+ case DataType when 'varchar' then '('+case when max_length=-1 then 'max' else convert(varchar(max),max_length) end+')'
                                                                                                                        when 'numeric' then '('+convert(varchar(max),max_length)+','+convert(varchar(max),precision)+')'
                                                                                                                        else '' end
FROM #AddColumns

SET @SQL='ALTER TABLE #local_input_table
ADD '+@SQL
EXEC(@SQL)

ALTER TABLE #local_input_table
DROP COLUMN Dummy
