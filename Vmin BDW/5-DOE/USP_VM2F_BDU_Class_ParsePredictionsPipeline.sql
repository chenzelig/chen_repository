USE MPDExploration
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_ParsePredictionsPipeline]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_ParsePredictionsPipeline]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USP_VM2F_BDU_Class_ParsePredictionsPipeline]
	 @Prefix VARCHAR(MAX)
	,@UnitID BIGINT=NULL
	,@IgnoredValues VARCHAR(MAX)=NULL
	,@Description BIT=0
AS

BEGIN TRY 

------------------ Description --------------------------------
IF @Description=1
BEGIN
	PRINT('
	Purpose:
	--------
	Parse Vmin Predictions data (from Results_String) recived from the experiment. 


	Requirements:
	-------------
	* Midas Results_String, TestData
	')
	
	GOTO FINISH
END

------------------ Variable Declaration --------------------------------
DECLARE @SQL VARCHAR(MAX)
   	   ,@FailPoint  VARCHAR(MAX)
	   ,@FailMessage VARCHAR(MAX)
	   ,@IgnoredValuesString VARCHAR(MAX)=NULL

------------------ Configuration Validation ----------------------

SET @FailPoint='1'
SET @FailMessage=NULL

IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @Prefix+'_Results_String')
	SET @FailMessage=@Prefix+'_Results_String Doesn''t Exist'

IF NOT EXISTS(SELECT TOP 1 * FROM sys.tables where name like @Prefix+'_TestData')
	SET @FailMessage=@Prefix+'_TestData Doesn''t Exist'

IF @FailMessage IS NOT NULL
	RAISERROR (@FailMessage, 16, 1)

----------------- Set Ignored Values ------------------------

SELECT @IgnoredValuesString=ISNULL(@IgnoredValuesString,'')+'AND value NOT LIKE '''+Value+''''+CHAR(13)
FROM UDF_GetStringTableFromList_New(@IgnoredValues,',',null)

print @IgnoredValuesString
----------------- Parse predictions -----------------------------
SET @SQL='
SELECT *
FROM 
	(SELECT 
		 Assembled_Unit_Seq_Key
		,UNPVT.PartitionKey
		,PartitionColoumn
		,TD.testName
		,val
		,Value
		,place
		,Result=CONVERT(FLOAT,CASE WHEN isnumeric(value)=1 THEN VALUE
								WHEN  value LIKE ''%:'' THEN NULL
								WHEN value LIKE ''%:%'' THEN substring(value,CHARINDEX('':'',value)+1,LEN(value)-CHARINDEX('':'',value))
								ELSE NULL END)
	FROM ['+@Prefix+'_Results_String]
	UNPIVOT 
	(val FOR PartitionColoumn IN(
			col0,col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,col21,col22,col23,col24,col25,col26
			,col27,col28,col29,col30,col31,col32,col33,col34,col35,col36,col37,col38,col39,col40,col41,col42,col43,col44,col45,col46,col47,col48,col49,col50,col51,col52
			,col53,col54,col55,col56,col57,col58,col59,col60,col61,col62,col63,col64,col65,col66,col67,col68,col69,col70,col71,col72,col73,col74,col75,col76,col77,col78
			,col79,col80,col81,col82,col83,col84,col85,col86,col87,col88,col89,col90,col91,col92,col93,col94,col95,col96,col97,col98,col99,col100,col101,col102,col103,col104
			,col105,col106,col107,col108,col109,col110,col111,col112,col113,col114,col115,col116,col117,col118,col119,col120,col121,col122,col123,col124,col125,col126,col127,col128
			,col129,col130,col131,col132,col133,col134,col135,col136,col137,col138,col139,col140,col141,col142,col143,col144,col145,col146,col147,col148,col149,col150
			,col151,col152,col153,col154,col155,col156,col157,col158,col159,col160,col161,col162,col163,col164,col165,col166,col167,col168,col169,col170,col171,col172
			,col173,col174,col175,col176,col177,col178,col179,col180,col181,col182,col183,col184,col185,col186,col187,col188,col189,col190,col191,col192,col193,col194
			,col195,col196,col197,col198,col199)
			) AS UNPVT 
	INNER JOIN ['+@Prefix+'_TestData] TD
	ON TD.partitionKey=UNPVT.partitionKey
	AND TD.partitionColumn=UNPVT.PartitionColoumn
	CROSS APPLY UDF_GetStringTableFromList_New(val,''|'',null)
	WHERE 1=1
	AND UNPVT.PartitionKey=0
	AND PartitionColoumn in (SELECT partitionColumn FROM ['+@Prefix+'_TestData] WHERE TestName LIKE ''DFF_%'' )
	AND TD.colTypeId=(SELECT TOP 1 colTypeId FROM  ['+@Prefix+'_TestData] WHERE TestName LIKE ''DFF_%'')
	'+ISNULL(@IgnoredValuesString,'')+'
	) Res1
WHERE 1=1
AND Res1.Result  IS NOT NULL
AND Res1.Assembled_Unit_Seq_Key='+CASE WHEN @UnitID IS NULL THEN 'Res1.Assembled_Unit_Seq_Key' ELSE CONVERT(varchar(MAX),@UnitID) END+'
ORDER BY  Assembled_Unit_Seq_Key,TestName
'

Print(@SQL)
EXEC(@SQL)

FINISH:
END TRY

BEGIN CATCH  	
	PRINT ('Fail Point: '+ @FailPoint + ' - ' + ERROR_MESSAGE())
END CATCH 

GO





