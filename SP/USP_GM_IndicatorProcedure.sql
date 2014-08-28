IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_GM_IndicatorProcedure]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_GM_IndicatorProcedure]
GO

/*******************************************************           
* Procedure:		[USP_GM_IndicatorProcedure] 
*                                                              
* Description:
exec [USP_GM_EvaluationProcedure] 100
* 
* ----------------------------------------------------------     
*                                                                    
* Modification Log:                                            
* Date				Modified By			Modification:                         
* ----				-----------			--------------------         
* 2014-08-24		Neiman,Jacob		Creating the SP 
*******************************************************/ 

CREATE PROCEDURE [dbo].[USP_GM_IndicatorProcedure](@ModelID INT)
AS

BEGIN TRY

	DECLARE @ErrorMessage nvarchar(max),@EvalQuery nvarchar(max)='',@TargetAttribute nvarchar(max),@StartTime datetime = GETUTCDATE(),@LogMessage varchar(1000),@EndTime datetime
		   ,@IndicatorCalculatedFieldIDs varchar (max) = '', @innerSelect varchar (max) = '',@i int = 1, @maxRowNumber int, @currDataTable nvarchar(max),@currDataTableID int,@indicatorLvlSctStr nvarchar(max) 
		   ,@orderByColumn varchar (max) = '',@indicatorQuery varchar(max),@maxInstanceId int,@Query varchar(max),@currIndicatorLvlId int,@leftJoinClause varchar(max) = ''
		   ,@outerSelect varchar(max) = '',@indicatorSelect varchar(max) = ''

	SET @LogMessage = 'Starting USP_GM_IndicatorProcedure on ModelID = '+ISNULL(convert(varchar(5),@ModelID),'NULL')
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_MainProcedure', 
							@EngineName = 'MFG_Solutions', @ModuleName = 'MainProcedure', @LogEventMessage = @LogMessage, 
							@StartDate = @StartTime, @EndDate = @EndTime, @LogEventType = 'I'	
	
	--SELECT @TargetAttribute = Value
	--FROM #ATM_GM_ModelingParameters
	--WHERE ModelID = @ModelID
	--	AND ParameterId=2
	
	--DEBUG
	set @currDataTable = 'tempdb..#ATM_GM_PreparedData'
	set @currDataTableID = 2

	select  @IndicatorCalculatedFieldIDs = @IndicatorCalculatedFieldIDs + ',' + IndicatorCalculatedFieldIDs 	FROM (select distinct IndicatorCalculatedFieldIDs from [dbo].[GM_D_Indicators] (nolock) where IndicatorCalculatedFieldIDs is not null and IndicatorID in (select indicatorid from [dbo].[GM_F_ModelIndicators] (nolock) where ModelID = @ModelID )) T
	SET @IndicatorCalculatedFieldIDs = substring(@IndicatorCalculatedFieldIDs,2,len(@IndicatorCalculatedFieldIDs))
	

	select @innerSelect = @innerSelect + ','  + IndicatorCalculatedFieldLogic +' AS '+ IndicatorCalculatedFieldName  from [GM_D_IndicatorCalculatedFields] (nolock) where IndicatorCalculatedFieldID in (select Value from [AdvancedBIsystem].[dbo].[UDF_GetIntTableFromList](@IndicatorCalculatedFieldIDs)) 
	SET @innerSelect = substring(@innerSelect,2,len(@innerSelect)) +','
	

	/*
	Here I should parse the [GM_F_ModelIndicators] table so that no ModelID=-1 will exist 
	*/

	--select  @EvaluationDataSet = @EvaluationDataSet + ',' + datasets 	FROM (select distinct datasets from [dbo].[GM_F_ModelEvaluation] where ModelID = @ModelID) T
	--SET @EvaluationDataSet = substring(@EvaluationDataSet,2,len(@EvaluationDataSet))



	IF OBJECT_ID('tempdb..#ATM_GM_TempIndicatorComponentList') IS NOT NULL
		DROP TABLE #ATM_GM_TempIndicatorComponentList
	
	select distinct M.SolutionID	
		,M.ModelGroupID	
		,M.ModelID	
		,M.IndicatorLevelID
		,IL.IndicatorComponent
		,IL.IndicatorComponentID	
		,case when t.name in ('varchar','char','nvarchar','nchar') then 1 else 0 end as CharInd
	into #ATM_GM_TempIndicatorComponentList	
	from [dbo].[GM_F_ModelIndicators] (nolock) M
	INNER JOIN [dbo].[GM_D_IndicatorLevels] (nolock) IL
	ON M.IndicatorLevelID=IL.IndicatorLevelID
	INNER JOIN tempdb.sys.columns (nolock) c
	on IL.IndicatorComponent=c.name and [object_id] = OBJECT_ID(@currDataTable)
	INNER JOIN sys.types (nolock) t 
	ON c.system_type_id = t.system_type_id and t.name <>'sysname'
	
	
	
	IF OBJECT_ID('tempdb..#ATM_GM_TempIndicatorList') IS NOT NULL
		DROP TABLE #ATM_GM_TempIndicatorList
	
	select row_number () over (order by IndicatorLevelID) as row_num,IndicatorLevelID, cast (null as varchar(max)) as indicatorLvlSctStr
	into #ATM_GM_TempIndicatorList
	from
	(select distinct IndicatorLevelID
	from GM_F_ModelIndicators (nolock)
	where ModelID=@ModelID) T

	--create the select separated by commas
	select @maxRowNumber =  max(row_num) from #ATM_GM_TempIndicatorList
	while @i<= @maxRowNumber
	BEGIN
		set @indicatorLvlSctStr = ''
		select @currIndicatorLvlId = IndicatorLevelID from #ATM_GM_TempIndicatorList where row_num=@i
		--select @indicatorLvlSctStr = @indicatorLvlSctStr + cast (case when CharInd=1 then '''''''''+' +IndicatorComponent + '+''''''''+' else ' CAST (' + IndicatorComponent + ' as varchar(max))+' end as varchar(max)) + ''',''+'

		select @indicatorLvlSctStr = @indicatorLvlSctStr + cast (' CAST (' + IndicatorComponent + ' as varchar(max))+' as varchar(max)) + ''',''+'
									from #ATM_GM_TempIndicatorComponentList
									where  IndicatorLevelID in (@currIndicatorLvlId)
									order by IndicatorComponentID

		SET @indicatorLvlSctStr = substring(@indicatorLvlSctStr,1,len(@indicatorLvlSctStr)-5)
		update #ATM_GM_TempIndicatorList set indicatorLvlSctStr=@indicatorLvlSctStr where row_num=@i
		select @maxInstanceId = coalesce(max(IndicatorLevelInstanceID),0) from [dbo].[GM_R_IndicatorLevelInstances] where IndicatorLevelID in (@currIndicatorLvlId)
		--insert new indicatorLevelInstance values and give them a new ID
		set @Query ='insert into [GM_R_IndicatorLevelInstances] (ModelID,	IndicatorLevelID,	IndicatorLevelInstanceID,	ComponentValues)
		
					select '+cast (@ModelID as varchar(10)) +
					','+ cast (@currIndicatorLvlId as varchar(10))+'
					, row_number() over (order by DisVals) +' + cast (@maxInstanceId as varchar(10))+
					+',DisVals'
					+' FROM 
					(select distinct '+ @indicatorLvlSctStr+ ' as DisVals from '+ @currDataTable+') T
					
					WHERE not exists (select * from [GM_R_IndicatorLevelInstances] (nolock) T2 where T2.ComponentValues=T.DisVals and T2.IndicatorLevelID='+cast (@currIndicatorLvlId as varchar(10)) + ')'
		exec (@Query)

		set @leftJoinClause = @leftJoinClause + '
							 
							 left join [GM_R_IndicatorLevelInstances] T_'+ cast (@currIndicatorLvlId as varchar(10)) + ' (nolock) ' +
							 'on T_'+cast (@currIndicatorLvlId as varchar(10))+'.ComponentValues=Concatenated_IndicatorLevelID_'+cast (@currIndicatorLvlId as varchar(10)) +' and T_'+cast (@currIndicatorLvlId as varchar(10))+'.IndicatorLevelID='+cast (@currIndicatorLvlId as varchar(10)) +' and T_'+cast (@currIndicatorLvlId as varchar(10))+'.modelid='+ cast (@ModelID as varchar(10)) +
							 '

							 '						 
		SET @outerSelect= @outerSelect +'T_'+cast (@currIndicatorLvlId as varchar(10))+'.IndicatorLevelID as IndicatorLevelID_'+cast (@currIndicatorLvlId as varchar(10))+',T_'+cast (@currIndicatorLvlId as varchar(10))+'.IndicatorLevelInstanceID as IndicatorLevelInstanceID_'+cast (@currIndicatorLvlId as varchar(10))+',T_'+cast (@currIndicatorLvlId as varchar(10))+'.ComponentValues as ComponentValues_'+cast (@currIndicatorLvlId as varchar(10))+','
		
						 
		set @i = @i +1
	END
	SET @outerSelect = substring(@outerSelect,1,len(@outerSelect)-1)
	select @indicatorSelect = @indicatorSelect + StrVal 
										from 
										(select distinct I.IndicatorDefinition +' OVER (PARTITION BY T_' + cast (M.IndicatorLevelID as varchar(10))  + '.ComponentValues) AS INDICATOR_RESULT_'+ cast (M.IndicatorID as varchar(10))+'_'++ cast (M.IndicatorLevelID as varchar(10)) +',' as StrVal
										from GM_D_Indicators I

										inner join GM_F_ModelIndicators (NOLOCK) M
										on M.indicatorID=I.indicatorID and M.modelID=@ModelID) T
 
	SET @indicatorSelect = substring(@indicatorSelect,1,len(@indicatorSelect)-1)
	--select @indicatorSelect
	--select @leftJoinClause
	--select * from #ATM_GM_TempIndicatorList
	--select @outerSelect
	select @innerSelect = @innerSelect +  indicatorLvlSctStr +' AS Concatenated_IndicatorLevelID_'+cast (IndicatorLevelID as varchar(10))+' , '  from #ATM_GM_TempIndicatorList
	SET @innerSelect = substring(@innerSelect,1,len(@innerSelect)-1)

	

	SET @indicatorQuery = ' IF OBJECT_ID(''tempdb..#tempIndicatorResults'') IS NOT NULL
								DROP TABLE #tempIndicatorResults
	
	
							select '+ @indicatorSelect +
								',' +@outerSelect+ ' 
							into #tempIndicatorResults
							from 
							(SELECT '+ @innerSelect+
						   ' ,T.*
							from '+@currDataTable +' T) innerSelect 
							' + @leftJoinClause +
							' 

							IF OBJECT_ID(''tempdb..#tempIndicatorLvlTbl'') IS NOT NULL
								DROP TABLE #tempIndicatorLvlTbl

							select row_number() over (ORDER BY IndicatorID, indicatorLevelID ) as Row_Num
								,IndicatorID
								,indicatorLevelID 
							into #tempIndicatorLvlTbl
							from  [dbo].[GM_F_ModelIndicators] I
							where modelID = '+cast (@ModelID as varchar(10))+'
								and '+cast (@currDataTableID as varchar(10))+' in (select Value from [AdvancedBIsystem].[dbo].[UDF_GetIntTableFromList](I.DataTableIDs) )
							GROUP BY IndicatorID, indicatorLevelID 
							
							declare @i int = 1,@maxRowNumber int,@Query varchar(max),@RunTime datetime = GETUTCDATE()
							--insert results to the Result table
							select @maxRowNumber = max(row_num) from #tempIndicatorLvlTbl
							WHILE @i<=@maxRowNumber
							BEGIN
							
								select @Query = '' insert into GM_R_ModelIndicatorValues (ModelID,IndicatorLevelID,IndicatorLevelInstanceID,IndicatorID,Timestamp,Value) 
													select DISTINCT '+cast (@ModelID as varchar(10))+',indicatorLevelID_'' + cast (indicatorLevelID as varchar(10)) + '', IndicatorLevelInstanceID_''+cast (indicatorLevelID as varchar(10))+'',''+cast (indicatorID as varchar(10))+'',''''''+cast (@RunTime as varchar(100))+'''''',INDICATOR_RESULT_''+cast (indicatorID as varchar(10))+''_''+cast (indicatorLevelID as varchar(10))+'' from #tempIndicatorResults''
								from #tempIndicatorLvlTbl
								where Row_Num = @i
								
								EXEC (@Query)

								set @i = @i +1
							END
							'
							
	print(@indicatorQuery)
	exec  (@indicatorQuery)

END TRY




BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_IndicatorProcedure', @EngineName = 'MFG_Solutions', 
							@ModuleName = 'GFA-UI', @LogEventMessage = @ErrorMessage, @LogEventType = 'E' 
	RAISERROR (N'USP_GM_IndicatorProcedure:: ERR-%s', 16,1, @ErrorMessage)
END CATCH



GO

