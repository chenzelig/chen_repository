IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_R_ModelIndicatorValues]') AND type in (N'U')) 
Begin
	ALTER TABLE [GM_R_ModelIndicatorValues] DROP CONSTRAINT [FK_GM_R_ModelIndicatorValues_IndicatorID]
	ALTER TABLE [GM_R_ModelIndicatorValues] DROP CONSTRAINT [FK_GM_R_ModelIndicatorValues_ModelID]
	DROP TABLE [dbo].[GM_R_ModelIndicatorValues]
End


CREATE TABLE [dbo].[GM_R_ModelIndicatorValues](
	[ModelID] [int] NOT NULL,
	[IndicatorLevelID] [int] NOT NULL,
	[IndicatorLevelInstanceID] [int] NOT NULL,
	[IndicatorID] [int] NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Value] [float] ,
 CONSTRAINT [PK_GM_R_ModelIndicatorValues] PRIMARY KEY CLUSTERED 
(
	[ModelID] ASC,
	[IndicatorLevelID] ASC,
	[IndicatorLevelInstanceID] ASC,
	[IndicatorID] ASC,
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GM_R_ModelIndicatorValues]  WITH CHECK ADD  CONSTRAINT [FK_GM_R_ModelIndicatorValues_IndicatorID] FOREIGN KEY([IndicatorID])
REFERENCES [dbo].[GM_D_Indicators] ([IndicatorID])
GO

ALTER TABLE [dbo].[GM_R_ModelIndicatorValues] CHECK CONSTRAINT [FK_GM_R_ModelIndicatorValues_IndicatorID]
GO

ALTER TABLE [dbo].[GM_R_ModelIndicatorValues]  WITH CHECK ADD  CONSTRAINT [FK_GM_R_ModelIndicatorValues_ModelID] FOREIGN KEY([ModelID])
REFERENCES [dbo].[GM_D_Models] ([ModelID])
GO

ALTER TABLE [dbo].[GM_R_ModelIndicatorValues] CHECK CONSTRAINT [FK_GM_R_ModelIndicatorValues_ModelID]
GO

