ALTER SERVER ROLE [sysadmin] ADD MEMBER [GER\sys_AAiBIDaaS]
GO

USE [MFG_Solutions]
GO
IF EXISTS(select * from sysusers where name ='GER\sys_AAiBIDaaS')
	DROP USER [GER\sys_AAiBIDaaS]
GO

USE [AdvancedBIsystem]
GO
IF EXISTS(select * from sysusers where name ='GER\sys_AAiBIDaaS')
	DROP USER [GER\sys_AAiBIDaaS]
GO

USE [EASY_System]
GO
IF EXISTS(select * from sysusers where name ='GER\sys_AAiBIDaaS')
	DROP USER [GER\sys_AAiBIDaaS]
GO

USE [master]
GO
IF EXISTS(select * from sysusers where name ='GER\sys_AAiBIDaaS')
	DROP USER [GER\sys_AAiBIDaaS]
GO

USE [AdvancedBI]
GO
IF EXISTS(select * from sysusers where name ='GER\sys_AAiBIDaaS')
	DROP USER [GER\sys_AAiBIDaaS]
GO