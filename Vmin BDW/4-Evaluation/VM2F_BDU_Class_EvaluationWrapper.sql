
----------------------------- create a class test table for a specific product ---------------------------------------

IF OBJECT_ID (N'[MPDExploration]..VM2F_BDU_Class_UT_ClassTests', N'U') IS NOT NULL
	DROP TABLE [MPDExploration]..VM2F_BDU_Class_UT_ClassTests;


select * 
into [MPDExploration]..VM2F_BDU_Class_UT_ClassTests
from [MPDExploration]..VM2F_ClassTests
where Shift is not null
AND convert(varchar(max),groupid) IN (
SELECT AttributeName
FROM VM2Fsystem..ARS_AttributesInJob A 
JOIN VM2Fsystem..ARS_Attributes B 
        ON A.ProjectID=B.ProjectID 
        AND A.AttributeID=B.AttributeID 
WHERE A.ProjectID=130 -- config!!!
AND IsTarget=1)


-- index table
create index ix_VM2F_BDU_Class_UT_ClassTests_1 on VM2F_BDU_Class_UT_ClassTests(GroupID)
create unique index ix_VM2F_BDU_Class_UT_ClassTests_2 on VM2F_BDU_Class_UT_ClassTests(TestID)

---------------------------------------- create a summary table -------------------------------------

IF OBJECT_ID (N'[MPDExploration]..VM2F_BDU_Class_UT_ClassTestsSummary', N'U') IS NOT NULL
	DROP TABLE [MPDExploration]..VM2F_BDU_Class_UT_ClassTestsSummary;

select top 0 GroupID,CNT,OS_CNT,OS_10MV,OS_20MV,OS_30MV,OS_40MV,OS_50MV,OS_50PLUS,AVG_STEPS_WP,AVG_STEPS_NP,TTR
into VM2F_BDU_Class_UT_ClassTestsSummary
from VM2F_BDU_Class_UT_ClassTests

-- Validation: check that data per groupid,testid,unitID appears more than once
select groupid,testid,unitID, COUNT(*)
from VM2F_BDU_Class_UT_Filtered_Target_Values 
group BY groupid,testid,unitID
HAVING COUNT(*)>1

------------------------------------------ Create a flat Table --------------------------------------
-- Create a flat table for evaluation 

IF OBJECT_ID (N'[MPDExploration]..VM2F_BDU_Class_UT_FLat_Table', N'U') IS NOT NULL
	DROP TABLE [MPDExploration]..VM2F_BDU_Class_UT_FLat_Table;

IF OBJECT_ID (N'[MPDExploration]..VM2F_BDU_Class_UT_FLat_Table_Temp1', N'U') IS NOT NULL
	DROP TABLE [MPDExploration]..VM2F_BDU_Class_UT_FLat_Table_Temp1;

IF OBJECT_ID (N'[MPDExploration]..VM2F_BDU_Class_UT_FLat_Table_Temp2', N'U') IS NOT NULL
	DROP TABLE [MPDExploration]..VM2F_BDU_Class_UT_FLat_Table_Temp2;

EXEC [USP_VM2F_BDU_Class_FlatTable_Populate]  
 @SourcePrefix = 'VM2F_BDU_Class_UT_DFF_Filtered'
,@TargetTable = 'VM2F_BDU_Class_UT_Filtered_Target_Values'
,@FlatTable = 'VM2F_BDU_Class_UT_FLat_Table'
,@groupTable = 'VM2F_BDU_Class_UT_ClassTests'
,@ProductID = 6

-- validate flat table
SELECT * from VM2F_BDU_Class_UT_FLat_Table
--UnitID=4855928207	
--DFF_SORT_RELVBDN_1-->0.792079

SELECT * 
from VM2F_BDU_Class_UT_DFF_Filtered_TestData
where testName like 'DFF_SORT_RELVBDN_1'

--0	col1

SELECT UnitID,col1
from VM2F_BDU_Class_UT_DFF_Filtered_Results_Float
where PartitionKey=0
and UnitID=4855928207

SELECT unitid,partitionkey, count(*)
from VM2F_BDU_Class_UT_DFF_Filtered_Results_Float
group by unitid,partitionkey
ORDER by count(*) desc

-------------------------------------------- Evalutaion ------------------------------------------------

DECLARE @currentGroupID int

DECLARE GroupCursor CURSOR FORWARD_ONLY  READ_ONLY 
     FOR select distinct GroupID from VM2F_BDU_Class_UT_ClassTests order by GroupID 

OPEN GroupCursor

FETCH NEXT FROM GroupCursor 
INTO @currentGroupID

WHILE @@FETCH_STATUS = 0
BEGIN


	EXEC [dbo].[USP_VM2F_BDU_Class_Evaluation]  
	 @GroupID = @currentGroupID
	,@groupTable = 'VM2F_BDU_Class_UT_ClassTests'
	,@TargetTable  = 'VM2F_BDU_Class_UT_Filtered_Target_Values'
	,@FlatTable ='VM2F_BDU_Class_UT_FLat_Table'

	FETCH NEXT FROM GroupCursor 
	INTO @currentGroupID

END 

CLOSE GroupCursor;
DEALLOCATE GroupCursor;

