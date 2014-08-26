USE MFG_Solutions
GO

/********************Back Out plan***********************************/
delete [GM_D_Parameters] where ParameterID in (19,20,21,22,23)



UPDATE A
SET ConnectionAttributes = 'SourceType,Driver'
FROM [dbo].[GM_D_DE_ConnectionTypes] A
where ConnectionTypeId=1


/********************************************************************/


UPDATE A
SET ConnectionAttributes = 'SourceType,ConnectionString'
FROM [dbo].[GM_D_DE_ConnectionTypes] A
where ConnectionTypeId=1

--INSERT INTO [dbo].[GM_D_DE_Connections] (ConnectionID,ConnectionTypeID,SourceType,					ConnectionString					,ConnectionDesc)
--									VALUES(		2,		1,				'MSDASQL','Driver={iBI DaaS}; Server=ibi-services.intel.com,9999;','OpenRowSet')

INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,	ParameterDesc, ParameterLevelID,DefaultValue)
							VALUES	(	19,			'Population Filter',		3,			''	 )
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,	ParameterDesc, ParameterLevelID,DefaultValue)
							VALUES	(	20,			'Indicators - Queries For Data Extraction via XML',		2,	 ''	)
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,	ParameterDesc, ParameterLevelID,DefaultValue)
							VALUES	(	21,			'Indicators - Raw Data Schema',		2,			''		)
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,	ParameterDesc, ParameterLevelID,DefaultValue)
							VALUES	(	22,			'Indicators - Prepared Data Schema',		3,			''		)
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,	ParameterDesc, ParameterLevelID,DefaultValue)
							VALUES	(	23,			'Indicators - Data preparation Stored Procedure',		3,			''		)







