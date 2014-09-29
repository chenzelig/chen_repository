IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_R_IndicatorLevelInstances]') AND type in (N'U'))
	DROP TABLE [GM_R_IndicatorLevelInstances]
	ALTER TABLE [GM_R_IndicatorLevelInstances] DROP CONSTRAINT [FK_GM_F_ModelEvaluation_SolutionID]
	ALTER TABLE [GM_R_IndicatorLevelInstances] DROP CONSTRAINT [FK_GM_R_IndicatorLevelInstances_ModelID]

CREATE TABLE [dbo].[GM_R_IndicatorLevelInstances](
	[ModelID] [int] NOT NULL,
	[IndicatorLevelID] [int] NOT NULL,
	[IndicatorLevelInstanceID] [int] NOT NULL,
	[ComponentValues] varchar(900) NOT NULL,
 CONSTRAINT [PK_GM_R_IndicatorLevelInstances] PRIMARY KEY CLUSTERED 
(
	[ModelID] ASC,
	[IndicatorLevelID] ASC,
	[IndicatorLevelInstanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GM_R_IndicatorLevelInstances]  WITH CHECK ADD  CONSTRAINT [FK_GM_R_IndicatorLevelInstances_ModelID] FOREIGN KEY([ModelID])
REFERENCES [dbo].[GM_D_Models] ([ModelID])
GO

ALTER TABLE [dbo].[GM_R_IndicatorLevelInstances] CHECK CONSTRAINT [FK_GM_R_IndicatorLevelInstances_ModelID]
GO

CREATE NONCLUSTERED INDEX IDX_GM_R_IndicatorLevelInstances_ComponentValues
ON GM_R_IndicatorLevelInstances (ComponentValues)
