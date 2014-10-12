USE MFG_Solutions
GO

------------------------------------------------------------------------------------------------------------------------
/*									Delete Preavious Values															*/
-----------------------------------------------------------------------------------------------------------------------

-- Indicators
DELETE FROM [GM_R_ModelIndicatorValues] WHERE convert(varchar(max),ModelID) LIKE '20%' AND LEN(convert(varchar(max),ModelID))=6
DELETE FROM [GM_R_IndicatorLevelInstances] WHERE convert(varchar(max),ModelID) LIKE '20%' AND LEN(convert(varchar(max),ModelID))=6
DELETE FROM [GM_F_ModelIndicators] WHERE SolutionID IN (20)
DELETE FROM [GM_D_IndicatorLevels] WHERE  IndicatorLevelID IN (4)
DELETE FROM [GM_D_Indicators] WHERE IndicatorID IN (4,5,6,7,8,9,10,11,12,13,14,15,16)
DELETE FROM [GM_D_IndicatorCalculatedFields] WHERE IndicatorCalculatedFieldID IN (3,4)

-- Parameters and Features
DELETE FROM [GM_F_ModelingFeatures] WHERE SolutionID=20
DELETE FROM [GM_D_Features] WHERE SolutionID=20
DELETE FROM [GM_F_ModelingParameters] WHERE SolutionID=20
DELETE FROM [GM_D_Parameters] WHERE ParameterID BETWEEN 100 AND 150 or ParameterID IN (20,21,22,23,24,25)

-- Models
DELETE FROM [GM_D_Models] WHERE SolutionID=20
DELETE FROM [GM_D_ModelGroups] WHERE SolutionID=20
DELETE FROM [GM_D_Solutions] WHERE SolutionID=20

------------------------------------------------------------------------------------------------------------------------
/*									 Models	Configuration															*/
-----------------------------------------------------------------------------------------------------------------------

------------------------------------- Config Solution -------------------------------------
INSERT INTO [dbo].[GM_D_Solutions] VALUES(20,'VM2F_BDU_Class')

------------------------------------- Config ModelGroups -------------------------------------
INSERT INTO [dbo].[GM_D_ModelGroups] VALUES (20,2011,'VM2F_BDU_Class_22_ULT')
INSERT INTO [dbo].[GM_D_ModelGroups] VALUES (20,2012,'VM2F_BDU_Class_22_ULX')

------------------------------------- Config Models -------------------------------------
	-- ULT
	INSERT INTO GM_D_Models VALUES(201101,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201102,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201103,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201104,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201105,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201106,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201107,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201108,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201109,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201110,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201111,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201112,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)
	INSERT INTO GM_D_Models VALUES(201113,20,'BDW','CLASS','2+2','All','ULT','',2011,0,1,1)

	--ULX
	INSERT INTO GM_D_Models VALUES(201201,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201202,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201203,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201204,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201205,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201206,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201207,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201208,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201209,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201210,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201211,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201212,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201213,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201214,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201215,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)
	INSERT INTO GM_D_Models VALUES(201216,20,'BDW','CLASS','2+2','All','ULX','',2012,0,1,1)

------------------------------------------------------------------------------------------------------------------------
/*									Parameters Configuration															*/
-----------------------------------------------------------------------------------------------------------------------
----------------------------------------------- General GM ----------------------------------------------------
INSERT INTO GM_D_Parameters VALUES (20	,'Indicators - Queries For Data Extraction via XML',	2,	NULL)
INSERT INTO GM_D_Parameters VALUES (21	,'Indicators - Raw Data Schema'	,2,	NULL)
INSERT INTO GM_D_Parameters VALUES (22	,'Indicators - Prepared Data Schema'	,3,	NULL)
INSERT INTO GM_D_Parameters VALUES (23	,'Indicators - Data preparation Stored Procedure',	3,	NULL)
INSERT INTO GM_D_Parameters VALUES (24	,'Modeling - DataExtraction Pre-Step'	,2	,NULL)
INSERT INTO GM_D_Parameters VALUES (25	,'Indicators - DataExtraction Pre-Step'	,2,	NULL)

----------------------------------------------- Import Query ----------------------------------------------------
--Solution Level
INSERT INTO GM_D_Parameters VALUES(100,'Import Query  - Indicators - Operation (VM2F)',1,NULL)
INSERT INTO GM_D_Parameters VALUES(102,'Import Query - Indicators - MLOTS_LATO_Valid_Flag (VM2F)',1,NULL)
INSERT INTO GM_D_Parameters VALUES(103,'Import Query - Indicators - MLOTS_LOTS_Complete_Flag (VM2F)',1,NULL)
INSERT INTO GM_D_Parameters VALUES(104,'Import Query - Indicators - MUTB_LATO_Valid_Flag (VM2F)',1,NULL)
INSERT INTO GM_D_Parameters VALUES(105,'Import Query - Indicators - MUTB_Within_LOTS_Latest_Flag (VM2F)',1,NULL)
INSERT INTO GM_D_Parameters VALUES(123,'Import Query - Indicators - MUTB_Within_SubFlowStep_Latest_Flag (VM2F)',1,NULL)
INSERT INTO GM_D_Parameters VALUES(107,'Import Query - Indicators - Summary_Letter (VM2F)',1,NULL)
INSERT INTO GM_D_Parameters VALUES(108,'Import Query - Indicators - SubStructure_ID (VM2F)',1,NULL)

--ModelGroup Level
INSERT INTO GM_D_Parameters VALUES(101,'Import Query - Indicators - Having Clause SumTested  (VM2F)',2,NULL)
INSERT INTO GM_D_Parameters VALUES(106,'Import Query - Indicators - Temperature (VM2F)',2,NULL)	
INSERT INTO GM_D_Parameters VALUES(109,'Import Query - Indicators - Test Program Pattern - Product (VM2F)',2,NULL)
INSERT INTO GM_D_Parameters VALUES(110,'Import Query - Indicators - Test Program Pattern - BOMGROUP (VM2F)',2,NULL)
INSERT INTO GM_D_Parameters VALUES(111,'Import Query - Indicators - Test Program Pattern - DieStructure  (VM2F)',2,NULL)
INSERT INTO GM_D_Parameters VALUES(112,'Import Query - Indicators - Test Program Pattern - Values To Ignore  (VM2F)',2,NULL)
INSERT INTO GM_D_Parameters VALUES(113,'Import Query - Indicators - Number Of Days Back  (VM2F)',2,NULL)
INSERT INTO GM_D_Parameters VALUES(114,'Import Query - Indicators - Number Of Days To Import  (VM2F)',2,NULL)
INSERT INTO GM_D_Parameters VALUES(118,'Import Query - Indicators - wip_env_id is not null (VM2F)',2,NULL)
INSERT INTO GM_D_Parameters VALUES(119,'Import Query - Indicators - DevRevStep_Template (VM2F)',2,NULL)
INSERT INTO GM_D_Parameters VALUES(120,'Import Query - Indicators - Facility_to_Ignore (VM2F)',2,NULL)

----------------------------------------------- Predictions	-----------------------------------------------------------			
-- ModelGroup Level
INSERT INTO GM_D_Parameters VALUES(115,'Predictions - BOMGROUP Position (VM2F)',2,NULL)
		
-- Model Level
INSERT INTO GM_D_Parameters VALUES(116,'Predictions - Domain_Corner_Flow (VM2F)',3,NULL)
INSERT INTO GM_D_Parameters VALUES(117,'Predictions - Domain_Corner_Bin (VM2F)',3,NULL)
INSERT INTO GM_D_Parameters VALUES(121,'Predictions - Vmin Baseline (VM2F)',3,NULL)
INSERT INTO GM_D_Parameters VALUES(122,'Predictions - Number Of Steps Baseline (VM2F)',3,NULL)

------------------------------------------------------------------------------------------------------------------------
/*									Configure ModelingParameters													*/
-----------------------------------------------------------------------------------------------------------------------

---------------------------------- -----Import Query ------------------------------------------------------
--Solution level
INSERT INTO [GM_F_ModelingParameters] VALUES (20,-1,-1,NULL,100,'6881')
INSERT INTO [GM_F_ModelingParameters] VALUES (20,-1,-1,NULL,102,'Y')
INSERT INTO [GM_F_ModelingParameters] VALUES (20,-1,-1,NULL,103,'Y')
INSERT INTO [GM_F_ModelingParameters] VALUES (20,-1,-1,NULL,104,'Y')
INSERT INTO [GM_F_ModelingParameters] VALUES (20,-1,-1,NULL,105,'Y')
INSERT INTO [GM_F_ModelingParameters] VALUES (20,-1,-1,NULL,107,'A')
INSERT INTO [GM_F_ModelingParameters] VALUES (20,-1,-1,NULL,108,'UNIT')
INSERT INTO [GM_F_ModelingParameters] VALUES (20,-1,-1,NULL,123,'Y')
	
-- ModelGroup level
	--ULT
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,101,'1000')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,106,'105')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,109,'BDU')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,110,'UT3M')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,111,'22')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,112,'ENG,DOE,HCSL')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,113,'1')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,114,'10')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,118,'0')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,119,'%')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,120,'')

	--ULX
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,101,'1000')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,106,'95')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,109,'BDU')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,110,'UX4A')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,111,'22')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,112,'ENG,EGN1')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,113,'1')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,114,'10')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,118,'0')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,119,'%')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,120,'')

------------------------------------------------ Predictions ------------------------------------------------------
-- ModelGroup level	
	--ULT
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,115,'1')
	--ULX
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,115,'2')

-- Model Level
	--ULT
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201101,NULL,116,'CLR_P1_1')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201102,NULL,116,'CLR_PN_1')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201103,NULL,116,'GT_P0_3')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201104,NULL,116,'GT_P0_4')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201105,NULL,116,'GT_P0_5')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201106,NULL,116,'GT_P0_6')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201107,NULL,116,'GT_P0_7')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201108,NULL,116,'IA_P1_3')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201109,NULL,116,'IA_P1_4')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201110,NULL,116,'IA_P1_5')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201111,NULL,116,'IA_P1_7')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201112,NULL,116,'IA_P1_9')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201113,NULL,116,'SA_P1_1')

	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201101,NULL,117,'CLR_P1_1250')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201102,NULL,117,'CLR_PN_1250')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201103,NULL,117,'GT_P0_1253')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201104,NULL,117,'GT_P0_1254')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201105,NULL,117,'GT_P0_1255')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201106,NULL,117,'GT_P0_1256')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201107,NULL,117,'GT_P0_1269')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201108,NULL,117,'IA_P1_1253')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201109,NULL,117,'IA_P1_1254')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201110,NULL,117,'IA_P1_1255')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201111,NULL,117,'IA_P1_1269')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201112,NULL,117,'IA_P1_1270')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2011,201113,NULL,117,'SA_P1_1250')
	
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201101,NULL,121,'0.98')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201102,NULL,121,'0.51')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201103,NULL,121,'1.09')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201104,NULL,121,'1.04')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201105,NULL,121,'1.07')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201106,NULL,121,'1.11')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201107,NULL,121,'1.00')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201108,NULL,121,'0.87')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201109,NULL,121,'0.87')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201110,NULL,121,'0.86')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201111,NULL,121,'0.80')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201112,NULL,121,'0.77')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201113,NULL,121,'0.71')

	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201101,NULL,122,'46.35')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201102,NULL,122,'9.67')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201103,NULL,122,'35.58')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201104,NULL,122,'29.80')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201105,NULL,122,'31.48')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201106,NULL,122,'34.05')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201107,NULL,122,'26.27')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201108,NULL,122,'37.69')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201109,NULL,122,'38.80')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201110,NULL,122,'37.66')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201111,NULL,122,'30.08')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201112,NULL,122,'27.87')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201113,NULL,122,'26.69')
	
	--ULX
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201201,NULL,116,'CLR_P0_3')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201202,NULL,116,'CLR_P1_1')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201203,NULL,116,'CLR_PN_1')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201204,NULL,116,'GT_P0_1')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201205,NULL,116,'GT_P0_2')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201206,NULL,116,'GT_P0_3')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201207,NULL,116,'GT_P1_1')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201208,NULL,116,'GT_PN_1')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201209,NULL,116,'IA_P0_2')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201210,NULL,116,'IA_P0_3')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201211,NULL,116,'IA_P0_7')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201212,NULL,116,'IA_P1_1')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201213,NULL,116,'IA_P1_2')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201214,NULL,116,'IA_P1_3')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201215,NULL,116,'IA_P1_4')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201216,NULL,116,'SA_P1_1')

	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201201,NULL,117,'CLR_P0_1267')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201202,NULL,117,'CLR_P1_1262')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201203,NULL,117,'CLR_PN_1262')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201204,NULL,117,'GT_P0_1262')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201205,NULL,117,'GT_P0_1263')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201206,NULL,117,'GT_P0_1267')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201207,NULL,117,'GT_P1_1262')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201208,NULL,117,'GT_PN_1262')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201209,NULL,117,'IA_P0_1263')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201210,NULL,117,'IA_P0_1267')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201211,NULL,117,'IA_P0_1274')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201212,NULL,117,'IA_P1_1262')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201213,NULL,117,'IA_P1_1263')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201214,NULL,117,'IA_P1_1267')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201215,NULL,117,'IA_P1_1268')
	INSERT INTO [GM_F_ModelingParameters] VALUES(20,2012,201216,NULL,117,'SA_P1_1262')

	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201201,NULL,121,'1.06')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201202,NULL,121,'0.63')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201203,NULL,121,'0.53')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201204,NULL,121,'0.95')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201205,NULL,121,'1.11')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201206,NULL,121,'1.04')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201207,NULL,121,'0.66')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201208,NULL,121,'0.54')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201209,NULL,121,'1.01')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201210,NULL,121,'1.01')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201211,NULL,121,'0.92')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201212,NULL,121,'0.62')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201213,NULL,121,'0.60')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201214,NULL,121,'0.61')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201215,NULL,121,'0.59')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201216,NULL,121,'0.67')

	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201201,NULL,122,'19.20')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201202,NULL,122,'10.37')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201203,NULL,122,'8.06')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201204,NULL,122,'35.44')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201205,NULL,122,'48.20')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201206,NULL,122,'33.57')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201207,NULL,122,'10.21')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201208,NULL,122,'8.58')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201209,NULL,122,'14.39')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201210,NULL,122,'14.25')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201211,NULL,122,'15.54')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201212,NULL,122,'12.80')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201213,NULL,122,'15.11')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201214,NULL,122,'12.35')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201215,NULL,122,'14.00')
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201216,NULL,122,'22.17')

------------------------------------------------ GM general -------------------------------------------------------

-- Solution level 
INSERT INTO [GM_F_ModelingParameters] VALUES (20,-1,-1,NULL,21, '[UnitID] VARCHAR(20),[Test_Program] VARCHAR(500),[Test_Name] VARCHAR(500) ,[WW] INT,[Test_Date] Date,[Test_Result] VARCHAR(500)')	-- Indicators #RawData Schema
INSERT INTO [GM_F_ModelingParameters] VALUES (20,-1,-1,NULL,22,'[UnitID] VARCHAR(20),[Test_Program] VARCHAR(500),[WW] INT, [Test_Date] Date ,[ModelID] INT,[FeatureID] INT,[Feature_ActualValue] FLOAT, [Feature_MinValue] FLOAT,[Feature_Step] INT, [Feature_GB] FLOAT,[Model_MaxValue] FLOAT,[Model_NumOfSteps] INT ,[Model_PotentialOS] INT, [Model_CertainOS] INT, [Model_Prediction] FLOAT') -- Indicators #PreparedData Schema
INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,-1,NULL,25,'USP_VM2F_BDU_Class_Indicators_PreDataExtraction @SolutionID=20, @ModelGroupID=2011') --the indicators data preparation SP
INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,-1,NULL,25,'USP_VM2F_BDU_Class_Indicators_PreDataExtraction @SolutionID=20, @ModelGroupID=2012') --the indicators data preparation SP
INSERT INTO [GM_F_ModelingParameters] VALUES(20,-1,-1,NULL,20,'
<Queries>
	<Row>
	<QueryNum>1</QueryNum>
	<ConnectionID>4</ConnectionID>
	<Query>
		SELECT  
			MUTB.Assembled_Unit_Seq_Key UnitID,      			  
			MLOTS.Program_Or_BI_Recipe_Name Test_Program,
			MTL.Test_Name,
			MLOTS.LATO_Start_WW as WW,
			CAST(MLOTS.LOTS_Start_Date_Time AS DATE) Test_Date,
			C.string_result Test_Result	  			  
		FROM MDS_Lot_Oper_Testing_Session MLOTS
				INNER JOIN MDS_Test_In_LOTS MTL
						ON MTL.LATO_Start_WW = MLOTS.LATO_Start_WW 
						AND MTL.Lot = MLOTS.Lot
						AND MTL.LOTS_Seq_Key = MLOTS.LOTS_Seq_Key
				INNER JOIN MDS_Unit_String_Test_Result C 
					  	ON MTL.LATO_Start_WW = C.LATO_Start_WW 
					  	AND MTL.Lot = C.Lot 
					  	AND MTL.LOTS_Seq_Key = C.LOTS_Seq_Key 
					  	AND MTL.Test_In_LOTS_Seq_Key = C.Test_In_LOTS_Seq_Key 
				INNER JOIN MDS_Unit_Testing_Bins MUTB 
					  	ON MUTB.LATO_Start_WW = C.LATO_Start_WW 
					  	AND MUTB.Lot = MLOTS.Lot 
					  	AND MUTB.LOTS_Seq_Key = MLOTS.LOTS_Seq_Key 
					  	AND MUTB.Unit_Testing_Seq_Key = C.Unit_Testing_Seq_Key 
					  	AND MUTB.Substructure_ID = C.Substructure_ID 
				INNER JOIN (SELECT DISTINCT MLOTS.Program_Or_BI_Recipe_Name
				  	  		FROM MDS_Lot_Oper_Testing_Session MLOTS
							INNER JOIN MDS_Test_In_LOTS MTL
							ON MTL.LATO_Start_WW = MLOTS.LATO_Start_WW 
							AND MTL.Lot = MLOTS.Lot
							AND MTL.LOTS_Seq_Key = MLOTS.LOTS_Seq_Key
				  	  		WHERE <<Test_Program_Pattern>>
				  	  		AND <<Operation>>
							AND <<ValuesToIgnore>>
							AND <<Test_Name Prediction DFF>>
							GROUP BY MLOTS.Program_Or_BI_Recipe_Name, MTL.Test_Name
							HAVING SUM(MLOTS.Total_Tested)><<SumTested>> 
					  		) Res1
						ON Res1.Program_Or_BI_Recipe_Name=MLOTS.Program_Or_BI_Recipe_Name
			WHERE <<MLOTS_LATO_Valid_Flag>>
			AND <<MLOTS_LOTS_Complete_Flag>>  
			AND <<MUTB_LATO_Valid_Flag>>        
			AND <<MUTB_Within_LOTS_Latest_Flag>>
			AND <<Within_SubFlowStep_Latest_Flag>>
			AND <<Facility_to_Ignore>>
			AND <<DevRevStep_Template>>
			AND <<wip_env_id>>
			AND <<Temperature>>
			AND <<Summary_Letter>>
			AND <<Operation>>
			AND <<SubStructure_ID>> 
			AND <<Test_Name Vmin Test>>
			AND <<DateRange>>	
	</Query>	
	</Row>
	<Row>
	<QueryNum>2</QueryNum>
	<ConnectionID>4</ConnectionID>
	<Query>
		SELECT  
			MUTB.Assembled_Unit_Seq_Key UnitID,      			  
			MLOTS.Program_Or_BI_Recipe_Name Test_Program,
			MTL.Test_Name,
			NULL AS WW,
			CAST(NULL AS DATE) AS Test_Date,
			Max(C.Raw_Test_Data_Value) AS Test_Result	  			  
		FROM MDS_Lot_Oper_Testing_Session MLOTS
				INNER JOIN MDS_Test_In_LOTS MTL
						ON MTL.LATO_Start_WW = MLOTS.LATO_Start_WW 
						AND MTL.Lot = MLOTS.Lot
						AND MTL.LOTS_Seq_Key = MLOTS.LOTS_Seq_Key
				INNER JOIN MDS_Unit_Raw_Test_Data C 
					  	ON MTL.LATO_Start_WW = C.LATO_Start_WW 
					  	AND MTL.Lot = C.Lot 
					  	AND MTL.LOTS_Seq_Key = C.LOTS_Seq_Key 
					  	AND MTL.Test_In_LOTS_Seq_Key = C.Test_In_LOTS_Seq_Key 
				INNER JOIN MDS_Unit_Testing_Bins MUTB 
					  	ON MUTB.LATO_Start_WW = C.LATO_Start_WW 
					  	AND MUTB.Lot = MLOTS.Lot 
					  	AND MUTB.LOTS_Seq_Key = MLOTS.LOTS_Seq_Key 
					  	AND MUTB.Unit_Testing_Seq_Key = C.Unit_Testing_Seq_Key 
					  	AND MUTB.Substructure_ID = C.Substructure_ID 
				INNER JOIN (SELECT DISTINCT MLOTS.Program_Or_BI_Recipe_Name
				  	  		FROM MDS_Lot_Oper_Testing_Session MLOTS
							INNER JOIN MDS_Test_In_LOTS MTL
							ON MTL.LATO_Start_WW = MLOTS.LATO_Start_WW 
							AND MTL.Lot = MLOTS.Lot
							AND MTL.LOTS_Seq_Key = MLOTS.LOTS_Seq_Key
				  	  		WHERE <<Test_Program_Pattern>>
				  	  		AND <<Operation>>
							AND <<ValuesToIgnore>>
							AND <<Test_Name Prediction DFF>>
							GROUP BY MLOTS.Program_Or_BI_Recipe_Name, MTL.Test_Name
							HAVING SUM(MLOTS.total_Tested)><<SumTested>> 
					  		) Res1
						ON Res1.Program_Or_BI_Recipe_Name=MLOTS.Program_Or_BI_Recipe_Name
			WHERE <<MLOTS_LATO_Valid_Flag>>
			AND <<MLOTS_LOTS_Complete_Flag>>  
			AND <<MUTB_LATO_Valid_Flag>>        
			AND <<MUTB_Within_LOTS_Latest_Flag>>
			AND <<Within_SubFlowStep_Latest_Flag>>

			AND <<Facility_to_Ignore>>
			AND <<DevRevStep_Template>>
			AND <<wip_env_id>>
			AND <<Temperature>>
			AND <<Summary_Letter>>
			AND <<Operation>>
			AND <<SubStructure_ID>> 
			AND <<Test_Name Prediction DFF>>
			AND <<DateRange>>
		GROUP BY MUTB.Assembled_Unit_Seq_Key, MLOTS.Program_Or_BI_Recipe_Name,MTL.Test_Name
	</Query>	
	</Row>
</Queries>
')

-- ModelGroupLevel
	--ULT	
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201101,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201101') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201102,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201102') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201103,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201103') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201104,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201104') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201105,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201105') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201106,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201106') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201107,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201107') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201108,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201108') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201109,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201109') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201110,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201110') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201111,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201111') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201112,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201112') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2011,201113,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2011, @ModelID=201113') --the indicators data preparation SP
	--ULX	
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201201,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201201') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201202,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201202') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201203,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201203') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201204,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201204') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201205,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201205') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201206,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201206') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201207,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201207') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201208,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201208') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201209,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201209') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201210,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201210') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201211,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201211') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201212,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201212') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201213,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201213') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201214,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201214') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201215,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201215') --the indicators data preparation SP
	INSERT INTO [GM_F_ModelingParameters] VALUES (20,2012,201216,NULL,23,'USP_VM2F_BDU_Class_Indicators_DataPreparation @SolutionID=20, @ModelGroupID=2012, @ModelID=201216') --the indicators data preparation SP

------------------------------------------------------------------------------------------------------------------------
/*									Configure Features															*/
-----------------------------------------------------------------------------------------------------------------------

------------------------------------- Config Features ------------------------------------------

-- Solution Level
INSERT INTO GM_D_Features VALUES(20009901,20,'DFF_PBIC_S1_CLRP0','6881','','','','')
INSERT INTO GM_D_Features VALUES(20009902,20,'DFF_PBIC_S1_CLRP1','6881','','','','')
INSERT INTO GM_D_Features VALUES(20009903,20,'DFF_PBIC_S1_CLRPN','6881','','','','')
INSERT INTO GM_D_Features VALUES(20009904,20,'DFF_PBIC_S1_GTP0','6881','','','','')
INSERT INTO GM_D_Features VALUES(20009905,20,'DFF_PBIC_S1_GTP1','6881','','','','')
INSERT INTO GM_D_Features VALUES(20009906,20,'DFF_PBIC_S1_GTPN','6881','','','','')
INSERT INTO GM_D_Features VALUES(20009907,20,'DFF_PBIC_S1_IAP0','6881','','','','')
INSERT INTO GM_D_Features VALUES(20009908,20,'DFF_PBIC_S1_IAP1','6881','','','','')
INSERT INTO GM_D_Features VALUES(20009910,20,'DFF_PBIC_S1_SAP0','6881','','','','')
INSERT INTO GM_D_Features VALUES(20009909,20,'DFF_PBIC_S1_SAP1','6881','','','','')

-- ModelGroup Level
	-- ULT
	INSERT INTO GM_D_Features VALUES(20110001,20,'DFF_SORT_IDVFX_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110002,20,'DFF_SORT_RELVBDJP_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110003,20,'DFF_SORT_RELVBDN_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110004,20,'DFF_SORT_RELVBDP_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110005,20,'DFF_SORT_SICC1_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110006,20,'DFF_SORT_SICC1_2','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110007,20,'DFF_SORT_SICC1_9','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110008,20,'DFF_SORT_SICC2_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110009,20,'DFF_SORT_SICC2_10','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110010,20,'DFF_SORT_SICC2_12','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110011,20,'DFF_SORT_SICC3_10','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110012,20,'DFF_SORT_SICC3_11','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110013,20,'DFF_SORT_SICC3_12','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110014,20,'DFF_SORT_SICC3_4','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110101,20,'CACHCBO::CBOUCLKL_XXXCX_TBM_NC_24242403_HFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110102,20,'CACHCBO::CBOUCLKL_XXXCX_TBM_NC_24242403_HFM_MIN_SPLIT_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110103,20,'CACHCBO::CBOUCLKN_XXXCX_TBM_NC_24242403_HFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110104,20,'CACHCBO::CBOUCLKNFLT_XXXCX_SDR_NC_32320803_HFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110105,20,'CACHCBO::SAUCLK_XXXCX_TBM_NC_24242403_HFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110106,20,'DRGUCLK::DRGUCLK_XXXCX_TBM_NC_24240803_HFM_MIN_2600_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110107,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_GX_24240803_HFM_MIN_2600_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110108,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_NC_24240803_HFM_MIN_2600_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110109,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_NC_24240803_HFM_SPT_2600_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110201,20,'CACHCBO::CBOUCLKL_XXXCX_TBM_NC_08080803_LFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110202,20,'CACHCBO::CBOUCLKL_XXXCX_TBM_NC_08080803_LFM_MIN_SPLIT_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110203,20,'CACHCBO::CBOUCLKN_XXXCX_TBM_NC_08080803_LFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110204,20,'CACHCBO::CBOUCLKNFLT_XXXCX_SDR_NC_08080803_LFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110205,20,'CACHCBO::SAUCLK_XXXCX_TBM_NC_08080803_LFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110206,20,'DRGUCLK::DRGUCLK_XXXCX_TBM_NC_08080803_LFM_MIN_0700_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110207,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_GX_08080803_LFM_MIN_0700_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110208,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_NC_08080803_LFM_MIN_0700_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110209,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_NC_08080803_LFM_SPT_0700_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110301,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_950_1253','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110302,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_950_1253_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110303,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1253_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110304,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_950_1253','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110305,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_950_1253_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110306,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_950_1253','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110307,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_950_1253_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110401,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_900_1254','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110402,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_900_1254_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110403,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1254','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110404,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1254_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110405,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_900_1254','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110406,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_900_1254_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110501,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_900_1255','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110502,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_900_1255_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110503,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1255','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110504,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1255_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110505,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_900_1255','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110506,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_900_1255_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110601,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_900_1256','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110602,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_900_1256_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110603,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1256','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110604,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1256_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110605,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_900_1256','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110606,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_900_1256_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110701,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_850_1269_GT2S0V0EU23','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110702,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2M_22222203_TFM_MIN_850_1269_GT2S0V0EU23','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110703,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2M_22222203_TFM_SPT_MIN_850_1269_GT2S0V0EU23','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110801,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_24242403_HFM_MIN_1253','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110802,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_HFM_MIN_2400_1253','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110803,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_HFM_SPT_2400_1253','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110901,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_24242403_HFM_MIN_1254','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110902,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_HFM_MIN_2400_1254','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20110903,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_HFM_SPT_2400_1254','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111001,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_24242403_HFM_MIN_1255','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111002,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_HFM_MIN_2300_1255','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111003,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_HFM_SPT_2300_1255','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111101,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_24242403_HFM_MIN_1269','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111102,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_HFM_MIN_2000_1269','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111103,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_HFM_SPT_2000_1269','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111201,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_24242403_HFM_MIN_1270','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111202,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_HFM_MIN_1900_1270','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111203,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_HFM_SPT_1900_1270','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111301,20,'CACHDE::CACHDE_XXXGX_TBM_DE_08080806_HFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111302,20,'CACHSA::SADFLCLK_XXXXX_TBM_UC_16160806_HFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111303,20,'CACHSA::SAFCLKFLT_XXXXX_SDR_UC_16160806_HFM_MIN_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111304,20,'DEFUNC::DEFUNC_FCLK700__ZZZZZ_TBM_XC_08080806_HFM_MIN_540_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111305,20,'DEFUNC::DEFUNC_FCLK700__ZZZZZ_TBM_XC_08080806_HFM_SPT_MIN_540_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111306,20,'RTLSA::SBFTSA_XXXCX_TBM_NC_08080806_UFM_MIN_0700_1250','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20111307,20,'RTLSA::SBFTSA_XXXCX_TBM_NC_08080806_UFM_SPT_0700_1250','6881','','','','')

	-- ULX
	INSERT INTO GM_D_Features VALUES(20120001,20,'DFF_SORT_IDVFX_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120002,20,'DFF_SORT_RELVBDN_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120003,20,'DFF_SORT_RELVBDP_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120004,20,'DFF_SORT_SICC1_10','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120005,20,'DFF_SORT_SICC1_4','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120006,20,'DFF_SORT_SICC1_9','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120007,20,'DFF_SORT_SICC2_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120008,20,'DFF_SORT_SICC2_12','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120009,20,'DFF_SORT_SICC2_2','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120010,20,'DFF_SORT_SICC2_4','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120011,20,'DFF_SORT_SICC2_7','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120012,20,'DFF_SORT_SICC2_9','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120013,20,'DFF_SORT_SICC3_1','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120014,20,'DFF_SORT_SICC3_10','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120015,20,'DFF_SORT_SICC3_11','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120016,20,'DFF_SORT_SICC3_4','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120017,20,'DFF_SORT_SICC3_8','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120018,20,'DFF_SORT_SICC3_9','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120101,20,'CACHCBO::CBOUCLKL_XXXCX_TBM_NC_24242403_TFM_MIN_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120102,20,'CACHCBO::CBOUCLKN_XXXCX_TBM_NC_24242403_TFM_MIN_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120103,20,'CACHCBO::CBOUCLKNFLT_XXXCX_SDR_NC_32320803_TFM_MIN_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120104,20,'CACHCBO::SAUCLK_XXXCX_TBM_NC_24242403_TFM_MIN_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120105,20,'DRGUCLK::DRGUCLK_XXXCX_TBM_NC_24240803_TFM_MIN_2600_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120106,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_GX_24240803_TFM_MIN_2600_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120107,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_NC_24240803_TFM_MIN_2600_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120108,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_NC_24240803_TFM_SPT_2600_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120201,20,'CACHCBO::CBOUCLKL_XXXCX_TBM_NC_16161603_HFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120202,20,'CACHCBO::CBOUCLKL_XXXCX_TBM_NC_16161603_HFM_MIN_SPLIT_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120203,20,'CACHCBO::CBOUCLKN_XXXCX_TBM_NC_16161603_HFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120204,20,'CACHCBO::CBOUCLKNFLT_XXXCX_SDR_NC_32320803_HFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120205,20,'CACHCBO::SAUCLK_XXXCX_TBM_NC_16161603_HFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120206,20,'DRGUCLK::DRGUCLK_XXXCX_TBM_NC_14140803_HFM_MIN_1200_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120207,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_GX_14140803_HFM_MIN_1200_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120208,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_NC_14140803_HFM_MIN_1200_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120209,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_NC_14140803_HFM_SPT_1200_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120301,20,'CACHCBO::CBOUCLKL_XXXCX_TBM_NC_08080803_LFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120302,20,'CACHCBO::CBOUCLKL_XXXCX_TBM_NC_08080803_LFM_MIN_SPLIT_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120303,20,'CACHCBO::CBOUCLKN_XXXCX_TBM_NC_08080803_LFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120304,20,'CACHCBO::CBOUCLKNFLT_XXXCX_SDR_NC_08080803_LFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120305,20,'CACHCBO::SAUCLK_XXXCX_TBM_NC_08080803_LFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120306,20,'DRGUCLK::DRGUCLK_XXXCX_TBM_NC_08080803_LFM_MIN_0600_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120307,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_GX_08080803_LFM_MIN_0600_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120308,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_NC_08080803_LFM_MIN_0600_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120309,20,'RTLUCLK::SBFTUCLK_XXXCX_TBM_NC_08080803_LFM_SPT_0600_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120401,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_900_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120402,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_900_1262_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120403,20,'DEFUNC::DEFUNC_ZZZZZ_TBM_XC_08080806_TFM_MIN_540_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120404,20,'DEFUNC::DEFUNC_ZZZZZ_TBM_XC_08080806_TFM_SPT_MIN_540_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120405,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120406,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1262_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120407,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_900_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120408,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_900_1262_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120501,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_900_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120502,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_900_1263_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120503,20,'DEFUNC::DEFUNC_ZZZZZ_TBM_XC_08080806_TFM_MIN_540_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120504,20,'DEFUNC::DEFUNC_ZZZZZ_TBM_XC_08080806_TFM_SPT_MIN_540_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120505,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120506,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_900_1263_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120507,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_900_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120508,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_900_1263_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120601,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_850_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120602,20,'CACHGT::CACHGT_XXXGX_TBM_GT_22222203_TFM_MIN_850_1267_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120603,20,'DEFUNC::DEFUNC_ZZZZZ_TBM_XC_08080806_TFM_MIN_540_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120604,20,'DEFUNC::DEFUNC_ZZZZZ_TBM_XC_08080806_TFM_SPT_MIN_540_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120605,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_850_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120606,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_MIN_850_1267_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120607,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_850_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120608,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_22222203_TFM_SPT_MIN_850_1267_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120701,20,'CACHGT::CACHGT_XXXGX_TBM_GT_08080803_HFM_MIN_450_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120702,20,'CACHGT::CACHGT_XXXGX_TBM_GT_08080803_HFM_MIN_450_1262_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120703,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_08080803_HFM_MIN_450_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120704,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_08080803_HFM_MIN_450_1262_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120705,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_08080803_HFM_SPT_MIN_450_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120706,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_08080803_HFM_SPT_MIN_450_1262_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120801,20,'CACHGT::CACHGT_XXXGX_TBM_GT_08080403_LFM_MIN_100_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120802,20,'CACHGT::CACHGT_XXXGX_TBM_GT_08080403_LFM_MIN_100_1262_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120803,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_08080403_LFM_MIN_100_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120804,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_08080403_LFM_MIN_100_1262_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120805,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_08080403_LFM_SPT_MIN_100_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120806,20,'RTLGCLK::RTLGCLK_XXXGX_TBM_2H_08080403_LFM_SPT_MIN_100_1262_GT2S0V0EU24','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120901,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_32323203_TFM_MIN_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120902,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_30300803_TFM_MIN_2700_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20120903,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_30300803_TFM_SPT_2700_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121001,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_24242403_TFM_MIN_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121002,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_30300803_TFM_MIN_2600_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121003,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_30300803_TFM_SPT_2600_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121101,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_24242403_TFM_MIN_1274','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121102,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_TFM_MIN_2400_1274','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121103,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_20200803_TFM_SPT_2400_1274','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121201,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_16161603_HFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121202,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_12120803_HFM_MIN_1200_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121203,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_12120803_HFM_SPT_1200_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121301,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_12121203_HFM_MIN_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121302,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_12120803_HFM_MIN_1100_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121303,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_12120803_HFM_SPT_1100_1263','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121401,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_12121203_HFM_MIN_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121402,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_12120803_HFM_MIN_1100_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121403,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_12120803_HFM_SPT_1100_1267','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121501,20,'CACHCORE::COREMCLK_XXXCX_TBM_NC_12121203_HFM_MIN_1268','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121502,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_12120803_HFM_MIN_1000_1268','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121503,20,'RTLMCLK::SBFTMCLK_XXXCX_TBM_NC_12120803_HFM_SPT_1000_1268','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121601,20,'CACHDE::CACHDE_XXXGX_TBM_DE_08080806_HFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121602,20,'CACHSA::SADFLCLK_XXXXX_TBM_UC_16160806_HFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121603,20,'CACHSA::SAFCLKFLT_XXXXX_SDR_UC_16160806_HFM_MIN_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121604,20,'DEFUNC::DEFUNC_ZZZZZ_TBM_XC_08080806_HFM_MIN_337_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121605,20,'DEFUNC::DEFUNC_ZZZZZ_TBM_XC_08080806_HFM_SPT_MIN_337_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121606,20,'RTLSA::SBFTSA_XXXCX_TBM_NC_08080806_UFM_MIN_0500_1262','6881','','','','')
	INSERT INTO GM_D_Features VALUES(20121607,20,'RTLSA::SBFTSA_XXXCX_TBM_NC_08080806_UFM_SPT_0500_1262','6881','','','','')

------------------------------------- Config ModelingFeatures ------------------------------------------

-- ModelGroupLevel
	-- ULT
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110005,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110009,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110012,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110101,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110102,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110103,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110104,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110105,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110106,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110107,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110108,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201101,20,20110109,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110007,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110011,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110201,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110202,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110203,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110204,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110205,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110206,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110207,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110208,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201102,20,20110209,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110004,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110007,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110013,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110301,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110302,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110303,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110304,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110305,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110306,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201103,20,20110307,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110002,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110004,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110007,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110401,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110402,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110403,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110404,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110405,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201104,20,20110406,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110002,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110004,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110013,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110501,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110502,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110503,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110504,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110505,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201105,20,20110506,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110002,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110004,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110011,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110601,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110602,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110603,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110604,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110605,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201106,20,20110606,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201107,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201107,20,20110006,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201107,20,20110010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201107,20,20110012,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201107,20,20110014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201107,20,20110701,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201107,20,20110702,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201107,20,20110703,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201108,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201108,20,20110003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201108,20,20110008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201108,20,20110011,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201108,20,20110014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201108,20,20110801,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201108,20,20110802,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201108,20,20110803,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201109,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201109,20,20110008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201109,20,20110011,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201109,20,20110012,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201109,20,20110014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201109,20,20110901,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201109,20,20110902,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201109,20,20110903,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201110,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201110,20,20110008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201110,20,20110011,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201110,20,20110012,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201110,20,20110014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201110,20,20111001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201110,20,20111002,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201110,20,20111003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201111,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201111,20,20110008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201111,20,20110011,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201111,20,20110012,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201111,20,20110014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201111,20,20111101,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201111,20,20111102,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201111,20,20111103,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201112,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201112,20,20110003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201112,20,20110008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201112,20,20110011,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201112,20,20110014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201112,20,20111201,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201112,20,20111202,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201112,20,20111203,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20110001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20110003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20110008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20110011,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20110014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20111301,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20111302,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20111303,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20111304,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20111305,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20111306,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201113,20,20111307,GETDATE(),1)

	--ULX
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120012,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120017,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120101,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120102,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120103,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120104,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120105,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120106,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120107,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201201,20,20120108,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120018,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120201,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120202,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120203,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120204,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120205,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120206,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120207,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120208,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201202,20,20120209,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120006,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120015,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120018,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120301,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120302,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120303,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120304,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120305,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120306,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120307,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120308,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201203,20,20120309,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120002,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120005,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120018,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120401,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120402,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120403,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120404,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120405,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120406,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120407,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201204,20,20120408,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120009,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120011,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120501,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120502,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120503,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120504,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120505,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120506,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120507,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201205,20,20120508,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120005,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120007,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120018,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120601,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120602,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120603,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120604,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120605,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120606,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120607,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201206,20,20120608,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120013,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120701,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120702,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120703,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120704,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120705,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201207,20,20120706,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120015,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120018,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120801,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120802,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120803,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120804,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120805,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201208,20,20120806,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201209,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201209,20,20120004,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201209,20,20120008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201209,20,20120010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201209,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201209,20,20120901,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201209,20,20120902,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201209,20,20120903,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201210,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201210,20,20120002,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201210,20,20120008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201210,20,20120010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201210,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201210,20,20121001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201210,20,20121002,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201210,20,20121003,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201211,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201211,20,20120005,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201211,20,20120007,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201211,20,20120008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201211,20,20120015,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201211,20,20121101,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201211,20,20121102,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201211,20,20121103,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201212,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201212,20,20120008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201212,20,20120010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201212,20,20120014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201212,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201212,20,20121201,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201212,20,20121202,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201212,20,20121203,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201213,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201213,20,20120008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201213,20,20120010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201213,20,20120014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201213,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201213,20,20121301,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201213,20,20121302,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201213,20,20121303,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201214,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201214,20,20120010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201214,20,20120014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201214,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201214,20,20120018,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201214,20,20121401,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201214,20,20121402,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201214,20,20121403,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201215,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201215,20,20120010,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201215,20,20120014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201215,20,20120016,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201215,20,20120018,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201215,20,20121501,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201215,20,20121502,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201215,20,20121503,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20120001,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20120005,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20120008,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20120014,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20120018,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20121601,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20121602,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20121603,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20121604,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20121605,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20121606,GETDATE(),1)
	INSERT INTO GM_F_ModelingFeatures VALUES(201216,20,20121607,GETDATE(),1)


------------------------------------------------------------------------------------------------------------------------
/*									Configure Indicators															*/
-----------------------------------------------------------------------------------------------------------------------

---------------------------------------- IndicatorCalculatedFields ----------------------------------------------------------
-- I represtns a ranking index for all the rows in the partition. 
-- N represnts one row from the partition.
-- The condition I=N as seen bellow means that we select only one row from a certain partition

INSERT INTO [GM_D_IndicatorCalculatedFields] VALUES (3,'RANK() OVER  (PARTITION BY Test_Program,ModelID,UnitID,WW,Test_Date ORDER BY Test_Program,ModelID,UnitID,FeatureID)','I')
INSERT INTO [GM_D_IndicatorCalculatedFields] VALUES (4,'COUNT(*) OVER (PARTITION BY  Test_Program,ModelID,UnitID,WW,Test_Date)','N')

---------------------------------------------- Indicators ----------------------------------------------------------
-- Test_Program, ModelID
INSERT INTO [GM_D_Indicators] VALUES (4,'Vmin_SUM','SUM(CASE WHEN I=N THEN Model_MaxValue ELSE NULL END)','3,4')
INSERT INTO [GM_D_Indicators] VALUES (5,'Vmin_CNT','SUM(CASE WHEN I=N THEN 1 ELSE 0 END)','3,4')
INSERT INTO [GM_D_Indicators] VALUES (6,'Vmin_SUMsq','SUM(CASE WHEN I=N THEN Model_MaxValue*Model_MaxValue ELSE NULL END)','3,4')
INSERT INTO [GM_D_Indicators] VALUES (7,'Steps_WP_CNT','SUM(Feature_Step)',NULL)
INSERT INTO [GM_D_Indicators] VALUES (8,'Potential_OS_CNT','SUM(CASE WHEN Model_PotentialOS=1 AND I=N THEN 1 ELSE 0 END) ','3,4')
INSERT INTO [GM_D_Indicators] VALUES (9,'Certain_OS_CNT','SUM(CASE WHEN Model_CertainOS=1 AND I=N THEN 1 ELSE 0 END) ','3,4')
INSERT INTO [GM_D_Indicators] VALUES (10,'Total_OS_CNT','SUM(CASE WHEN Model_CertainOS+Model_PotentialOS=2 AND I=N THEN 2 WHEN Model_CertainOS+Model_PotentialOS=1 AND I=N THEN 1 ELSE 0 END)','3,4')
INSERT INTO [GM_D_Indicators] VALUES (11,'Prediction_Calculated_CNT','SUM(CASE WHEN ISNUMERIC(Model_Prediction)=1 AND I=N THEN 1 ELSE 0 END) ','3,4')
INSERT INTO [GM_D_Indicators] VALUES (12,'Prediction_Used_CNT','SUM(CASE WHEN Model_Prediction=Feature_MinValue THEN 1 ELSE 0 END)',NULL)
INSERT INTO [GM_D_Indicators] VALUES (13,'Prediction_Justified_Unused_CNT','SUM(CASE WHEN Feature_MinValue>Model_Prediction THEN 1 ELSE 0 END)',NULL)
INSERT INTO [GM_D_Indicators] VALUES (14,'Prediction_Unjustified_Unused_CNT','SUM(CASE WHEN Feature_MinValue<Model_Prediction AND Feature_MinValue+Feature_GB>=Model_Prediction THEN 1 ELSE 0 END)',NULL)
INSERT INTO [GM_D_Indicators] VALUES (15,'Prediction_Unexplained_Unused_CNT','SUM(CASE WHEN Feature_MinValue<Model_Prediction AND Feature_MinValue+Feature_GB<Model_Prediction THEN 1 ELSE 0 END)',NULL)
INSERT INTO [GM_D_Indicators] VALUES (16,'TestsResults_CNT','COUNT(*)',NULL)

---------------------------------------- IndicatorLevels ----------------------------------------------------------
-- Test_Program, ModelID
INSERT INTO [GM_D_IndicatorLevels] VALUES (4, 1 ,'Test_Program')
INSERT INTO [GM_D_IndicatorLevels] VALUES (4, 2 ,'ModelID')
INSERT INTO [GM_D_IndicatorLevels] VALUES (4, 3 ,'WW')
INSERT INTO [GM_D_IndicatorLevels] VALUES (4, 4 ,'Test_Date')

---------------------------------------- Model Indicator ----------------------------------------------------------
-- Test_Program, ModelID
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,4,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,5,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,6,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,7,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,8,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,9,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,10,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,11,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,12,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,13,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,14,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,15,'4')
INSERT INTO [GM_F_ModelIndicators] VALUES (20,-1,-1,4,16,'4')
