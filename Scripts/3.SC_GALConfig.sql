USE AdvancedBIsystem

GO

DELETE FROM [dbo].[GAL_Engines] WHERE EngineName='MFG_Solutions'

INSERT INTO [dbo].[GAL_Engines]  (EngineName,IsDisabled,IsDisabledEmailNotifications,IsDisabledSMSNotifications,IsShadowing)
						VALUES	('MFG_Solutions', 0,		0,										0,				0		)

DECLARE @EngineID INT
SELECT @EngineID=EngineID
FROM [GAL_Engines]
WHERE EngineName='MFG_Solutions'

--add notifications
IF @@SERVERNAME='FM1PAPVSQLPD\SQL01'
INSERT INTO GAL_EngineNotifications(EngineID,MSG_MethodID,SendAddress,			  IsEnabaled)
							 VALUES(@EngineID,1,		  'itamar.golan@ntel.com',1),
								   (@EngineID,3,		  '0543423804',			  1),
								   (@EngineID,1,		  'gil.ben.shalom@intel.com',1)

								   