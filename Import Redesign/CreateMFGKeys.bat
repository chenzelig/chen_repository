echo off
cls
echo  " Create key ...."


set USERPASS= "grwrp37$"
set USERNMAE= "GER\sys_AAiBIDaaS"


SecureKeyMgr -set-key "Software\Intel Corporation\MFGSolutions\iBIUser" -user %USERNMAE%  -password %USERPASS% 
SecureKeyMgr -set-key "Software\Wow6432Node\Intel Corporation\MFGSolutions\iBIUser" -user %USERNMAE%  -password %USERPASS% 

echo on
