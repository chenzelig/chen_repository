USE MFG_Solutions
GO

DELETE FROM [dbo].[GM_D_Parameters] 
DELETE FROM [dbo].[GM_D_Solutions] WHERE SolutionID=-1
DELETE FROM [dbo].[GM_D_Models] WHERE ModelID=-1
DELETE FROM [dbo].[GM_D_ModelGroups] WHERE ModelGroupID=-1


INSERT INTO [dbo].[GM_D_Parameters] (ParameterID, ParameterDesc,					   ParameterLevelID, DefaultValue)
							VALUES	(	1	,	  'QueryTemplate',					   2,				 '')
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID, ParameterDesc,					   ParameterLevelID, DefaultValue)
							VALUES	(	3	,	  'Data preparation Stored Procedure', 2,			     '')
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID, ParameterDesc,					   ParameterLevelID, DefaultValue)
							VALUES  (	4	,	  'Prepared Data Schema',			   2,				 '')
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID, ParameterDesc,					   ParameterLevelID, DefaultValue)
							VALUES	(	5	,	  'Modeling Stored Procedure',		   3,				 '')
INSERT INTO [dbo].[GM_D_Parameters] (ParameterID, ParameterDesc,					   ParameterLevelID, DefaultValue)
							VALUES	(	7	,	  'Raw Data Schema',				   2,				 '')


INSERT INTO [dbo].[GM_D_Solutions] VALUES (-1,'Generic Solution')

INSERT INTO [dbo].[GM_D_ModelGroups] VALUES (-1,-1,'Generic Model Group',NULL)

INSERT INTO [dbo].[GM_D_Models] (ModelID,SolutionID,Product,Operation,DieStructure,Package,[Version/Specification],GenericColumn,ModelGroupID,IsBackground,IsProduction,IsIndicators)
						VALUES	(	-1	,	-1	,		'',		'',			'',		'',				''			,	'Generic Model',	-1	,		0,			0,			0		)
