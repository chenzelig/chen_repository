

-------------------- rename and edit preavious project -------------------
USE MPDExploration
GO
sp_RENAME '[VM2F_BDU_Class_UT_PartitionedData]' , 'VM2F_BDU_Class_UT_PartitionedData_Draft'

USE VM2FSystem
GO

UPDATE ARS_Project
SET ProjectDesc='VM2F BDU Class ULT Analysis Draft',
PartitionTableName='VM2F_BDU_Class_UT_PartitionedData_Draft'
where ProjectID=120


/********************
  ARS configuration
********************/


USE VM2FSystem
GO



insert into dbo.ARS_Project(ProjectID,ProjectDesc,PartitionTableName,PartitionTableDataBase,PartitionTableschema,DataModelKey,ScaleData,MoveToHadoop)
values (122,'VM2F BDU Class ULT Analysis','VM2F_BDU_Class_UT_PartitionedData','MPDExploration'	,'dbo'				,'UnitID'	 ,1		   ,0)

select * from ARS_Project where ProjectID=122

--configure target source
insert into dbo.ARS_SourcePartition(ProjectID, SourceID, SourceName,	[DataBase],			[schema], SourceTableName,					 ValueField, AggregateFunction, SourceTypeID, SourceKeys)
							 values(122,	   1,	    'Target data',	'MPDExploration',	'dbo',	  'VM2F_BDU_Class_UT_TargetData', 'TargetValue','MAX',			     1			 , 'GroupID')
--configure sort data source
--HOW CAN I FILTER'SELECT TOP 5,00 FROM..WHERE UNITID IS NOT NULL' USING POPULATION FILTER
insert into dbo.ARS_SourcePartition(ProjectID, SourceID, SourceName,	[DataBase],			[schema], SourceTableName,    AggregateFunction, SourceTypeID, SourceAdditionalParam,								SourceKeys, ColumnsToIgnore)
							 values(122,	   2,	    'Sort data',	'MPDExploration',	'dbo',	  'VM2F_BDU_Class_UT_Results_Float',NULL,			     4			,'MPDExploration.dbo.VM2F_BDU_Class_UT_TestData' , 'PartitionKey',
							 'LATO_Start_WW,LotId,LOTS_Seq_Key,dataDomainId,operationId,Unit_Testing_Seq_Key,Assembled_Unit_Seq_Key,	Sort_Wafer_ID,Sort_X_Location,Sort_Y_Location,Socket_ID,Unit_Interface_Bin,Unit_Natural_Bin,Unit_Functional_Bin,	Unit_Data_Bin,Substructure_Interface_Bin,Substructure_Functional_Bin,Substructure_Data_Bin,Within_LOTS_Seq_Num	Sort_LotId'
							 )


--configure special values
INSERT INTO ARS_ProjectSpecialValues(ProjectID,SourceID,SpecialValue,SpecialValueHandlingID)
SELECT ProjectID=122
	  ,SourceID=NULL--If this special value is for all sources in project then NULL, otherwise configure a specific source
	  ,SpecialValue='-999'--Your special value as it appears when casting from source table to VARCHAR 
	  ,SpecialValueHandlingID=0 --An ID from ARS_DIM_SpecialValueHandling or any other ID that doesn't appear for ignoring this value
UNION
SELECT ProjectID=122
	  ,SourceID=NULL--If this special value is for all sources in project then NULL, otherwise configure a specific source
	  ,SpecialValue='999'--Your special value as it appears when casting from source table to VARCHAR 
	  ,SpecialValueHandlingID=0 --An ID from ARS_DIM_SpecialValueHandling or any other ID that doesn't appear for ignoring this value

--check the special values configuration
/*
select distinct convert(varchar,col132) 
from MPDExploration..VM2F_HSW_Sort_HSWDT_Results_Float
order by 1 
*/

--look at the configured sources
select * from ARS_SourcePartition where ProjectID=122

--Execute data preparation on first source
EXEC USP_ARS_DataPreparation @ProjectID=122, @SourceID=1, @IsDestructive=0, @IsSpecialValuesHandling=1 , @EM_ExecutionID=null, @IsSavingMode=1


--look at the attributes table
select * 
from ARS_Attributes
where ProjectID=122
and SourceID=1

select GroupID,count(distinct UnitID)
from MPDExploration.dbo.VM2F_HSW_Class_HSWDT_TargetData
group by GroupID
order by GroupID

--check the new partitioned data table
select * from MPDExploration.dbo.VM2F_HSWDTOZ_PartitionedData

--Execute data preparation on second source
EXEC USP_ARS_DataPreparation @ProjectID=122,@SourceID=2,@IsDestructive=0,@IsSpecialValuesHandling=1, @EM_ExecutionID=null, @IsSavingMode=1

--look at the attributes table
select * 
from ARS_Attributes
where ProjectID=122
and SourceID=2

--filter the attributes table
--select * from ARS_DIM_AttributeType
select * 
from ARS_Attributes
where ProjectID=122
and SourceID=2
and DataTypeID=2 --only continuous attributes
and 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1--maximum 10% missing values


/***********************************************
	Configure and execute attribute knockout
***********************************************/


INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  1,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  2,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  3,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  4,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  5,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  6,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  7,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  8,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  9,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  10,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  11,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  12,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  13,	   0.9,		  15,	   NULL,  2,	    '0.1')

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  14,	   0.9,		  15,	   NULL,  2,	    '0.1')



--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,1,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='616'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,2,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='617'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,3,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='629'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,4,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='630'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,5,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='631'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,6,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='632'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,7,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='633'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,8,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='640'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,9,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='643'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,10,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='647'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,11,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='650'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,12,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='657'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,13,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='660'

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,14,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='661'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,1,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'


--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,2,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,3,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,4,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,5,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,6,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,7,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,8,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,9,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,10,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,11,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,12,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,13,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,14,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
AND AttributeName like '%DFF_SORT_%'

--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=1,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=2,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=3,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=4,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=5,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=6,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=7,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=8,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=9,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=10,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=11,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=12,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=13,@JobExecutionTS=null
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=14,@JobExecutionTS=null







--#####################################################################################
--creating the view + updating its name to be without timestamp in the end of the name
--#####################################################################################
DECLARE @ProjectID INT  =122;
DECLARE @GroupID VARCHAR(MAX) = '128';
declare @jobId varchar (max) = 14;
declare @AttributeId varchar(max) = (
	select AttributeId 
	from VM2Fsystem..ARS_Attributes where projectId = @ProjectID and  AttributeName=@GroupID)
;
DECLARE @AttributeQuery VARCHAR(MAX) = CONCAT('
SELECT A.AttributeId
FROM dbo.ARS_AttributeReductionResults R
INNER JOIN dbo.ARS_Attributes A
ON R.ProjectID=A.ProjectID
 AND R.AttributeID=A.AttributeID
WHERE R.ProjectID=',@ProjectID,' 
 AND R.JobID=',@jobId,'
  AND R.JobExecutionTS=(
	select max(JobExecutionTS)
	from ARS_AttributeReductionResults
	where ProjectID=R.ProjectID
	 and JobID=R.JobID
)
 AND R.Status=1');

 if object_id('tempdb..#ViewName') is not null
	drop table #ViewName
 create table #ViewName(name varchar(100))


--create a flat view with selected attributes
insert into #ViewName
EXEC [VM2Fsystem].[dbo].[USP_ARS_CreateFlatViewFromPartition]
@ProjectID=@ProjectID, 
@AttributeQuery=@AttributeQuery, 
@populationFilter=null, 
@ViewPrefix='VM2F_HSWDTOZ_GroupID', 
@viewdetails=@GroupID, 
@DataBase='MPDExploration', 
@TargetAttributeID=@AttributeId, 
@UpsampleAttributeID=NULL, 
@UpsampleRatio=NULL, 
@CreatedBy='ssarel',
@IsNormalizedValues=0--return original values (not scaled)

declare @SQL varchar(max)

select @SQL='sp_rename '''+replace(replace(name,'[MPDExploration].[dbo].[',''),']','')+''',''VM2F_HSWDTOZ_GroupID_'+@GroupID+'_VW'''
from #ViewName

exec(@SQL)
--#####################################################################################
--Validate the creation of the views
select *
from sys.views
where name like '%VM2F_HSWDTOZ_GroupID%'

-- job 1: ~40K
select * from VM2F_HSWDTOZ_GroupID_113_VW where [113] is not null
-- job 2: ~80K
select * from VM2F_HSWDTOZ_GroupID_114_VW where [114] is not null
-- job 3: ~14K
select * from VM2F_HSWDTOZ_GroupID_115_VW where [115] is not null
-- job 4: ~175K
select * from VM2F_HSWDTOZ_GroupID_116_VW where [116] is not null
-- job 5: ~26K
select * from VM2F_HSWDTOZ_GroupID_117_VW where [117] is not null
-- job 6: ~48K
select * from VM2F_HSWDTOZ_GroupID_118_VW where [118] is not null
-- job 7: ~13K
select * from VM2F_HSWDTOZ_GroupID_119_VW where [119] is not null
-- job 8: ~175K
select * from VM2F_HSWDTOZ_GroupID_120_VW where [120] is not null
-- job 9: ~26K
select * from VM2F_HSWDTOZ_GroupID_121_VW where [121] is not null
-- job 12: ~23K
select * from VM2F_HSWDTOZ_GroupID_126_VW where [126] is not null
-- job 13: ~43K
select * from VM2F_HSWDTOZ_GroupID_127_VW where [127] is not null
-- job 14: ~79K
select * from VM2F_HSWDTOZ_GroupID_128_VW where [128] is not null
-- job 15: ~68K
select * from VM2F_HSWDTOZ_GroupID_138_VW where [138] is not null
-- job 16: ~172K
select * from VM2F_HSWDTOZ_GroupID_140_VW where [140] is not null
-- job 17: ~63K
select * from VM2F_HSWDTOZ_GroupID_141_VW where [141] is not null
-- job 18: ~74K
select * from VM2F_HSWDTOZ_GroupID_142_VW where [142] is not null
--#####################################################################################


/*******************************
		JobIds 2- 24
******************************/
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=2
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=2
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  2,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,2,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='114'
;
--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,2,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1

;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=3
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=3
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  3,	   0.9,		  15,	   NULL,  2,	    '0.1')
;

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,3,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='115'
;
--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,3,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=4
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=4
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  4,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,4,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='116'
;
--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,4,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=5
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=5
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  5,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,5,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='117'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,5,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;



DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=6
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=6
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  6,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,6,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='118'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,6,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=7
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=7
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  7,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,7,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='119'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,7,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=8
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=8
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  8,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,8,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='120'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,8,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=9
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=9
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  9,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,9,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='121'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,9,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=10
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=10
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  10,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,10,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='123'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,10,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=11
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=11
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  11,	   0.9,		  15,	   NULL,  2,	    '0.1')
;

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,11,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='125'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,11,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=12
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=12
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  12,	   0.9,		  15,	   NULL,  2,	    '0.1')
;

--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,12,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='126'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,12,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=13
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=13
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  13,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,13,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='127'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,13,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=14
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=14
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  14,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,14,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='128'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,14,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=15
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=15
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  15,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,15,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='138'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,15,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=16
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=16
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  16,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,16,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='140'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,16,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=17
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=17
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  17,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,17,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='141'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,17,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=18
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=18
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  18,	   0.9,		  15,	   NULL,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,18,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='142'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,18,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
--##############################################didn't run the following jobs#############################################
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=19
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=19
;

INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  19,	   0.9,		  15,	   30,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,19,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='143'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,19,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;


DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=20
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=20
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  20,	   0.9,		  15,	   30,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,20,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='144'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,20,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=21
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=21
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  21,	   0.9,		  15,	   30,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,21,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='149'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,21,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=22
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=22
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  22,	   0.9,		  15,	   30,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,22,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='150'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,22,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=23
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=23
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  23,	   0.9,		  15,	   30,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,23,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='151'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,23,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;
DELETE dbo.ARS_AttributesInJob
WHERE ProjectID=122 AND JobID=24
;
DELETE dbo.ARS_Jobs
WHERE ProjectID=122 AND JobID=24
;
--select * from ARS_DIM_OrderType
--select * from ARS_DIM_Method
INSERT INTO dbo.ARS_Jobs  (ProjectID, JobID, Threshold, OrderType, K,	  MethodID, AdditionalParam)
VALUES					  (122,		  24,	   0.9,		  15,	   30,  2,	    '0.1')
;
--insert the target attribute
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)		
SELECT 122,24,AttributeID,1
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=1
AND AttributeName='152'

--insert the candidate attributes
INSERT INTO dbo.ARS_AttributesInJob (ProjectID, JobID, AttributeID, IsTarget)	
SELECT 122,24,AttributeID,0
FROM ARS_Attributes
WHERE ProjectID=122
AND SourceID=2
AND DataTypeID=2
AND 1.0*NumMissingValues/(NumRecords+NumMissingValues)<0.1
;

/*Are running on the server
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=2,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=3,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=4,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=5,@JobExecutionTS=null

--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=6,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=7,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=8,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=9,@JobExecutionTS=null

--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=10,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=11,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=12,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=13,@JobExecutionTS=null

--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=14,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=15,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=16,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=17,@JobExecutionTS=null

--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=18,@JobExecutionTS=null
;*/
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=19,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=20,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=21,@JobExecutionTS=null
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=22,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=23,@JobExecutionTS=null
;
--execute the job
exec USP_ARS_AttributeKnockout @ProjectID=122,@jobID=24,@JobExecutionTS=null





SELECT Status,count(1)
FROM dbo.ARS_AttributeReductionResults R
INNER JOIN dbo.ARS_Attributes A
ON R.ProjectID=A.ProjectID
 AND R.AttributeID=A.AttributeID
WHERE R.ProjectID=122 
 AND R.JobID=24
 AND R.JobExecutionTS=(--make sure we look at the last execution
	select max(JobExecutionTS)
	from ARS_AttributeReductionResults
	where ProjectID=R.ProjectID
	 and JobID=R.JobID
)
GROUP BY Status

