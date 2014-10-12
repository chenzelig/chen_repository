IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_R_ModelIndicatorValues]') AND type in (N'U')) 
Begin
	IF OBJECT_ID('FK_GM_R_ModelIndicatorValues_IndicatorID', 'C') IS NOT NULL ALTER TABLE [GM_R_ModelIndicatorValues] DROP CONSTRAINT [FK_GM_R_ModelIndicatorValues_IndicatorID]
	IF OBJECT_ID('FK_GM_R_ModelIndicatorValues_ModelID', 'C') IS NOT NULL ALTER TABLE [GM_R_ModelIndicatorValues] DROP CONSTRAINT [FK_GM_R_ModelIndicatorValues_ModelID]
End

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_F_ModelEvaluation]') AND type in (N'U')) BEGIN
	IF OBJECT_ID('FK_GM_F_ModelEvaluation_EvaluationMeasureID', 'C') IS NOT NULL ALTER TABLE [GM_F_ModelEvaluation] DROP CONSTRAINT [FK_GM_F_ModelEvaluation_EvaluationMeasureID]
	IF OBJECT_ID('FK_GM_F_ModelEvaluation_ModelGroupID', 'C') IS NOT NULL ALTER TABLE [GM_F_ModelEvaluation] DROP CONSTRAINT [FK_GM_F_ModelEvaluation_ModelGroupID]
	IF OBJECT_ID('FK_GM_F_ModelEvaluation_ModelID', 'C') IS NOT NULL ALTER TABLE [GM_F_ModelEvaluation] DROP CONSTRAINT [FK_GM_F_ModelEvaluation_ModelID]
	IF OBJECT_ID('FK_GM_F_ModelEvaluation_SolutionID', 'C') IS NOT NULL ALTER TABLE [GM_F_ModelEvaluation] DROP CONSTRAINT [FK_GM_F_ModelEvaluation_SolutionID]
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_F_ModelIndicators]') AND type in (N'U')) 
BEGIN
	IF OBJECT_ID('FK_GM_F_ModelIndicators_ModelID', 'C') IS NOT NULL ALTER TABLE [GM_F_ModelIndicators] DROP CONSTRAINT [FK_GM_F_ModelIndicators_ModelID]
	IF OBJECT_ID('FK_GM_F_ModelIndicators_SolutionID', 'C') IS NOT NULL ALTER TABLE [GM_F_ModelIndicators] DROP CONSTRAINT [FK_GM_F_ModelIndicators_SolutionID]
	IF OBJECT_ID('FK_GM_F_ModelIndicators_ModelGroupID', 'C') IS NOT NULL ALTER TABLE [GM_F_ModelIndicators] DROP CONSTRAINT [FK_GM_F_ModelIndicators_ModelGroupID]
END	


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_R_IndicatorLevelInstances]') AND type in (N'U'))
BEGIN
	IF OBJECT_ID('FK_GM_R_IndicatorLevelInstances_ModelID', 'C') IS NOT NULL ALTER TABLE [GM_R_IndicatorLevelInstances] DROP CONSTRAINT [FK_GM_R_IndicatorLevelInstances_ModelID]
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_R_ModelEvaluationResults]') AND type in (N'U')) begin
	IF OBJECT_ID('FK_GM_R_ModelEvaluationResults_EvaluationMeasureID', 'C') IS NOT NULL ALTER TABLE [GM_R_ModelEvaluationResults] DROP CONSTRAINT [FK_GM_R_ModelEvaluationResults_EvaluationMeasureID]
	IF OBJECT_ID('FK_GM_R_ModelEvaluationResults_ModelID', 'C') IS NOT NULL ALTER TABLE [GM_R_ModelEvaluationResults] DROP CONSTRAINT [FK_GM_R_ModelEvaluationResults_ModelID]
end	











IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_R_ModelIndicatorValues]') AND type in (N'U')) 
Begin
	DROP TABLE [dbo].[GM_R_ModelIndicatorValues]
End

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_EvaluationCalculatedFields]') AND type in (N'U'))
	DROP TABLE [dbo].[GM_D_EvaluationCalculatedFields]

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_EvaluationMeasures]') AND type in (N'U'))
	DROP TABLE [GM_D_EvaluationMeasures]

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_IndicatorCalculatedFields]') AND type in (N'U'))
	DROP TABLE [dbo].[GM_D_IndicatorCalculatedFields]

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_IndicatorLevels]') AND type in (N'U'))
	DROP TABLE [GM_D_IndicatorLevels]
	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_Indicators]') AND type in (N'U'))
	DROP TABLE [dbo].[GM_D_Indicators]

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_TempDataTable]') AND type in (N'U'))
	DROP TABLE [GM_D_TempDataTable]	

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_F_ModelEvaluation]') AND type in (N'U')) BEGIN
	DROP TABLE [GM_F_ModelEvaluation]

END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_F_ModelIndicators]') AND type in (N'U')) 
BEGIN
	DROP TABLE [GM_F_ModelIndicators]
END	

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_R_IndicatorLevelInstances]') AND type in (N'U'))
BEGIN
	DROP TABLE [GM_R_IndicatorLevelInstances]
END

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_R_ModelEvaluationResults]') AND type in (N'U'))
	DROP TABLE [GM_R_ModelEvaluationResults]