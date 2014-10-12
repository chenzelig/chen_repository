USE MFG_Solutions
GO

DELETE FROM [dbo].[GM_D_Models] where ModelID = -1
DELETE FROM [dbo].[GM_D_ModelGroups] where ModelGroupID = -1
DELETE FROM [dbo].[GM_D_Solutions] where SolutionID = -1
DELETE FROM [dbo].[GM_D_Parameters]
DELETE FROM [dbo].[GM_D_ParameterLevels] WHERE ParameterLevelID in (1,2,3,4)
DELETE FROM [dbo].[GM_D_DE_ConnectionTypes]

INSERT INTO GM_D_ParameterLevels(ParameterLevelID,ParameterLevel)
						VALUES(			1,		'Solution'		)
INSERT INTO GM_D_ParameterLevels(ParameterLevelID,ParameterLevel)
						VALUES(			2,		'Model Group'		)
INSERT INTO GM_D_ParameterLevels(ParameterLevelID,ParameterLevel)
						VALUES(			3,		'Model'		)
INSERT INTO GM_D_ParameterLevels(ParameterLevelID,ParameterLevel)
						VALUES(			4,		'Feature'		)


INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,ParameterLevelID,DefaultValue)
							VALUES	(	1	,	'Queries For Data Extraction via XML',2,	''		)
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,ParameterLevelID,DefaultValue)
							VALUES	(	3	,	'Data preparation Stored Procedure',3,	''	)
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,ParameterLevelID,DefaultValue)
							VALUES  (	4	,	'Prepared Data Schema',3,'')
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,ParameterLevelID,DefaultValue)
							VALUES	(	5	,	'Modeling Stored Procedure',3,'')
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,ParameterLevelID,DefaultValue)
							VALUES	(	7	,	'Raw Data Schema',2,'')


INSERT INTO [dbo].[GM_D_Solutions] VALUES (-1,'Generic Solution')

INSERT INTO [dbo].[GM_D_ModelGroups] VALUES (-1,-1,'Generic Model Group')

INSERT INTO [dbo].[GM_D_Models] (ModelID,SolutionID,Product,Operation,DieStructure,Package,[Version],GenericColumn,ModelGroupID,IsBackground,IsProduction,IsIndicators)
						VALUES	(	-1	,	-1	,		'',		'',			'',		'',				''			,	'Generic Model',	-1	,		0,			0,			0		)


INSERT INTO GM_D_DE_ConnectionTypes(ConnectionTypeID,ConnectionTypeDesc,ConnectionAttributes)
							VALUES (	  1,		'OpenRowSet',		'SourceType,Driver' )
INSERT INTO GM_D_DE_ConnectionTypes(ConnectionTypeID,ConnectionTypeDesc,ConnectionAttributes)
							VALUES (	  2,		'Credentials',		'ConnPass,Module' )
