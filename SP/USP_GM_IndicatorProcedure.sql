
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

	SET @LogMessage = 'Starting USP_GM_EvaluationProcedure on ModelID = '+ISNULL(convert(varchar(5),@ModelID),'NULL')
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_MainProcedure', 
							@EngineName = 'MFG_Solutions', @ModuleName = 'MainProcedure', @LogEventMessage = @LogMessage, 
							@StartDate = @StartTime, @EndDate = @EndTime, @LogEventType = 'I'	
	
	SELECT @TargetAttribute = Value
	FROM #ATM_GM_ModelingParameters
	WHERE ModelID = @ModelID
		AND ParameterId=2
	
	/*
	Here I should parse the [GM_F_ModelIndicators] table so that no ModelID=-1 will exist 
	*/

	select M.SolutionID	
		,M.ModelGroupID	
		,M.ModelID	
		,M.IndicatorLevelID
		,IL.IndicatorComponent	
		,case when t.name in ('varchar','char','nvarchar','nchar') then 1 else 0 end as CharInd
		,M.IndicatorID
		,I.IndicatorDefinition
	
	from [dbo].[GM_F_ModelIndicators] M

	INNER JOIN [dbo].[GM_D_IndicatorLevels]  IL
	ON M.IndicatorLevelID=IL.IndicatorLevelID

	INNER JOIN [dbo].[GM_D_Indicators] I
	ON M.IndicatorId=I.IndicatorId
	
	INNER JOIN tempdb.sys.columns c
	on IL.IndicatorComponent=c.name and [object_id] = OBJECT_ID(N'tempdb..#ATM_GM_PreparedData')
	
	INNER JOIN sys.types t 
	ON c.system_type_id = t.system_type_id and t.name <>'sysname'
	


END TRY




BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GFA_FE_GetProductNameFromMGID', @EngineName = 'MFG_Solutions', 
							@ModuleName = 'GFA-UI', @LogEventMessage = @ErrorMessage, @LogEventType = 'E' 
	RAISERROR (N'USP_GFA_FE_GetProductNameFromMGID:: ERR-%s', 16,1, @ErrorMessage)
END CATCH


GO
