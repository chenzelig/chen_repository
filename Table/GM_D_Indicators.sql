IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_Indicators]') AND type in (N'U'))
	DROP TABLE [dbo].[GM_D_Indicators]


CREATE TABLE [dbo].[GM_D_Indicators](
	[IndicatorID] [int] NOT NULL,
	[IndicatorName] [varchar](50) NOT NULL,
	[IndicatorDefinition] [varchar](1000) NOT NULL,
	[IndicatorCalculatedFieldIDs] [varchar](1000),
 CONSTRAINT [PK_GM_D_Indicators] PRIMARY KEY CLUSTERED 
(
	[IndicatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


