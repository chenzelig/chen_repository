	
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

CREATE PROCEDURE USP_VM2F_BDU_Class_Indicators_PreDataExtraction  @SolutionID INT ,@ModelGroupID INT

AS 

BEGIN TRY 

	DECLARE @SQL VARCHAR(MAX)=NULL   
		   ,@ImportQuery VARCHAR(MAX)=NULL
		   ,@ParameterValue VARCHAR(MAX)=NULL
		   ,@FailPoint INT
		   ,@ErrorMessage VARCHAR(MAX)=NULL
		   ,@DaysBack INT=NULL
		   ,@DaysToImport INT=NULL

	
	------------------------------------------------------------------------------------------
	/*								select Import query										*/
	------------------------------------------------------------------------------------------
    SET @FailPoint=1

	SELECT @ImportQuery=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ModelGroupID=@ModelGroupID
	AND ParameterID=20 -- Import Query

	------------------------------------------------------------------------------------------
	/*								update Import querys generic fields						*/
	------------------------------------------------------------------------------------------

	------------------------------- Operation -------------------------------
	SET @FailPoint=2

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=100 	

    SELECT @SQL='MLOTS.Operation='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<Operation>>',@SQL)

	
	--------------------------------- SumTested -------------------------------
	SET @FailPoint=3

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=101

	SET @ImportQuery=REPLACE(@ImportQuery,'<<SumTested>>',@ParameterValue)

	------------------------------- MLOTS_LATO_Valid_Flag -------------------------------
	SET @FailPoint=4

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=102	

    SELECT @SQL=CASE WHEN @ParameterValue IN ('Y','N') THEN 'MLOTS.LATO_Valid_Flag='''+@ParameterValue+'''' ELSE '1=1' END

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MLOTS_LATO_Valid_Flag>>',@SQL)

	------------------------------- MLOTS_LOTS_Complete_Flag -------------------------------
	SET @FailPoint=5

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=103	

    SELECT @SQL=CASE WHEN @ParameterValue IN ('Y','N') THEN 'MLOTS.LOTS_Complete_Flag='''+@ParameterValue+'''' ELSE '1=1' END

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MLOTS_LOTS_Complete_Flag>>',@SQL)

	------------------------------- MUTB_LATO_Valid_Flag -------------------------------
	SET @FailPoint=6

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=104	

    SELECT @SQL=CASE WHEN @ParameterValue IN ('Y','N') THEN 'MUTB.LATO_Valid_Flag='''+@ParameterValue+'''' ELSE '1=1' END

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MUTB_LATO_Valid_Flag>>',@SQL)

	------------------------------- MUTB_Within_LOTS_Latest_Flag -------------------------------
	SET @FailPoint=7

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=105	

   SELECT @SQL=CASE WHEN @ParameterValue IN ('Y','N') THEN 'MUTB.Within_LOTS_Latest_Flag='''+@ParameterValue+'''' ELSE '1=1' END

	SET @ImportQuery=REPLACE(@ImportQuery,'<<MUTB_Within_LOTS_Latest_Flag>>',@SQL)

	------------------------------- Temperature -------------------------------
	SET @FailPoint=8

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=106	

    SELECT @SQL='MLOTS.LOTS_Temperature='+@ParameterValue+''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<Temperature>>',@SQL)

	------------------------------- Summary_Letter -------------------------------
	SET @FailPoint=9

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=107	

    SELECT @SQL='MLOTS.Summary_Letter='''+@ParameterValue+''''

	SET @ImportQuery=REPLACE(@ImportQuery,'<<Summary_Letter>>',@SQL)

	------------------------------- SubStructure_ID -------------------------------
	SET @FailPoint=10

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=108	

    SELECT @SQL='MUTB.SubStructure_ID='''+@ParameterValue+''''
	SET @ImportQuery=REPLACE(@ImportQuery,'<<SubStructure_ID>>',@SQL)

	------------------------------- Test_Program_Pattern ------------------------------
	SET @FailPoint=11

	SET	@ParameterValue=NULL

	SELECT @ParameterValue=ISNULL(@ParameterValue,'')+Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID IN (109,110,111) --Test Program Pattern
	ORDER BY ParameterID

	SET @SQL='MLOTS.Program_Or_BI_Recipe_Name LIKE '''+@ParameterValue+'%'''
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<Test_Program_Pattern>>',@SQL)

	------------------------------- Values To Ignore ------------------------------
	SET @FailPoint=12

	SET	@ParameterValue=NULL

	SELECT @ParameterValue=ISNULL( @ParameterValue+' AND MLOTS.Program_Or_BI_Recipe_Name NOT LIKE ''%'+RES.Value+'%''','(MLOTS.Program_Or_BI_Recipe_Name NOT LIKE ''%'+RES.Value+'%'' ')
	FROM #ATM_GM_ModelingParameters MP
	CROSS APPLY dbo.UDF_GetStringTableFromList_New(Value,',',NULL) RES
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=112

	SET @SQL=CASE WHEN @ParameterValue!='' THEN @ParameterValue+')' ELSE '1=1' END
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<ValuesToIgnore>>',@SQL)
			
	 ------------------------------- DateRange -------------------------------
	 SET @FailPoint=13

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
	SET @FailPoint=14

	SET	@ParameterValue=NULL

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters MP
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=118
	
	SET @SQL=CASE WHEN @ParameterValue='1' THEN 'wip_env_id IS NOT NULL' ELSE '1=1' END
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<wip_env_id>>',@SQL)

	------------------------------- DevRevStep_Template -----------------------------
	SET @FailPoint=15
	
	SET	@ParameterValue=NULL

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters MP
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=119
	
	SET @SQL=CASE WHEN @ParameterValue!='' THEN 'MLOTS.DevRevStep like '''+@ParameterValue+'''' ELSE '1=1' END
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<DevRevStep_Template>>',@SQL)

	------------------------------- Facility_to_Ignore ------------------------------
	SET @FailPoint=16
	
	SET	@ParameterValue=NULL

	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters MP
	WHERE ModelGroupID=@ModelGroupID
	AND ParameterID=120

	SET @SQL=CASE WHEN @ParameterValue!='' THEN 'MLOTS.Facility NOT IN ('''+REPLACE(@ParameterValue,',',''',''')+''')' ELSE '1=1' END
	
	SET @ImportQuery=REPLACE(@ImportQuery,'<<Facility_to_Ignore>>',@SQL)


	------------------------------- Within_SubFlowStep_Latest_Flag -------------------------------
	SET @FailPoint=17
	
	SELECT @ParameterValue=Value
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ParameterID=123

    SELECT @SQL=CASE WHEN @ParameterValue IN ('Y','N') THEN 'MUTB.Within_SubFlowStep_Latest_Flag='''+@ParameterValue+'''' ELSE '1=1' END

	SET @ImportQuery=REPLACE(@ImportQuery,'<<Within_SubFlowStep_Latest_Flag>>',@SQL)

	------------------------------------------------------------------------------------------
	/*								update Test Names										*/
	------------------------------------------------------------------------------------------

	------------------------------- Test_Name Vmin Test -------------------------------
	SET @FailPoint=18

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
	SET @FailPoint=19

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
	SET @FailPoint=20

	UPDATE #ATM_GM_ModelingParameters
	SET Value=@ImportQuery
	FROM #ATM_GM_ModelingParameters
	WHERE SolutionID=@SolutionID
	AND ModelGroupID=@ModelGroupID
	AND ParameterID=20

END TRY

BEGIN CATCH  	
	SET @ErrorMessage = 'Fail Point: ' + CONVERT(VARCHAR(3), @FailPoint) +' '+ ERROR_MESSAGE()
	SELECT @ErrorMessage
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_VM2F_BDU_Class_Indicators_PreDataExtraction', @EngineName = 'VM2F', 
							@ModuleName = 'Indicators', @LogEventMessage = @ErrorMessage, @LogEventType = 'E' 
	RAISERROR (N'USP_VM2F_BDU_Class_Indicators_PreDataExtraction::FailPoint- %d ERR-%s', 16,1, @FailPoint, @ErrorMessage)
END CATCH 
GO
