DECLARE  @SOLUTIONID VARCHAR(MAX)='20'
		,@MODELGROUPID VARCHAR(MAX)='2011'
		,@OPERATION VARCHAR(MAX)='6881'
		,@PRODUCT VARCHAR(MAX)='BDW'
		,@PRODUCTOPERATION VARCHAR(MAX)='CLASS'
		,@DIESTRUCTURE VARCHAR(MAX)='2+2'
		,@PACKAGE VARCHAR(MAX)='All'
		,@VERSION VARCHAR(MAX)='ULT'
		,@GenericColumn VARCHAR(MAX)=''
		,@ISBACKGROUND VARCHAR(MAX)='0'
		,@ISPRODUCTION VARCHAR(MAX)='1'
		,@ISINDICATORS VARCHAR(MAX)='1'
		,@NumDFFInEQ INT=5


SELECT  
	    FeatureID=@MODELGROUPID+'99'+RIGHT('0000'+CONVERT(VARCHAR(MAX),DENSE_RANK() OVER (ORDER BY testName)),2)
	   ,SolutionID=@SOLUTIONID
	   ,testName
	   ,Operation=@Operation
	   ,SourceTable=''
	   ,Categorizing_Value=''
	   ,Distinctive_Value=''
	   ,XMLTestCaption=''

INTO #Temp 
FROM [VM2F_BDU_Class_UT_Exp_WW34_Orig_WP_TestData]
where testName LIKE 'DFF_%'

SELECT GM_D_Features='INSERT INTO GM_D_Features VALUES('+FeatureID+','+SolutionID+','''+TestName+''','''+Operation+''','''+SourceTable+''','''+Categorizing_Value+''','''+Distinctive_Value+''','''+XMLTestCaption+''')'
FROM #Temp
