USE MFG_Solutions
GO

INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,DefaultValue)
							VALUES	(	1	,	'QueryTemplate',	''		)
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,DefaultValue)
							VALUES	(	2	,	'ConnectionID',	''		)
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,DefaultValue)
							VALUES	(	3	,	'Creating Prepared Data Stored Procedure',	''		)
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,DefaultValue)
							VALUES  (	4	,	'Prepared Data Schema','')
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,DefaultValue)
							VALUES	(	5	,	'Modeling Stored Procedure','')
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,DefaultValue)
							VALUES	(	6	,	'Connection Type','')
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,DefaultValue)
							VALUES	(	7	,	'Raw Data Schema','')


INSERT INTO [dbo].[GM_D_Solutions] VALUES (-1,'Generic Solution')

INSERT INTO [dbo].[GM_D_ModelGroups] VALUES (-1,-1,'Generic Model Group',NULL)

SET IDENTITY_INSERT GM_D_Models ON
INSERT INTO [dbo].[GM_D_Models] (ModelID,SolutionID,Product,Operation,DieStructure,Package,[Version/Specification],GenericColumn,ModelGroupID,IsBackground,IsProduction,IsIndicators)
						VALUES	(	-1	,	-1	,		'',		'',			'',		'',				''			,	'Generic Model',	-1	,		0,			0,			0		)
SET IDENTITY_INSERT GM_D_Models OFF

