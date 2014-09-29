@echo off

ECHO Running "\Table\GM_D_EvaluationCalculatedFields.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_D_EvaluationCalculatedFields.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Table\GM_D_IndicatorCalculatedFields.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_D_IndicatorCalculatedFields.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Table\GM_D_IndicatorLevels.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_D_IndicatorLevels.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error


ECHO Running "\Table\GM_D_TempDataTable.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_D_TempDataTable.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Table\GM_R_IndicatorLevelInstances.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_R_IndicatorLevelInstances.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Table\GM_R_ModelIndicatorValues.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_R_ModelIndicatorValues.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Table\GM_F_ModelIndicators.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_F_ModelIndicators.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Table\GM_D_Indicators.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_D_Indicators.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Table\GM_F_ModelEvaluation.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_F_ModelEvaluation.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Table\GM_R_ModelEvaluationResults.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_R_ModelEvaluationResults.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Table\GM_D_EvaluationMeasures.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Table\GM_D_EvaluationMeasures.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Functions\UDF_GM_GetFormulaString.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Functions\UDF_GM_GetFormulaString.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\Functions\UDF_SolutionID_PartitionFunction.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\Functions\UDF_SolutionID_PartitionFunction.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error


ECHO Running "\SP\USP_GM_EvaluationProcedure.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\SP\USP_GM_EvaluationProcedure.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

ECHO Running "\SP\USP_GM_IndicatorProcedure.sql"...
SQLCMD -S %1 -d %2 -U %3 -P %4 -b -i ".\SP\USP_GM_IndicatorProcedure.sql" -o "DBObjectsMigration.log"
if errorlevel 1 goto :error

:success
echo Migration was successfully completed!
goto exit

:error
echo An unexpected error occured. Migration failed, and might have been partially created.
goto exit

:exit
pause
