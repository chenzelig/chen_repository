IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_R_ModelEvaluationResults]') AND type in (N'U'))
	DROP TABLE [GM_R_ModelEvaluationResults]

USE [MFG_Solutions]
GO

/****** Object:  Table [dbo].[GM_R_ModelEvaluationResults]    Script Date: 8/7/2014 1:29:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[GM_R_ModelEvaluationResults](
	[ModelID] [int] NOT NULL,
	[SolutionID] [int] NOT NULL,
	[RemodelingTimestamp] [datetime] NOT NULL,
	[Dataset] [varchar](250) NOT NULL,
	[EvaluationMeasureID] [int] NOT NULL,
	[Value] [float] NOT NULL,
 CONSTRAINT [PK_GM_R_ModelEvaluationResults] PRIMARY KEY CLUSTERED 
(
	[ModelID] ASC,
	[SolutionID] ASC,
	[RemodelingTimestamp] ASC,
	[Dataset] ASC,
	[EvaluationMeasureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[GM_R_ModelEvaluationResults]  WITH CHECK ADD  CONSTRAINT [FK_GM_R_ModelEvaluationResults_EvaluationMeasureID] FOREIGN KEY([EvaluationMeasureID])
REFERENCES [dbo].[GM_D_EvaluationMeasures] ([EvaluationMeasureID])
GO

ALTER TABLE [dbo].[GM_R_ModelEvaluationResults] CHECK CONSTRAINT [FK_GM_R_ModelEvaluationResults_EvaluationMeasureID]
GO

ALTER TABLE [dbo].[GM_R_ModelEvaluationResults]  WITH CHECK ADD  CONSTRAINT [FK_GM_R_ModelEvaluationResults_ModelID] FOREIGN KEY([ModelID])
REFERENCES [dbo].[GM_D_Models] ([ModelID])
GO

ALTER TABLE [dbo].[GM_R_ModelEvaluationResults] CHECK CONSTRAINT [FK_GM_R_ModelEvaluationResults_ModelID]
GO


