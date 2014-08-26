	
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

	SET @FailPoint='1'

    SELECT @ImportQuery=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ModelGroupID=@ModelGroupID
	AND ParameterID=20 -- Import Query


	-- Program_Or_BI_Recipe_Name
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=109

	SET @SQL=NULL
    SELECT @SQL=ISNULL(@SQL+' OR Program_Or_BI_Recipe_Name LIKE ','(Program_Or_BI_Recipe_Name LIKE ')+''''+'%'+value+'%'+''''
	FROM UDF_GetStringTableFromList_New(@ParameterValue,',',NULL)

	SET @SQL=@SQL+') ' 
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<Program_Or_BI_Recipe_Name>>',@SQL)

		
	-- Operation
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=100 	

	SET @SQL=NULL
    SELECT @SQL='Operation='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<Operation>>',@SQL)

	
	-- SumTested
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=101

	SET @SQL=NULL
    SELECT @SQL='sum(Total_Tested)>'+@ParameterValue

	SET @ImportQuery=REPLACE(@ImportQuery,'<<SumTested>>',@SQL)

	
	-- MLOTS_LATO_Valid_Flag
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=102	

	SET @SQL=NULL
    SELECT @SQL='MLOTS_LATO_Valid_Flag='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MLOTS_LATO_Valid_Flag>>',@SQL)

	-- MLOTS_LOTS_Complete_Flag
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=103	

	SET @SQL=NULL
    SELECT @SQL='MLOTS_LOTS_Complete_Flag='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MLOTS_LOTS_Complete_Flag>>',@SQL)

	-- MUTB_LATO_Valid_Flag
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=104	

	SET @SQL=NULL
    SELECT @SQL='MUTB_LATO_Valid_Flag='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MUTB_LATO_Valid_Flag>>',@SQL)

	-- MUTB_Within_LOTS_Latest_Flag
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=105	

	SET @SQL=NULL
    SELECT @SQL='MUTB_Within_LOTS_Latest_Flag='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MUTB_Within_LOTS_Latest_Flag>>',@SQL)

	-- Temperture
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=106	

	SET @SQL=NULL
    SELECT @SQL='Tempeture='+@ParameterValue+''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<Temperture>>',@SQL)

	-- Summary_Letter
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=107	

	SET @SQL=NULL
    SELECT @SQL='Summary_Letter='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<Summary_Letter>>',@SQL)

	-- SubStructure_ID
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=108	

    SELECT @SQL='SubStructure_ID='''+@ParameterValue+''''
	SET @ImportQuery=REPLACE(@ImportQuery,'<<SubStructure_ID>>',@SQL)

	
	-- Test_Name

	SET @ParameterValue=NULL

	SELECT @ParameterValue= ISNULL(@ParameterValue+',','')+''''+Test_Name+''''
	FROM GM_D_Features
	WHERE SolutionID=@SolutionID
	AND (Test_Name NOT like 'DFF_SORT%' OR Test_Name NOT like 'DFF_PBIC%')

	 SELECT @SQL='MT.Test_Name IN ('+@ParameterValue+')'
	 SET @ImportQuery=REPLACE(@ImportQuery,'<<Test_Name>>',@SQL)

	-- Update Import query

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
