SET MGID=%1
SecureRunAs "Software\Intel Corporation\MFGSolutions\iBIUser" "D:\Jobs\AutosysSP.bat \"USP_GM_MainProcedure @ModelGroupID=%MGID%\" MFGDEV"