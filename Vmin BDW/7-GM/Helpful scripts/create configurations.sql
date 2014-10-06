------------------------------------------------------------------------------------------------------------------------
/*									 User Configurations and actions													*/
-----------------------------------------------------------------------------------------------------------------------
-- modify to the relevant DB
USE MPDExploration 
GO

-- Create a Clustered index on the ClassTests
--CREATE CLUSTERED INDEX  INDEX_VM2F_BDU_CLASS_UX_EXP_WW34B_CLASSTESTS_SELECTED ON VM2F_BDU_CLASS_UX_EXP_WW34B_CLASSTESTS_SELECTED (GROUPID,TESTID);

-- create a #ClassTests table
IF OBJECT_ID('tempdb..#ClassTests') IS NOT NULL
	DROP TABLE #ClassTests

IF OBJECT_ID('tempdb..#ClassTestsSummary') IS NOT NULL
	DROP TABLE #ClassTestsSummary

IF OBJECT_ID('tempdb..#TargetData') IS NOT NULL
	DROP TABLE #TargetData

SELECT * 
INTO #ClassTests
FROM VM2F_BDU_CLASS_UX_EXP_WW34_CLASSTESTS_SELECTED

SELECT * 
INTO #ClassTestsSummary
FROM VM2F_BDU_Class_UX_ClassTestsSummary

SELECT * 
INTO #TargetData
FROM VM2F_BDU_Class_UX_TargetData
----------------
DECLARE  
		-- Per solution
		 @SolutionID VARCHAR(MAX)='20'	
		,@OPERATION VARCHAR(MAX)='6881'
		,@PRODUCT VARCHAR(MAX)='BDW'
		,@PRODUCTOPERATION VARCHAR(MAX)='CLASS'
		,@PACKAGE VARCHAR(MAX)='All'		
		,@GenericColumn VARCHAR(MAX)=''
		,@ISBACKGROUND VARCHAR(MAX)='0'
		,@ISPRODUCTION VARCHAR(MAX)='1'
		,@ISINDICATORS VARCHAR(MAX)='1' 
		,@NumDFFInEQ INT=5 -- a const number for numbering features
		,@DomainCornerFlow_ParameterID VARCHAR(MAX)='116' --Domain_Corner_Flow
		,@DomainCornerBin_ParameterID VARCHAR(MAX)='117'
		,@VminBaseline_ParameterID VARCHAR(MAX)='121'
		,@NumOfSteps_ParameterID VARCHAR(MAX)='122'
		,@DataPreparationSP_parameterID VARCHAR(MAX)='23'
		,@DataPreparationSPname VARCHAR(MAX)='USP_VM2F_BDU_Class_Indicators_DataPreparation'

		-- Per ModelGroup
		,@ModelGroupID VARCHAR(MAX)='2012'
		,@ProductID INT=7
		,@VERSION VARCHAR(MAX)='ULX'
		,@DIESTRUCTURE VARCHAR(MAX)='2+2'

------------------------------------------------------------------------------------------------------------------------
/*									 run script from here on (no extra actions are needed)							*/
-----------------------------------------------------------------------------------------------------------------------		
				
------------------------------------------------------------------------------------------------------------------------
/*									 Create Configurations Table													*/
-----------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#ConfigurationTable') IS NOT NULL
	DROP TABLE #ConfigurationTable

SELECT  SolutionID=@SolutionID
	   ,ModelGroupID=@ModelGroupID
	   ,ModelID=@ModelGroupID+
				   RIGHT('00000'+CONVERT(varchar(max),DENSE_RANK() OVER (Order by Res3.groupID)),2)
	   --,GroupID
		,FeatureID= CASE WHEN TestType='DFF' THEN @ModelGroupID+'00'+ID
											 ELSE @ModelGroupID+
															   RIGHT('00000'+CONVERT(varchar(max),DENSE_RANK() OVER (Order by Res3.GroupID)),2)+
															   RIGHT('00000'+CONVERT(varchar(max),DENSE_RANK() OVER (PARTITION BY Res3.GroupID ORDER BY ID)-@NumDFFInEQ),2)
											 END

		,TestName
		,TestType
		,Res3.Domain
		,Res3.Corner
		,Bin=Res3.Flow 
		,Flow= CONVERT(VARCHAR(MAX),CF.Flow)
		,Vmin_Baseline
		,NumOfSteps_Baseline
INTO #ConfigurationTable
FROM(
	SELECT  distinct GroupID
			,ID
			,Res1.TestName
			,TestType='DFF'
			,Domain=NUll
			,Corner=NULL
			,Flow=NULL
	FROM(
		SELECT DISTINCT  TestName= SUBSTRING(Value,1,CASE WHEN CHARINDEX('+',Value)>0 THEN CHARINDEX('+',Value)-1 ELSE LEN(Value) END)
						,ID=RIGHT('0000'+ convert(varchar(MAX),DENSE_RANK() OVER (ORDER BY SUBSTRING(Value,1,CASE WHEN CHARINDEX('+',Value)>0 THEN CHARINDEX('+',Value)-1 ELSE LEN(Value) END))),2)

		FROM #ClassTests
		CROSS APPLY dbo.UDF_GetStringTableFromList_New(Equation,'*',NULL)
		where place>1
	)Res1
	INNER JOIN #ClassTests Res2
	ON (Res2.Equation LIKE '%'+Res1.TestName)
	OR (Res2.Equation LIKE '%'+Res1.TestName+'+%')
	UNION
	SELECT  groupID
		   ,ID=convert(varchar(max),TestID)
		   ,TestName
		   ,TestType='Vmin'
		   ,Domain
		   ,Corner
		   ,Flow
	FROM #ClassTests
) Res3
LEFT JOIN VM2F_BDU_Class_Flows CF
ON CF.Bin=Res3.Flow
AND CF.ProductID=@ProductID
INNER JOIN 
	(SELECT DISTINCT  Res1.GroupID
					,Vmin_Baseline=CAST(Vmin_Baseline AS decimal(18,2))
					,NumOfSteps_Baseline=CAST(CTS.AVG_STEPS_NP AS decimal(18,2))

	from(
		SELECT groupID, Vmin_Baseline=AVG(TargetValue)
		FROM #TargetData
		GROUP BY GroupID
	)Res1
	INNER JOIN #ClassTestsSummary CTS
	ON Res1.GroupID=CTS.GroupID
)Res4
ON Res4.GroupID=Res3.GroupID

------------------------------------------------------------------------------------------------------------------------
/*									 Create Configurations script													*/
-----------------------------------------------------------------------------------------------------------------------

-------------------------------------------- GM_D_Models -------------------------------------------------------

-- Create Models
SELECT GM_D_Models='INSERT INTO GM_D_Models VALUES('+ModelID+','+SolutionID+','''+Product+''','''+Operation+''','''+DieStructure+''','''+Package+''','''+[Version]+''','''+GenericColumn+''','+ModelGroupID+','+IsBackground+','+IsProduction+','+IsIndicators+')'
FROM(
	select   distinct 
			 ModelID
			,SolutionID
			,Product=@Product
			,Operation=@ProductOperation
			,DieStructure=@DieStructure
			,Package=@Package
			,[Version]=@Version
			,GenericColumn=@GenericColumn
			,ModelGroupID
			,IsBackground=@IsBackground
			,IsProduction=@IsProduction
			,IsIndicators=@IsIndicators
	from #ConfigurationTable
) Res1

-------------------------------------------- GM_F_ModelingParameters -------------------------------------------------------
-- Create the Domain_Corner_Flow values
SELECT Domain_Corner_Flow='INSERT INTO [GM_F_ModelingParameters] VALUES('+SolutionID+','+ModelGroupID+','+ModelID+','+FeatureID+','+ParameterID+','''+Value+''')'
FROM(
	SELECT DISTINCT
		 SolutionID
		,ModelGroupID
		,ModelID
		,FeatureID='NULL'
		,ParameterID=@DomainCornerFlow_ParameterID
		,Value=Domain+'_'+Corner+'_'+Flow
	FROM #ConfigurationTable
	WHERE TestType='Vmin')
Res1

-- Create the Domain_Corner_Bin values
SELECT Domain_Corner_Bin='INSERT INTO [GM_F_ModelingParameters] VALUES('+SolutionID+','+ModelGroupID+','+ModelID+','+FeatureID+','+ParameterID+','''+Value+''')'
FROM(
	SELECT DISTINCT
		 SolutionID
		,ModelGroupID
		,ModelID
		,FeatureID='NULL'
		,ParameterID=@DomainCornerBin_ParameterID
		,Value=Domain+'_'+Corner+'_'+Bin
	FROM #ConfigurationTable
	WHERE TestType='Vmin')
Res1

-- Create DataPreparation statment
SELECT DataPreparation='INSERT INTO [GM_F_ModelingParameters] VALUES ('+SolutionID+','+ModelGroupID+','+ModelID+',NULL,'+Parameter+','''+SPname+' @SolutionID='+SolutionID+', @ModelGroupID='+ModelGroupID+', @ModelID='+ModelID+''')' --the indicators data preparation SP'
FROM
(
	SELECT DISTINCT
		 SolutionID
		,ModelGroupID
		,ModelID
		,Parameter=@DataPreparationSP_parameterID
		,SPname=@DataPreparationSPname
    FROM #ConfigurationTable
)
Res1	
 
 -- Vmin Baseline
SELECT Vmin_Baseline='INSERT INTO [GM_F_ModelingParameters] VALUES ('+SolutionID+','+ModelGroupID+','+ModelID+',NULL,'+Parameter+','''+Vmin_Baseline+''')'
FROM
(
	SELECT DISTINCT
		 SolutionID
		,ModelGroupID
		,ModelID
		,Parameter=@VminBaseline_ParameterID
		,Vmin_Baseline=CAST(Vmin_Baseline AS varchar(max))
    FROM #ConfigurationTable
)
Res1	

 -- Number Of Steps Baseline
SELECT NumOfSteps_Baseline='INSERT INTO [GM_F_ModelingParameters] VALUES ('+SolutionID+','+ModelGroupID+','+ModelID+',NULL,'+Parameter+','''+NumOfSteps_Baseline+''')'
FROM
(
	SELECT DISTINCT
		 SolutionID
		,ModelGroupID
		,ModelID
		,Parameter=@NumOfSteps_ParameterID
		,NumOfSteps_Baseline=CAST(NumOfSteps_Baseline AS varchar(max))
    FROM #ConfigurationTable
)
Res1	
-------------------------------------------- GM_D_Features -------------------------------------------------------
SELECT GM_D_Features='INSERT INTO GM_D_Features VALUES('+FeatureID+','+SolutionID+','''+TestName+''','''+Operation+''','''+SourceTable+''','''+Categorizing_Value+''','''+Distinctive_Value+''','''+XMLTestCaption+''')'
FROM(

	select   FeatureID
			,SolutionID
			,TestName
			,Operation=@Operation
			,SourceTable=''
			,Categorizing_Value=''
			,Distinctive_Value=''
			,XMLTestCaption=''
	from #ConfigurationTable
	where TestType='Vmin'
	UNION
	SELECT DISTINCT
			 FeatureID
			,SolutionID
			,TestName
			,Operation=@Operation
			,SourceTable=''
			,Categorizing_Value=''
			,Distinctive_Value=''
			,XMLTestCaption=''
	from #ConfigurationTable
	where TestType='DFF'

) Res1

-------------------------------------------- GM_F_ModelingFeatures -------------------------------------------------------
SELECT	GM_F_ModelingFeatures='INSERT INTO GM_F_ModelingFeatures VALUES('+ModelID+','+SolutionID+','+FeatureID+','+UpdateTimestamp+','+IsActive+')'
FROM(
	select   ModelID
			,SolutionID
			,FeatureID
			,UpdateTimestamp='GETDATE()'
			,IsActive='1'
	from #ConfigurationTable
) Res1


