@echo off

rem ------------ User Configuration ---------------
SET levelID=%1
SET parameterID=%2
SET executionMode=%3


rem ---------------------------------------------
GOTO levelID%levelID%

:levelID1 
SecureRunAs "Software\Intel Corporation\MFGSolutions\iBIUser" "D:\Jobs\AutosysSP.bat \"USP_GM_MainProcedure @SolutionID=%parameterID%\" MFGTEST"
GOTO success

:levelID2
SecureRunAs "Software\Intel Corporation\MFGSolutions\iBIUser" "D:\Jobs\AutosysSP.bat \"USP_GM_MainProcedure @ModelGroupID=%parameterID%\" MFGTEST"
GOTO success

:levelID3
SecureRunAs "Software\Intel Corporation\MFGSolutions\iBIUser" "D:\Jobs\AutosysSP.bat \"USP_GM_MainProcedure @ModelID=%parameterID%\" MFGTEST"
GOTO success
rem ---------------------------------------------

:success


