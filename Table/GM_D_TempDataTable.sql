IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GM_D_TempDataTable]') AND type in (N'U'))
	DROP TABLE [GM_D_TempDataTable]

CREATE TABLE [dbo].[GM_D_TempDataTable](
	[ID] [int] NOT NULL,
	[DataTable] [varchar](1000) NOT NULL,
 CONSTRAINT [PK_GM_D_TempDataTable] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


insert into [dbo].[GM_D_TempDataTable] values
(1,'#ATM_GM_RawData')
insert into [dbo].[GM_D_TempDataTable] values
(2,'#PreparedData')
insert into [dbo].[GM_D_TempDataTable] values
(3,'#ATM_GM_Indicators_RawData')
insert into [dbo].[GM_D_TempDataTable] values
(4,'ATM_GM_Indicators_PreparedData')

