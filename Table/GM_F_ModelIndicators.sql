IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_F_ModelIndicators]') AND type in (N'U')) 
BEGIN
	ALTER TABLE [GM_F_ModelIndicators] DROP CONSTRAINT [FK_GM_F_ModelIndicators_ModelID]
	ALTER TABLE [GM_F_ModelIndicators] DROP CONSTRAINT [FK_GM_F_ModelIndicators_SolutionID]
	ALTER TABLE [GM_F_ModelIndicators] DROP CONSTRAINT [FK_GM_F_ModelIndicators_ModelGroupID]
	DROP TABLE [GM_F_ModelIndicators]
END	

CREATE TABLE [dbo].[GM_F_ModelIndicators](
	[SolutionID] [int] NOT NULL,
	[ModelGroupID] [int] NOT NULL,
	[ModelID] [int] NOT NULL,
	[IndicatorLevelID] [int] NOT NULL,
	[IndicatorID] [int] NOT NULL,
	[DataTableIDs] [varchar](1000) NOT NULL,
 CONSTRAINT [PK_GM_F_ModelIndicators] PRIMARY KEY CLUSTERED 
(
	[SolutionID] ASC,
	[ModelID] ASC,
	[IndicatorLevelID] ASC,
	[IndicatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GM_F_ModelIndicators]  WITH CHECK ADD  CONSTRAINT [FK_GM_F_ModelIndicators_ModelID] FOREIGN KEY([ModelID])
REFERENCES [dbo].[GM_D_Models] ([ModelID])
GO

ALTER TABLE [dbo].[GM_F_ModelIndicators] CHECK CONSTRAINT [FK_GM_F_ModelIndicators_ModelID]
GO

ALTER TABLE [dbo].[GM_F_ModelIndicators]  WITH CHECK ADD  CONSTRAINT [FK_GM_F_ModelIndicators_SolutionID] FOREIGN KEY([SolutionID])
REFERENCES [dbo].[GM_D_Solutions] ([SolutionID])
GO

ALTER TABLE [dbo].[GM_F_ModelIndicators] CHECK CONSTRAINT [FK_GM_F_ModelIndicators_SolutionID]
GO

ALTER TABLE [dbo].[GM_F_ModelIndicators]  WITH CHECK ADD  CONSTRAINT [FK_GM_F_ModelIndicators_ModelGroupID] FOREIGN KEY([ModelGroupID])
REFERENCES [dbo].[GM_D_ModelGroups] ([ModelGroupID])
GO

ALTER TABLE [dbo].[GM_F_ModelIndicators] CHECK CONSTRAINT [FK_GM_F_ModelIndicators_ModelGroupID]
GO