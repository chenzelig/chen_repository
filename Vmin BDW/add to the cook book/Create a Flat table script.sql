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
