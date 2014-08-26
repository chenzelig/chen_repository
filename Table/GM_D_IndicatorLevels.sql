IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_IndicatorLevels]') AND type in (N'U'))
	DROP TABLE [GM_D_IndicatorLevels]


CREATE TABLE [dbo].[GM_D_IndicatorLevels](
	[IndicatorLevelID] [int] NOT NULL,
	[IndicatorComponentID] [int] NOT NULL,
	[IndicatorComponent] VARCHAR(256) NOT NULL,
 CONSTRAINT [PK_GM_D_IndicatorLevels] PRIMARY KEY CLUSTERED 
(
	[IndicatorLevelID] ASC,
	[IndicatorComponentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


