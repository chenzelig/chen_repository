
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_IndicatorCalculatedFields]') AND type in (N'U'))
	DROP TABLE [dbo].[GM_D_IndicatorCalculatedFields]


CREATE TABLE [dbo].[GM_D_IndicatorCalculatedFields](
	[IndicatorCalculatedFieldID] [int] NOT NULL,
	[IndicatorCalculatedFieldLogic] [varchar](max) NOT NULL,
	[IndicatorCalculatedFieldName] [varchar](max) NOT NULL,
 CONSTRAINT [PK_GM_D_IndicatorCalculatedFields] PRIMARY KEY CLUSTERED 
(
	[IndicatorCalculatedFieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
