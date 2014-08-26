
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_GM_EvaluationProcedure]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_GM_EvaluationProcedure]
GO

/*******************************************************           
* Procedure:		[USP_GM_EvaluationProcedure] 
*                                                              
* Description:
exec [USP_GM_EvaluationProcedure] 100
* 
* ----------------------------------------------------------     
*                                                                    
* Modification Log:                                            
* Date				Modified By			Modification:                         
* ----				-----------			--------------------         
* 2014-08-07		Neiman,Jacob		Creating the SP 
*******************************************************/ 

CREATE PROCEDURE [dbo].[USP_GM_EvaluationProcedure](@ModelID INT)
AS

BEGIN TRY

	DECLARE @ErrorMessage nvarchar(max),@EvalQuery nvarchar(max)='',@TargetAttribute nvarchar(max),@StartTime datetime = GETUTCDATE(),@LogMessage varchar(1000),@EndTime datetime,@i int =1
			,@MaxEvalIndex int,@outerSelect nvarchar(max)='',@innerSelect nvarchar(max),@j int,@MaxDataSetIndex int,@TempDataset nvarchar(max),@InnerWhereClause nvarchar(max),@EvaluationDataSet nvarchar(max)
			,@isDuplicateInd int=0,@DatasetColumn nvarchar(max)=null,@outerSelectPivot nvarchar(max)='',@SolutionID nvarchar(7)=''

	SET @LogMessage = 'Starting USP_GM_EvaluationProcedure on ModelID = '+ISNULL(convert(varchar(5),@ModelID),'NULL')
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_MainProcedure', 
							@EngineName = 'MFG_Solutions', @ModuleName = 'MainProcedure', @LogEventMessage = @LogMessage, 
							@StartDate = @StartTime, @EndDate = @EndTime, @LogEventType = 'I'	
	
	SELECT @TargetAttribute = Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelID = @ModelID
		AND ParameterId=2
	
	
	--Get evaluation parameters into a temp table
	IF OBJECT_ID('tempdb..#ATM_GM_TempEvaluationParams') IS NOT NULL
	DROP TABLE #ATM_GM_TempEvaluationParams

	SELECT row_number() over (order by A.EvaluationMeasureID,B.EvaluationCalculatedFieldID) as ROW_NUM
		,EvaluationMeasureID
		,EvaluationMeasureName
		,EvaluationDefinition
		,EvaluationCalculatedFieldID
		,EvaluationCalculatedFieldLogic
		,EvaluationCalculatedFieldName
	into #ATM_GM_TempEvaluationParams
	FROM [dbo].[GM_D_EvaluationMeasures] A
	CROSS JOIN [dbo].[GM_D_EvaluationCalculatedFields] B
	where B.EvaluationCalculatedFieldID in (select Value from [AdvancedBIsystem].[dbo].[UDF_GetIntTableFromList](EvaluationCalculatedFieldIDs))
		and EvaluationMeasureID in (select EvaluationMeasureID from [dbo].[GM_F_ModelEvaluation] where ModelID = @ModelID)
	
	--select * from #ATM_GM_TempEvaluationParams --for debug

	SET @EvalQuery = ''
	SET @outerSelect =''
	SET @innerSelect =''
	SET @EvaluationDataSet =''

	SELECT @outerSelect = @outerSelect + ' CAST (' + EvaluationDefinition  + ' as float) AS EVALUATION_'+cast (EvaluationMeasureID as varchar(6))+ ' ,' FROM  (select distinct EvaluationMeasureID, EvaluationDefinition from #ATM_GM_TempEvaluationParams) T 
	SET @outerSelect = substring(@outerSelect,1,len(@outerSelect)-1)
	SELECT @outerSelectPivot = @outerSelectPivot + 'EVALUATION_'+cast (EvaluationMeasureID as varchar(6))+ ' ,' FROM  (select distinct EvaluationMeasureID, EvaluationDefinition from #ATM_GM_TempEvaluationParams) T 
	SET @outerSelectPivot = substring(@outerSelectPivot,1,len(@outerSelectPivot)-1)	
	SELECT @innerSelect = @innerSelect + ' ' + REPLACE(EvaluationCalculatedFieldLogic,'[TARGET]',@TargetAttribute) + ' AS ' + EvaluationCalculatedFieldName +',' FROM  (select distinct EvaluationCalculatedFieldLogic, EvaluationCalculatedFieldName from #ATM_GM_TempEvaluationParams) T 
	SET @innerSelect = substring(@innerSelect,1,len(@innerSelect)-1)
	
	--checking if data is partitioned into other then 'ALL'/NULL partitions
	select  @EvaluationDataSet = @EvaluationDataSet + ',' + datasets 	FROM (select distinct datasets from [dbo].[GM_F_ModelEvaluation] where ModelID = @ModelID) T
	SET @EvaluationDataSet = substring(@EvaluationDataSet,2,len(@EvaluationDataSet))

	SELECT @DatasetColumn = Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelID = @ModelID
		AND ParameterId=6

	if (@DatasetColumn = null OR (select count(*) from [AdvancedBIsystem].[dbo].[UDF_GetStringTableFromList](@EvaluationDataSet) where value='ALL' or value is null)>1) BEGIN
		--that means that no datasetcolumn was configured/no partition population was selected
		set @isDuplicateInd =1 
	END

	SELECT top 1 @SolutionID = SolutionID
	FROM #ATM_GM_ModelingParameters
	WHERE ModelID = @ModelID

	set @EvalQuery ='DECLARE @RunTime datetime = GETUTCDATE()
	
					IF OBJECT_ID(''tempdb..#ATM_GM_TempEvaluationTable'') IS NOT NULL
						DROP TABLE #ATM_GM_TempEvaluationTable

					  --insert evaluations for "ALL" the data
					  SELECT cast(PARTITION_DATASET as varchar(240)) AS PARTITION_DATASET,' + @outerSelect + 
					' INTO #ATM_GM_TempEvaluationTable 
					  FROM (SELECT  ''ALL''   AS PARTITION_DATASET, [PREDICTION],' + @TargetAttribute +' , ' + @innerSelect+ ' 
							FROM #ATM_GM_PreparedData ) A
					  GROUP BY PARTITION_DATASET

					  --insert evaluations for "ALL" the data
					  INSERT INTO  #ATM_GM_TempEvaluationTable  
					  SELECT PARTITION_DATASET,' + @outerSelect + ' 
					  FROM (SELECT '+coalesce(@DatasetColumn,'''ALL''') +'  AS PARTITION_DATASET, [PREDICTION],' + @TargetAttribute +' , ' + @innerSelect+ ' 
							FROM #ATM_GM_PreparedData ) A 
					   GROUP BY PARTITION_DATASET


						--SELECT * --into yasha_20140820_evalResults 	from #ATM_GM_TempEvaluationTable --Remove "--" for selecting Result table
						
						--UNPIVOT the evaluation data
						insert into [dbo].[GM_R_ModelEvaluationResults] (ModelID,SolutionID,RemodelingTimestamp,Dataset,EvaluationMeasureID,Value)' +
						+' 
						
						SELECT '+cast (@ModelID as char(10)) +
						','+ @SolutionID+
						',@RunTime
						,PARTITION_DATASET
						,cast (substring(evalID,CHARINDEX(''_'',evalID)+1,len(evalID)) as int)
						,EvalValue
						from #ATM_GM_TempEvaluationTable
						unpivot
						(
						EvalValue
						for evalID in ('+@outerSelectPivot+')
						) T
						
						--this join is intended to insert existing <EvaluationMeasureID,DataSet> tuples
						INNER JOIN (select EvaluationMeasureID,Value as DataSet 
									from [GM_F_ModelEvaluation] A
									CROSS JOIN (select Value 
												from [AdvancedBIsystem].[dbo].[UDF_GetStringTableFromList]('''+@EvaluationDataSet+''')) B
									where CHARINDEX(B.value,a.Datasets)>0 ) DS
						ON DS.EvaluationMeasureID=cast (substring(evalID,CHARINDEX(''_'',evalID)+1,len(evalID)) as int) AND PARTITION_DATASET=DS.DataSet'
						
						+'
					'
	exec (@EvalQuery) 
	

END TRY




BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GFA_FE_GetProductNameFromMGID', @EngineName = 'MFG_Solutions', 
							@ModuleName = 'GFA-UI', @LogEventMessage = @ErrorMessage, @LogEventType = 'E' 
	RAISERROR (N'USP_GFA_FE_GetProductNameFromMGID:: ERR-%s', 16,1, @ErrorMessage)
END CATCH


GO
