USE MFG_Solutions

UPDATE A
SET ConnectionAttributes = 'SourceType,ConnectionString'
FROM [dbo].[GM_D_DE_ConnectionTypes] A
where ConnectionTypeId=1

INSERT INTO [dbo].[GM_D_DE_Connections] (ConnectionID,ConnectionTypeID,SourceType,					ConnectionString					,ConnectionDesc)
									VALUES(		2,		1,				'MSDASQL','Driver={iBI DaaS}; Server=ibi-services.intel.com,9999;','OpenRowSet')

INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,	ParameterDesc,	ParameterLevelID,DefaultValue)
							VALUES	(	19,		'Population Filter',		3,			''		)