IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_EvaluationMeasures]') AND type in (N'U'))
	DROP TABLE [GM_D_EvaluationMeasures]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[GM_D_EvaluationMeasures](
	[EvaluationMeasureID] [int] NOT NULL,
	[EvaluationMeasureName] [varchar](250) NOT NULL,
	[EvaluationDefinition] [varchar](max) NOT NULL,
	[EvaluationCalculatedFieldIDs] [varchar](max)
 CONSTRAINT [PK_GM_D_EvaluationMeasures] PRIMARY KEY CLUSTERED 
(
	[EvaluationMeasureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


SET ANSI_PADDING OFF
GO
