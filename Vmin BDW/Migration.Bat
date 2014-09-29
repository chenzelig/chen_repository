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
REM Prepared By :Peleg, Eyal

ECHO Running "\7-GM\VM2F_BDU_Class_GMconfigurations.sql"...
ECHO SQLCMD -S %1 -d %2  -b -q ".\7-GM\VM2F_BDU_Class_GMconfigurations.sql" 
ECHO if errorlevel 1 goto :error

ECHO Running "\7-GM\USP_VM2F_BDU_Class_Indicators_PreDataExtraction.sql"...
SQLCMD -S %1 -d %2 -q ".\7-GM\USP_VM2F_BDU_Class_Indicators_PreDataExtraction.sql" -b
if errorlevel 1 goto :error

ECHO Running "\7-GM\USP_VM2F_BDU_Class_Indicators_DataPreparation.sql"...
SQLCMD -S %1 -d %2  -b -q ".\7-GM\USP_VM2F_BDU_Class_Indicators_DataPreparation.sql" 
if errorlevel 1 goto :error

ECHO Running "\8-Reports\USP_VM2F_BDU_Class_Indicators_GenerateReport.sql"...
SQLCMD -S %1 -d %2  -b -q ".\8-Reports\USP_VM2F_BDU_Class_Indicators_GenerateReport.sql"
if errorlevel 1 goto :error


:success
echo Migration was successfully completed!
goto exit

:error
echo An unexpected error occured. Migration failed, and might have been partially created.
goto exit

:exit
pause