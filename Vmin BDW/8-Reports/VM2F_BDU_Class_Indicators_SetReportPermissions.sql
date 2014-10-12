------------------------------ Create Login --------------------------------
IF EXISTS (SELECT * FROM master.sys.sql_logins WHERE [name] = 'MFG_PoPAI')
	DROP LOGIN MFG_PoPAI

CREATE LOGIN MFG_PoPAI WITH PASSWORD = 'mf6p0P@i', DEFAULT_DATABASE=MFG_Solutions;
GO

------------------------------ Create User --------------------------------
Use MFG_Solutions;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'MFG_PoPAI')
	DROP USER MFG_PoPAI

CREATE USER MFG_PoPAI FOR LOGIN MFG_PoPAI

------------------------------ Set Permissions --------------------------------
USE MFG_Solutions; 
GO

GRANT EXECUTE ON OBJECT::USP_VM2F_BDU_Class_Indicators_GenerateReport TO MFG_PoPAI;
GO 
