::::::::::::::::::::::::::::::::::::::::::::
:: Elevate.cmd - Version 4
:: Automatically check & get admin rights
:: see "https://stackoverflow.com/a/12264592/1016343" for description
::::::::::::::::::::::::::::::::::::::::::::
 @echo off
 CLS
 ECHO.
 ECHO =============================
 ECHO Running Admin shell
 ECHO =============================

:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~dpnx0"
 rem this works also from cmd shell, other than %~0
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  ECHO **************************************
  ECHO Invoking UAC for Privilege Escalation
  ECHO **************************************

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"
  
  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)
 ::::::::::::::::::::::::::::
 ::START
 ::::::::::::::::::::::::::::

 title Instalador de aplicativos
 @ECHO OFF
 powershell.exe -command "Set-MpPreference -DisableRealtimeMonitoring $true"
 CLS
 
 
 :MENU
 ECHO.
 ECHO ======================================================
 ECHO =                  MENU PRINCIPAL                    =
 ECHO ======================================================
 ECHO = Selecione um numero para continuar:                =
 ECHO = 1. Instalar base dos aplicativos (chocolatey)      =
 ECHO = 2. Instalar aplicativos                            =
 ECHO = 3. Setar Wallpaper                                 =
 ECHO = 4. Ativar Windows                                  =
 ECHO = 0. Sair                                            =
 ECHO ======================================================
 ECHO. 

 SET /P M=Digite 1, 2, 3, 4 ou 0 e depois pressione ENTER: 
 IF %M%==1 GOTO ICHOCO
 IF %M%==2 GOTO IAPP
 IF %M%==3 GOTO SWP
 IF %M%==4 GOTO ATW
 IF %M%==0 GOTO EOF
 
 :ICHOCO
 @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
 timeout 3
 GOTO MENU
 :IAPP
 choco install adobereader googlechrome firefox jre8 winrar k-litecodecpackfull -y
 GOTO MENU
 :SWP
 wget http://wallpaper.explorer/307.png -outfile C:\windows\System32 oobe\Info\backgrounds\BackgroundDefault.png
 GOTO MENU
 :ATW
 slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
 slmgr /skms kms8.msguides.com
 slmgr /ato
 GOTO MENU

 ECHO %batchName% Arguments: P1=%1 P2=%2 P3=%3 P4=%4 P5=%5 P6=%6 P7=%7 P8=%8 P9=%9
 cmd /k
