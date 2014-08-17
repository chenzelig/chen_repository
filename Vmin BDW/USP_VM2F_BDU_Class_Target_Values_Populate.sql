USE [MPDExploration]
GO

/****** Object:  StoredProcedure [dbo].[USP_VM2F_BDU_Class_Target_Values_Populate]    Script Date: 7/24/2014 9:25:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[USP_VM2F_BDU_Class_Target_Values_Populate] 
 @SourcePrefix NVARCHAR(1000)
,@groupTable NVARCHAR(1000)
,@TargetTable NVARCHAR(1000) 
,@ProductID int = 5

AS
    
/**************************************************************************************
 *
 *				CREATE THE QUERY FOR ADDING THE RELEVANT POPULATION - RAW DATA
 *
 **************************************************************************************/
DECLARE @INSERT NVARCHAR(max) = ''
DECLARE @SQLString NVARCHAR(max) = 
'SELECT  @INSERT = @INSERT +  '' 
MERGE ' + @TargetTable+ ' AS target
    USING (SELECT '' + cast(groups.ProductID as varchar(10)) + '' ProductID,  source.[Assembled_Unit_Seq_Key],'' + cast(groups.GroupID as varchar(10)) + '' GroupID,'' + cast(groups.TestID as varchar(10)) + '' TestID, '' +
		max(CASE WHEN testTable.[testName] = groups.[TestName] + ''_1'' THEN ''max(CASE WHEN source.partitionkey = '' + cast(testTable.partitionkey as varchar(10)) + '' THEN '' + testTable.partitionColumn + '' END) '' END)	 + '' ActualValue ,'' +	
		max(CASE WHEN testTable.[testName] = groups.[TestName] + ''_4'' THEN ''max(CASE WHEN source.partitionkey = '' + cast(testTable.partitionkey as varchar(10)) + '' THEN '' + testTable.partitionColumn + '' END) '' END)  + '' MinValue,'' +
		 max(CASE WHEN testTable.[testName] = groups.[TestName] + ''_11'' THEN ''max(CASE WHEN source.partitionkey = '' + cast(testTable.partitionkey as varchar(10)) + '' THEN '' + testTable.partitionColumn + '' END) '' END)  + '' step '' +		
		+ '' FROM ' + @SourcePrefix + '_Results_Float source 
		GROUP BY source.[Assembled_Unit_Seq_Key]
		HAVING '' + max(CASE WHEN testTable.[testName] = groups.[TestName] + ''_1'' THEN ''max(CASE WHEN source.partitionkey = '' + cast(testTable.partitionkey as varchar(10)) + '' THEN '' + testTable.partitionColumn + '' END) '' END) + '' IS NOT NULL 
		AND '' + max(CASE WHEN testTable.[testName] = groups.[TestName] + ''_4'' THEN ''max(CASE WHEN source.partitionkey = '' + cast(testTable.partitionkey as varchar(10)) + '' THEN '' + testTable.partitionColumn + '' END) '' END) + '' IS NOT NULL
		AND '' + max(CASE WHEN testTable.[testName] = groups.[TestName] + ''_11'' THEN ''max(CASE WHEN source.partitionkey = '' + cast(testTable.partitionkey as varchar(10)) + '' THEN '' + testTable.partitionColumn + '' END) '' END) + '' IS NOT NULL
) AS source
    ON (target.ProductID = source.ProductID
AND target.UnitID = source.Assembled_Unit_Seq_Key
AND target.GroupID = source.GroupID
AND target.TestID = source.TestID)
    WHEN MATCHED THEN 
        UPDATE SET ActualValue = source.ActualValue
		,MinValue = source.MinValue
		,step = source.step
		,MaxValue = null
		,IsTrain = null
	WHEN NOT MATCHED THEN	
	    INSERT (ProductID,UnitID,GroupID,TestID,ActualValue,MinValue,step)
	    VALUES (source.ProductID,source.Assembled_Unit_Seq_Key,source.GroupID,source.TestID,ActualValue,MinValue,step);
		''
		FROM ' + @groupTable + ' groups
INNER JOIN ' + @SourcePrefix + '_TestData testTable
	ON testTable.[testName] IN (groups.[TestName] + ''_1'', groups.[TestName] + ''_4'', groups.[TestName] + ''_11'')
WHERE groups.ProductID = ' + cast(@ProductID as varchar(10))+' 
GROUP BY groups.ProductID, groups.GroupID, groups.TestID'

PRINT(@SQLString)+char(13)+'*************************************************************************'+char(13)
EXEC sp_executeSql @SQLString, N'@INSERT NVARCHAR(max) OUTPUT', @INSERT OUTPUT

-------------------------------------------------

/**************************************************************************************
 *
 *									RUN THE ACTUAL QUERY 
 *
 **************************************************************************************/
PRINT(@INSERT)+char(13)+'*************************************************************************'+char(13)
EXEC(@INSERT)



/**************************************************************************************
 *
 *								UPDATE THE MAX VALUE COLUMN
 *
 **************************************************************************************/
SET @SQLString = 'UPDATE target
SET MaxValue = mValue
FROM ' + @TargetTable + ' target 
inner join 
(SELECT ProductID, UnitID, GroupID,MAX([ActualValue]) mValue
 FROM ' + @TargetTable + '
 WHERE ProductID = ' + cast(@ProductID as varchar(10)) + 
' GROUP BY ProductID, UnitID,GroupID
) source
ON target.ProductID = source.ProductID
AND target.UnitID = source.UnitID
AND target.GroupID = source.GroupID
'
PRINT(@SQLString)+char(13)+'*************************************************************************'+char(13)
EXEC(@SQLString)


/**************************************************************************************
 *
 *								UPDATE THE ISTRAIN FLAG
 *
 **************************************************************************************/
SET @SQLString = 'UPDATE target
SET IsTrain = CASE WHEN RID*1.0/CNT*1.0<=0.7 THEN 1 ELSE 0 END
FROM ' + @TargetTable + ' target 
INNER JOIN
(SELECT distinct groupid,CNT=count(distinct unitid)
			FROM ' + @TargetTable + '
			WHERE ProductID = ' + cast(@ProductID as varchar(10)) + '
			GROUP BY groupid) source1 ON target.groupid = source1.groupid
			INNER JOIN (SELECT groupid, unitid , RID=DENSE_RANK()OVER(PARTITION BY groupid ORDER BY unitid)
						FROM ' + @TargetTable + '
			WHERE ProductID = ' + cast(@ProductID as varchar(10)) + '
					 ) source2 ON target.unitid = source2.unitid
										and  target.groupid = source2.groupid'
PRINT(@SQLString)+char(13)+'*************************************************************************'+char(13)
EXEC(@SQLString)

GO


