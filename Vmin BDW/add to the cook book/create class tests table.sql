--------------------------- create a class test table for a specific product ---------------------------------------

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
