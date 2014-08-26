IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_F_ModelEvaluation]') AND type in (N'U'))
	DROP TABLE [GM_F_ModelEvaluation]


/****** Object:  Table [dbo].[GM_F_ModelEvaluation]    Script Date: 8/7/2014 1:27:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[GM_F_ModelEvaluation](
	[SolutionID] [int] NOT NULL,
	[ModelGroupID] [int] NOT NULL,
	[ModelID] [int] NOT NULL,
	[EvaluationMeasureID] [int] NOT NULL,
	[Datasets] [varchar](100) NOT NULL,
 CONSTRAINT [PK_GM_F_ModelEvaluation] PRIMARY KEY CLUSTERED 
(
	[SolutionID] ASC,
	[ModelGroupID] ASC,
	[ModelID] ASC,
	[EvaluationMeasureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[GM_F_ModelEvaluation]  WITH CHECK ADD  CONSTRAINT [FK_GM_F_ModelEvaluation_EvaluationMeasureID] FOREIGN KEY([EvaluationMeasureID])
REFERENCES [dbo].[GM_D_EvaluationMeasures] ([EvaluationMeasureID])
GO

ALTER TABLE [dbo].[GM_F_ModelEvaluation] CHECK CONSTRAINT [FK_GM_F_ModelEvaluation_EvaluationMeasureID]
GO

ALTER TABLE [dbo].[GM_F_ModelEvaluation]  WITH CHECK ADD  CONSTRAINT [FK_GM_F_ModelEvaluation_ModelGroupID] FOREIGN KEY([ModelGroupID])
REFERENCES [dbo].[GM_D_ModelGroups] ([ModelGroupID])
GO

ALTER TABLE [dbo].[GM_F_ModelEvaluation] CHECK CONSTRAINT [FK_GM_F_ModelEvaluation_ModelGroupID]
GO

ALTER TABLE [dbo].[GM_F_ModelEvaluation]  WITH CHECK ADD  CONSTRAINT [FK_GM_F_ModelEvaluation_ModelID] FOREIGN KEY([ModelID])
REFERENCES [dbo].[GM_D_Models] ([ModelID])
GO

ALTER TABLE [dbo].[GM_F_ModelEvaluation] CHECK CONSTRAINT [FK_GM_F_ModelEvaluation_ModelID]
GO

ALTER TABLE [dbo].[GM_F_ModelEvaluation]  WITH CHECK ADD  CONSTRAINT [FK_GM_F_ModelEvaluation_SolutionID] FOREIGN KEY([SolutionID])
REFERENCES [dbo].[GM_D_Solutions] ([SolutionID])
GO

ALTER TABLE [dbo].[GM_F_ModelEvaluation] CHECK CONSTRAINT [FK_GM_F_ModelEvaluation_SolutionID]
GO


