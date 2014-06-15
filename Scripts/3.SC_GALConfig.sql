USE AdvancedBIsystem

GO

DELETE FROM [dbo].[GAL_Engines] WHERE EngineName='MFG_Solutions'
DELETE FROM [dbo].[GAL_Engines] WHERE LogEventObjectName='USP_GM_MainProcedure'

INSERT INTO [dbo].[GAL_Engines]  (EngineName,IsDisabled,IsDisabledEmailNotifications,IsDisabledSMSNotifications,IsShadowing)
						VALUES	('MFG_Solutions', 0,		0,										0,				0		)

INSERT INTO [dbo].[GAL_LogEventObjects] (LogEventObjectName,IsDisabled,IsDisabledEmailNotifications,IsDisabledSMSNotifications,IsDisabledMeasures)
							VALUES		('USP_GM_MainProcedure', 0,					0,							0,						0		)

