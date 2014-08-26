
--[DBO].[VM2F_BDU_CLASS_UX_EXP_WW34B_CLASSTESTS_SELECTED]
--[DBO].[VM2F_BDU_CLASS_UT_EXP_WW34B_CLASSTESTS_SELECTED]


--CREATE CLUSTERED INDEX  INDEX_VM2F_BDU_CLASS_UT_EXP_WW34B_CLASSTESTS_SELECTED ON VM2F_BDU_CLASS_UT_EXP_WW34B_CLASSTESTS_SELECTED (GROUPID,TESTID);

--SELECT * 
--INTO #TEMP
--FROM VM2F_BDU_CLASS_UT_EXP_WW34B_CLASSTESTS_SELECTED

DROP TABLE #temp
----------------
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

-------------------------
SELECT  SolutionID=@SolutionID
	   ,ModelGroupID=@ModelGroupID
	   ,ModelID=@ModelGroupID+
				   RIGHT('00000'+CONVERT(varchar(max),DENSE_RANK() OVER (Order by GroupID)),2)
	   --,GroupID
		,FeatureID= CASE WHEN TestType='DFF' THEN @ModelGroupID+'00'+ID
											 ELSE @ModelGroupID+
															   RIGHT('00000'+CONVERT(varchar(max),DENSE_RANK() OVER (Order by GroupID)),2)+
															   RIGHT('00000'+CONVERT(varchar(max),DENSE_RANK() OVER (PARTITION BY GroupID ORDER BY ID)-@NumDFFInEQ),2)
											 END

		,TestName
		,TestType
INTO #Temp
FROM(
	SELECT  distinct GroupID
			,ID
			,Res1.TestName
			,TestType='DFF'
	FROM(
		SELECT DISTINCT  TestName= SUBSTRING(Value,1,CASE WHEN CHARINDEX('+',Value)>0 THEN CHARINDEX('+',Value)-1 ELSE LEN(Value) END)
						,ID=RIGHT('0000'+ convert(varchar(MAX),DENSE_RANK() OVER (ORDER BY SUBSTRING(Value,1,CASE WHEN CHARINDEX('+',Value)>0 THEN CHARINDEX('+',Value)-1 ELSE LEN(Value) END))),2)

		FROM VM2F_BDU_CLASS_UT_EXP_WW34B_CLASSTESTS_SELECTED
		CROSS APPLY dbo.UDF_GetStringTableFromList_New(Equation,'*',NULL)
		where place>1
	)Res1
	INNER JOIN VM2F_BDU_CLASS_UT_EXP_WW34B_CLASSTESTS_SELECTED Res2
	ON (Res2.Equation LIKE '%'+Res1.TestName)
	OR (Res2.Equation LIKE '%'+Res1.TestName+'+%')
	UNION
	SELECT  groupID
		   ,ID=convert(varchar(max),TestID)
		   ,TestName
		   ,TestType='Vmin'
	FROM VM2F_BDU_CLASS_UT_EXP_WW34B_CLASSTESTS_SELECTED
) Res3


--------
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
	from #Temp
) Res1

-----------------
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
	from #Temp
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
	from #Temp
	where TestType='DFF'

) Res1

----------------------------
SELECT	GM_F_ModelingFeatures='INSERT INTO GM_F_ModelingFeatures VALUES('+ModelID+','+SolutionID+','+FeatureID+','+UpdateTimestamp+','+IsActive+')'
FROM(
	select   ModelID
			,SolutionID
			,FeatureID
			,UpdateTimestamp='GETDATE()'
			,IsActive='1'
	from #Temp
) Res1

