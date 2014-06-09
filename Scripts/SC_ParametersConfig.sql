insert into [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,DefaultValue)
							VALUES	(	1	,	'QueryTemplate',	''		)
insert into [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,DefaultValue)
							VALUES	(	2	,	'ConnectionID',	''		)

insert into [dbo].[GM_D_Parameters] (ParameterID,ParameterDesc,DefaultValue)
							VALUES	(	3	,	'Creating Prepared Data Stored Procedure',	''		)

INSERT into [dbo].[GM_D_Parameters] Values(4,'Prepared Data Schemna','')

INSERT into [dbo].[GM_D_Parameters] Values(5,'Modeling Stored Procedure','')

INSERT INTO [dbo].[GM_D_Parameters] Values(6,'Connection Type','')


INSERT INTO [dbo].[GM_D_Solutions] Values (-1,'Generic Solution')

INSERT INTO [dbo].[GM_D_ModelGroups] Values (-1,-1,'Generic Model Group',NULL)

SET IDENTITY_INSERT GM_D_Models ON
INSERT INTO [dbo].[GM_D_Models] (ModelID,SolutionID,Product,Operation,DieStructure,Package,[Version/Specification],GenericColumn,ModelGroupID,IsBackground,IsProduction,IsIndicators)
						VALUES	(	-1	,	-1	,		'',		'',			'',		'',				''			,	'Generic Model',	-1	,		0,			0,			0		)
SET IDENTITY_INSERT GM_D_Models OFF

