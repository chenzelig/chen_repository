@echo off

rem ------------ User Configuration ---------------
SET levelID=%1
SET parameterID=%2
SET executionMode=%3

SET "user="Software\Intel Corporation\MFGSolutions\iBIUser" "
SET "dir="D:\Jobs\AutosysGM.bat \"
SET "proc="USP_GM_MainProcedure"
SET "dataBase=MFGDEV"

rem ---------------------------------------------
GOTO levelID%levelID%

:levelID1 
SET "parameter=@SolutionID"
GOTO success

:levelID2
SET "parameter=@ModelGroupID"
GOTO success

:levelID3
SET "parameter=@ModelID"
GOTO success
rem ---------------------------------------------

:success
SET "cmd=SecureRunAs %user% %dir%%proc% %parameter%=%parameterID% @ExecutionMode=%executionMode%\" %dataBase%""
echo %cmd%
rem %cmd%

