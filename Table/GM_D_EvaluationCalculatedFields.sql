IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_EvaluationCalculatedFields]') AND type in (N'U'))
	DROP TABLE [dbo].[GM_D_EvaluationCalculatedFields]



CREATE TABLE [dbo].[GM_D_EvaluationCalculatedFields](
	[EvaluationCalculatedFieldID] [int] NOT NULL,
	[EvaluationCalculatedFieldLogic] [varchar](max) NOT NULL,
	[EvaluationCalculatedFieldName] [varchar](max) NOT NULL
 
CONSTRAINT [PK_GM_D_EvaluationCalculatedFields] PRIMARY KEY CLUSTERED 
(
	[EvaluationCalculatedFieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

