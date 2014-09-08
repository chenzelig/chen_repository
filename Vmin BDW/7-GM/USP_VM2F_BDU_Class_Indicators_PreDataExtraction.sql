	
USE MFG_Solutions
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_Indicators_PreDataExtraction]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_Indicators_PreDataExtraction]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------

CREATE PROCEDURE USP_VM2F_BDU_Class_Indicators_PreDataExtraction  
		@SolutionID INT
	   ,@ModelGroupID INT

AS 

BEGIN TRY 

	DECLARE @SQL VARCHAR(MAX)=NULL   
		   ,@ImportQuery VARCHAR(MAX)=NULL
		   ,@ParameterValue VARCHAR(MAX)=NULL
		   ,@FailPoint VARCHAR(MAX)=NULL
		   ,@DaysBack INT=NULL
		   ,@DaysToImport INT=NULL


	SET @FailPoint='1'

	
	------------------------------------------------------------------------------------------
	/*								select Import query										*/
	------------------------------------------------------------------------------------------
    SELECT @ImportQuery=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ModelGroupID=@ModelGroupID
	AND ParameterID=20 -- Import Query

	------------------------------------------------------------------------------------------
	/*								update Import querys generic fields						*/
	------------------------------------------------------------------------------------------

	------------------------------- Operation -------------------------------
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=100 	

    SELECT @SQL='MLOTS.Operation='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<Operation>>',@SQL)

	
	--------------------------------- SumTested -------------------------------
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=101

	SET @ImportQuery=REPLACE(@ImportQuery,'<<SumTested>>',@ParameterValue)

	------------------------------- MLOTS_LATO_Valid_Flag -------------------------------
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=102	

    SELECT @SQL='MLOTS.LATO_Valid_Flag='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MLOTS_LATO_Valid_Flag>>',@SQL)

	------------------------------- MLOTS_LOTS_Complete_Flag -------------------------------
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=103	

    SELECT @SQL='MLOTS.LOTS_Complete_Flag='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MLOTS_LOTS_Complete_Flag>>',@SQL)

	------------------------------- MUTB_LATO_Valid_Flag -------------------------------
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=104	

    SELECT @SQL='MUTB.LATO_Valid_Flag='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MUTB_LATO_Valid_Flag>>',@SQL)

	------------------------------- MUTB_Within_LOTS_Latest_Flag -------------------------------
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=105	

    SELECT @SQL='MUTB.Within_LOTS_Latest_Flag='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MUTB_Within_LOTS_Latest_Flag>>',@SQL)

	------------------------------- Temperature -------------------------------
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=106	

    SELECT @SQL='MLOTS.LOTS_Temperature='+@ParameterValue+''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<Temperature>>',@SQL)

	------------------------------- Summary_Letter -------------------------------
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=107	

    SELECT @SQL='MLOTS.Summary_Letter='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<Summary_Letter>>',@SQL)

	------------------------------- SubStructure_ID -------------------------------
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=108	

    SELECT @SQL='MUTB.SubStructure_ID='''+@ParameterValue+''''
	SET @ImportQuery=REPLACE(@ImportQuery,'<<SubStructure_ID>>',@SQL)

	------------------------------- Test_Program_Pattern ------------------------------
	SET	@ParameterValue=NULL

	SELECT @ParameterValue=ISNULL(@ParameterValue,'')+Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID IN (109,110,111) --Test Program Pattern
	ORDER BY ParameterID

	SET @SQL='MLOTS.Program_Or_BI_Recipe_Name LIKE '''+@ParameterValue+'%'''
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<Test_Program_Pattern>>',@SQL)

	------------------------------- Values To Ignore ------------------------------
	SET	@ParameterValue=NULL

	SELECT @ParameterValue=ISNULL( @ParameterValue+' AND MLOTS.Program_Or_BI_Recipe_Name NOT LIKE ''%'+RES.Value+'%''','(MLOTS.Program_Or_BI_Recipe_Name NOT LIKE ''%'+RES.Value+'%'' ')
	FROM #ATM_GM_ModelingParameters MP
	CROSS APPLY dbo.UDF_GetStringTableFromList_New(Value,',',NULL) RES
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=112

	SET @SQL=CASE WHEN @ParameterValue!='' THEN @ParameterValue+')' ELSE '1=1' END
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<ValuesToIgnore>>',@SQL)
			
	 ------------------------------- DateRange -------------------------------

	SELECT @DaysBack=CAST(value AS int)
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=113 -- days back

	SELECT @DaysToImport=CAST(value AS int)
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=114 -- days To Import

	
	SELECT @SQL='CAST(MLOTS.LOTS_Start_Date_Time AS DATE) BETWEEN  current_date -interval '''+CAST((@DaysBack+@DaysToImport) AS varchar(max))
	+'''day AND  current_date -interval '''+CAST(@DaysBack as varchar(max))+'''day'

	SET @ImportQuery=REPLACE(@ImportQuery,'<<DateRange>>',@SQL)

	------------------------------- wip_env_id ------------------------------
	SET	@ParameterValue=NULL

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters MP
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=118
	
	SET @SQL=CASE WHEN @ParameterValue='1' THEN 'wip_env_id IS NOT NULL' ELSE '1=1' END
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<wip_env_id>>',@SQL)

	------------------------------- DevRevStep_Template ------------------------------
	SET	@ParameterValue=NULL

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters MP
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=119
	
	SET @SQL=CASE WHEN @ParameterValue!='' THEN 'MLOTS.DevRevStep like '''+@ParameterValue+'''' ELSE '1=1' END
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<DevRevStep_Template>>',@SQL)

	------------------------------- Facility_to_Ignore ------------------------------
	SET	@ParameterValue=NULL

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters MP
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=120

	SET @SQL=CASE WHEN @ParameterValue!='' THEN 'MLOTS.Facility NOT IN ('''+REPLACE(@ParameterValue,',',''',''')+''')' ELSE '1=1' END
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<Facility_to_Ignore>>',@SQL)


	------------------------------------------------------------------------------------------
	/*								update Test Names										*/
	------------------------------------------------------------------------------------------

	------------------------------- Test_Name Vmin Test -------------------------------

	SET @ParameterValue=NULL

	SELECT @ParameterValue= ISNULL(@ParameterValue+',','')+''''+Test_Name+''''
	FROM GM_D_Features F
	INNER JOIN [dbo].[GM_F_ModelingFeatures] MF
	ON F.SolutionID=MF.SolutionID
	AND F.FeatureID=MF.FeatureID
	AND f.SolutionID=@SolutionID
	AND f.Test_Name NOT LIKE 'DFF_%'
	INNER JOIN [dbo].[GM_D_Models] M
	on M.SolutionID=MF.SolutionID
	AND M.ModelID=MF.ModelID
	AND M.ModelGroupID=@ModelGroupID
	
	SELECT @SQL='MTL.Test_Name IN ('+@ParameterValue+')'
	SET @ImportQuery=REPLACE(@ImportQuery,'<<Test_Name Vmin Test>>',@SQL)

	------------------------------- Test_Name Prediction DFF -------------------------------

	SET @ParameterValue=NULL

	SELECT @ParameterValue= ISNULL(@ParameterValue+',','')+''''+Test_Name+''''
	FROM GM_D_Features
	WHERE SolutionID=@SolutionID
	AND Test_Name like 'DFF_PBIC%'

	 SELECT @SQL='MTL.Test_Name IN('+@ParameterValue+')'
	 SET @ImportQuery=REPLACE(@ImportQuery,'<<Test_Name Prediction DFF>>',@SQL)

	------------------------------------------------------------------------------------------
	/*				update #ATM_GM_ModelingParameters Import query field					*/
	------------------------------------------------------------------------------------------

	UPDATE #ATM_GM_ModelingParameters
	SET Value=@ImportQuery
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ModelGroupID=@ModelGroupID
	AND ParameterID=20

END TRY
BEGIN CATCH  	
	PRINT ('Fail Point: '+ @FailPoint + ' - ' + ERROR_MESSAGE())
END CATCH 
GO
