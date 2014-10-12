@echo off
REM 
REM  ********************************************************************************************
REM  *** VM2F BDU Class Indicators
REM  ********************************************************************************************
REM  
REM  File Name - Migration.bat
REM  Date :29/09/2014 
REM  
REM Server - %1 
REM DB - %2 
REM username - %3 
REM password - %4 
REM Prepared By :Peleg, Eyal

ECHO Running "\7-GM\VM2F_BDU_Class_GMconfigurations.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i "..\7-GM\VM2F_BDU_Class_GMconfigurations.sql" -o "MigrationLog.log"
if errorlevel 1 goto :error

ECHO Running "\7-GM\USP_VM2F_BDU_Class_Indicators_PreDataExtraction.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i "..\7-GM\USP_VM2F_BDU_Class_Indicators_PreDataExtraction.sql" -o "MigrationLog.log"
if errorlevel 1 goto :error

ECHO Running "\7-GM\USP_VM2F_BDU_Class_Indicators_DataPreparation.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i "..\7-GM\USP_VM2F_BDU_Class_Indicators_DataPreparation.sql" -o "MigrationLog.log"
if errorlevel 1 goto :error

ECHO Running "\8-Reports\USP_VM2F_BDU_Class_Indicators_GenerateReport.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i "..\8-Reports\USP_VM2F_BDU_Class_Indicators_GenerateReport.sql" -o "MigrationLog.log"
if errorlevel 1 goto :error

ECHO Running "\8-Reports\VM2F_BDU_Class_Indicators_SetReportPermissions.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i "..\8-Reports\VM2F_BDU_Class_Indicators_SetReportPermissions.sql" -o "MigrationLog.log"
if errorlevel 1 goto :error


:success
echo Migration was successfully completed!
goto exit

:error
echo An unexpected error occured. Migration failed, and might have been partially created.
goto exit

:exit
pause