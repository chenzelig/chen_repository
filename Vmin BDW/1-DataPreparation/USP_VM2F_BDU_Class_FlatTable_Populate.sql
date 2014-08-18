USE [MPDExploration]
GO

/****** Object:  StoredProcedure [dbo].[USP_VM2F_BDU_Class_FlatTable_Populate]    Script Date: 7/24/2014 3:11:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[USP_VM2F_BDU_Class_FlatTable_Populate]  

 @SourcePrefix NVARCHAR(1000)

,@TargetTable NVARCHAR(1000)

,@groupTable NVARCHAR(1000)

,@FlatTable NVARCHAR(1000)

,@ProductID int



AS

DECLARE @ColumnList1 varchar(max) = '', @ColumnList2 varchar(max) = '', @ColumnList3 varchar(max) = '', 
@ColumnListPivot varchar(max) = '', @TrainColumnListPivot varchar(max) = '',
@finalColumnList1 varchar(max) = '', @finalColumnList2 varchar(max) = '', @TrainFinalColumnList varchar(max) = ''

DECLARE @SQLString NVARCHAR(max) = 
'SELECT @columnList1 = @columnList1 + 
'',max(CASE WHEN source.partitionkey = '' + cast(testTable.partitionkey as varchar(10)) + '' THEN '' + testTable.partitionColumn + '' END) as '' + testTable.TestName ,
@finalColumnList1 = @finalColumnList1 + '','' + testTable.TestName
FROM ' + @SourcePrefix + '_TestData testTable
WHERE testTable.TestName like ''DFF%'''

PRINT(@SQLString)

EXEC sp_executeSql @SQLString, N'@ColumnList1 NVARCHAR(max) OUTPUT, @finalColumnList1 NVARCHAR(max) OUTPUT', @ColumnList1 OUTPUT, @finalColumnList1 OUTPUT

 
PRINT char(13)+'********************'
print char(13)+@columnList1
PRINT char(13)+'********************'
----------------------------------------------------------------
SET @SQLString = 'SELECT @columnList2 = @columnList2 +  ''['' +  cast( groupid as varchar(10))  + ''],'',
@columnList3 = @columnList3 +  ''[_'' +  cast( groupid as varchar(10))  + ''],'',
@ColumnListPivot = @ColumnListPivot +  '',max([''+ cast( groupid as varchar(10)) +'']) as '' + groupName ,
@finalColumnList2 = @finalColumnList2 + '','' + groupName,
@TrainColumnListPivot = @TrainColumnListPivot +  '',max([_''+ cast( groupid as varchar(10)) +'']) as IsTrain'' + groupName ,
@TrainFinalColumnList = @TrainFinalColumnList + '',IsTrain'' +groupName
FROM (
SELECT distinct a.groupid, ''max_''+ rtrim(ltrim([Domain])) +''_''+ rtrim(ltrim([Corner])) +''_''+ rtrim(ltrim([Flow])) groupName
FROM ' + @TargetTable + ' a
inner join ' + @groupTable + ' b on a.groupid = b.groupid) T'

PRINT(@SQLString)
EXEC sp_executeSql @SQLString, N'@ColumnList2 NVARCHAR(max) OUTPUT,@ColumnList3 NVARCHAR(max) OUTPUT, @finalColumnList2 NVARCHAR(max) OUTPUT, @ColumnListPivot NVARCHAR(max) OUTPUT
, @TrainFinalColumnList NVARCHAR(max) OUTPUT, @TrainColumnListPivot NVARCHAR(max) OUTPUT',@ColumnList2 OUTPUT, @ColumnList3 OUTPUT, @finalColumnList2 OUTPUT, @ColumnListPivot OUTPUT, @TrainFinalColumnList OUTPUT, @TrainColumnListPivot OUTPUT

SET @columnList2 = substring(@columnList2,1,len(@columnList2)-1)
SET @columnList3 = substring(@columnList3,1,len(@columnList3)-1)

PRINT char(13)+'********************'
print @columnList2
print @columnList3
PRINT @ColumnListPivot
PRINT @finalColumnList2
PRINT @TrainColumnListPivot
print @TrainFinalColumnList
PRINT char(13)+'********************'
-------------------------------------------------------------------------
SET @SQLString ='SELECT '+ cast(@ProductID as varchar(10)) +' ProductID,  source.[Assembled_Unit_Seq_Key]'+CHAR(13)
+ @columnList1 + 
' INTO ' + @FlatTable + '_TEMP1
 FROM ' + @SourcePrefix + '_Results_Float source 
GROUP BY source.[Assembled_Unit_Seq_Key]'

PRINT(@SQLString)+char(13)+'************************************'
EXEC(@SQLString)
--------------------------------------------------------------------------------------------------------
SET @SQLString ='CREATE NONCLUSTERED INDEX [cl' + @FlatTable + '_TEMP111] ON ' + @FlatTable + '_TEMP1
(
	[Assembled_Unit_Seq_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
'

PRINT(@SQLString)+char(13)+'************************************'
EXEC(@SQLString)
----------------------------------------------------------------------------------------------------------------
SET @SQLString ='SELECT ProductID	,UnitID' + @ColumnListPivot + @TrainColumnListPivot + '
INTO ' + @FlatTable + '_TEMP2
FROM (
SELECT *, ''_'' + cast(groupid as varchar(10)) groupid2
FROM ' + @TargetTable + '
) T
PIVOT
(
AVG(maxValue)
FOR GroupId IN (' + @ColumnList2 + ')
) AS PivotTable1
PIVOT
(
AVG(isTrain)
FOR GroupId2 IN (' + @ColumnList3 + ')
) AS PivotTable2
group by ProductID	,UnitID'

PRINT(@SQLString)+char(13)+'************************************'
EXEC(@SQLString)

----------------------------------------------------------------------------------------------------
SET @SQLString ='CREATE NONCLUSTERED INDEX [cl' + @FlatTable + '_TEMP211] ON ' + @FlatTable + '_TEMP2
(
	[unitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
'

PRINT(@SQLString)+char(13)+'************************************'
EXEC(@SQLString)
---------------------------------------------------------------------------------------------------------------------------
SET @SQLString ='
SELECT T1.ProductID,UnitID ' + @finalColumnList1 +  @finalColumnList2 + @TrainfinalColumnList + '
INTO ' + @FlatTable + '
FROM ' + @FlatTable + '_TEMP1 T1
RIGHT JOIN ' + @FlatTable + '_TEMP2 T2
ON T1.Assembled_Unit_Seq_Key = T2.UnitID'

PRINT(@SQLString)+char(13)+'************************************'
EXEC(@SQLString)
------------------------------------------------------------------------------------------------------------------------------------
SET @SQLString ='DROP TABLE ' + @FlatTable + '_TEMP1
DROP TABLE ' + @FlatTable + '_TEMP2'

PRINT(@SQLString)+char(13)+'************************************'
EXEC(@SQLString)

GO


