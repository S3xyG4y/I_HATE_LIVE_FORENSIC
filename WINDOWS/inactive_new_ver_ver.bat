@echo off
setlocal enabledelayedexpansion

SET "curDir=%~dp0"
SET "ETC=%~dp0etc"
set "sysinternals=%~dp0sysinternalsSuite"
SET "HASH=%~dp0HASH"
set "dump=%~dp0Memory_Dump_Tool"
set "kape=%~dp0kape"
SET "PATH=%curDir%;%ETC%;%sysinternals%;%HASH%;%dump%;%kape%;%PATH%"

set "CASE=%~1"
set "NAME=%~2"
set "_System_Drive=%systemdrive%"
set "_FirstCharacter=%_System_Drive:~0,1%"

call :GetTimestamp
if "%~3"=="" (
    set foldername=%computername%_!timestamp!
) else (
    set foldername=%3
)
if not exist %foldername% (
    mkdir %foldername%
    echo "created %foldername%"
) else (
    echo Folder %foldername% already exists. Skipping creation.
)
echo CREATE %foldername% DIRECTORY 

set _TimeStamp=%foldername%\TimeStamp.log
echo [!timestamp!] Inactive Script START TIME >> %_TimeStamp%

:INPUT_CASE
    echo [!timestamp!] CASE: %CASE% >> %_TimeStamp%

:INPUT_NAME
    echo [!timestamp!] NAME: %NAME% >> %_TimeStamp%

:START
echo %CASE% - %NAME% Inactive Data Collection Begins >> %_TimeStamp%
echo .

set NONVOLATILE_DIR=%foldername%\NONVOLATILE
mkdir %NONVOLATILE_DIR%
echo [!timestamp!] CREATE NONVOLATILE DIRECTORY >> %_TimeStamp%

:: Check .NET Framework4 or 6
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" >nul 2>&1
if %errorlevel%==0 (
    echo .NET Framework version 4 is installed. >>%NONVOLATILE_DIR%\basic_info.txt
    echo [!timestamp!] basic_info checked >> %_TimeStamp%
    set "net=4"
    set "mftecmd=%curDir%\net4\MFTECmd\MFTECmd.exe"
    set "rbcmd=%curDir%\net4\RBCMD\RBCmd.exe"
    set "lecmd=%curDir%\net4\LECmd\LECmd.exe"
    set "jlecmd=%curDir%\net4\JLECmd\JLECmd.exe"
    set "pecmd=%curDir%\net4\PECmd\PECmd.exe"
    set "evtxecmd=%curDir%\net4\EvtxeCmd\EvtxECmd.exe"
    goto Check_Architecture
)

reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v6.0" >nul 2>&1
if %errorlevel%==0 (
    echo .NET Framework version 6 is installed. >> %NONVOLATILE_DIR%\basic_info.txt
    echo [!timestamp!] basic_info checked >> %_TimeStamp%
    set "net=6"
    set "mftecmd=%curDir%\net6\MFTECmd\MFTECmd.exe"
    set "rbcmd=%curDir%\net6\RBCmd\RBCmd.exe"
    set "lecmd=%curDir%\net6\LECmd\LECmd.exe"
    set "jlecmd=%curDir%\net6\JLECmd\JLECmd.exe"
    set "pecmd=%curDir%\net6\PECmd\PECmd.exe"
    set "evtxecmd=%curDir%\net6\EvtxeCmd\EvtxECmd.exe"
    goto Check_Architecture
)

echo .NET Framework is not installed. >> %NONVOLATILE_DIR%\basic_info.txt
echo [!timestamp!] basic_info checked >> %_TimeStamp%
goto Check_Architecture

:Check_Architecture
    :: -----------------Architecture Detection-----------------
    if %PROCESSOR_ARCHITECTURE%==AMD64 (
        echo 64-bit operating system detected. >> %NONVOLATILE_DIR%\basic_info.txt
        set "psexec=%sysinternals%\PsExec64.exe"
        set "CyLR=%dump%\CyLR\CyLR_64.exe"
        set "hashdeep=%HASH%\hashdeep64.exe"

    ) else if %PROCESSOR_ARCHITECTURE%==x86 (
        echo 32-bit operating system detected. >> %NONVOLATILE_DIR%\basic_info.txt
        set "psexec=%sysinternals%\PsExec.exe"
        set "CyLR=%dump%\CyLR\CyLR_32.exe"
        set "hashdeep=%HASH%\hashdeep.exe"
    ) else (
        echo Unknown archtecture detected. >> %NONVOLATILE_DIR%\basic_info.txt
    )

echo **********************************
echo.
echo NONVOLATILE DATA
echo.
echo **********************************
echo.
echo.

set final_step=9
set choice=

:Menu
    echo.
    echo ====================================
    echo Select the step you want to perform:
    echo ====================================
    echo [1] File System MetaData       - Collects MFT, Boot, Amcache
    echo [2] Registry File              - Collects SAM, SYSTEM, SOFTWARE, SECURITY
    echo [3] Prefetch File              - Collects Prefetch and Superfetch
    echo [4] Event Log File             - Collects Event Log for target host
    echo [5] Recycle Bin Information    - Collects Recycle Bin Info
    echo [6] Browser Artifact           - Collects Browser Cache, Cookie, Browser History, Download History
    echo [7] System Restore Point       - Collects Restore Point (or System Volume Information)
    echo [8] Portable System History    - Collects Portable Device Information
    echo [9] Link File                  - Collects Link File and JumpLists
    echo [a] RUN ALL STEPS
    echo [q] QUIT
    echo.
    set /p choice="You entered : "

    if not defined choice (
        goto :Menu
    ) else (
        set "steps="
        for %%x in (%choice%) do (
            if /i "%%x"=="q" (
                IF EXIST forecopy_handy.log (
                    move forecopy_handy.log %NONVOLATILE_DIR%\
                )
                echo %CASE% - %NAME% Inactive Data Collection finished >> %_TimeStamp%
                call :LogStep
                exit /b
            ) else if /i "%%x"=="a" (
                for /l %%i in (1, 1, %final_step%) do (
                    set "steps=!steps! %%i"
                )
            ) else (
                set "steps=!steps! %%x"
            )
        )
    for %%x in (!steps!) do (
        call :RUN_STEP_%%x
        )
    )
    goto :Menu


:RUN_STEP_1
    call :LogStep
    call :GetTimestamp
    set _FileSystem=%NONVOLATILE_DIR%\FileSystem
    mkdir %_FileSystem%
    echo.
    echo [RUN_STEP_1] Create FileSystem Data Directory
    echo [!timestamp!] Create FileSystem Data Directory >> %_TimeStamp%
    set _FileSystemModule=%_FileSystem%\FileSystemModule
    mkdir %_FileSystemModule%
    echo [!timestamp!] Create FileSystem Module Directory >> %_TimeStamp%

    
    echo.
    if "%net%"=="4" (
        goto RUN_STEP_1_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_1_NET6
    ) else (
        goto RUN_STEP_1_Fore
    )

:RUN_STEP_1_Fore
    call :GetTimestamp
    echo Acquring FileSystem Data...
    echo [!timestamp!] Acquring FileSystem Data... >> %_TimeStamp%
    forecopy_handy -m %_FileSystem%
    goto RUN_STEP_1_Hash
    
:RUN_STEP_1_NET4
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target FileSystem --tdest %_FileSystem% 
    %kape%\kape.exe --msource %_FileSystem% --module MFTECmd --mdest %_FileSystemModule% 
    
    ::%mftecmd% -f %_FileSystem%\%_FirstCharacter%\$MFT --csv %_FileSystem% --csvf "mft_parser.csv" >NUL
    ::%mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Boot --csv %_FileSystem% --csvf "Boot_parser.csv" >NUL
    ::%mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Extend\$J --csv %_FileSystem% --csvf "Extend_parser.csv" >NUL
    ::%mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Secure_$SDS --csv %_FileSystem% --csvf "SDS_parser.csv" >NUL
    goto RUN_STEP_1_Hash

:RUN_STEP_1_NET6
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target FileSystem --tdest %_FileSystem%
    %kape%\kape.exe --msource %_FileSystem% --module MFTECmd --mdest %_FileSystemModule% 

    ::%mftecmd% -f %_FileSystem%\%_FirstCharacter%\$MFT --csv %_FileSystem% --csvf "mft_parser.csv" >NUL
    ::%mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Boot --csv %_FileSystem% --csvf "Boot_parser.csv" >NUL
    ::%mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Extend\$J --csv %_FileSystem% --csvf "Extend_parser.csv" >NUL
    ::%mftecmd% -f %_FileSystem%\%_FirstCharacter%\$Secure_$SDS --csv %_FileSystem% --csvf "SDS_parser.csv" >NUL
    goto RUN_STEP_1_Hash

:RUN_STEP_1_Hash
    call :GetTimestamp
    set _FileSystem_Hash=%_FileSystem%\Hash
    mkdir %_FileSystem_Hash%
    echo.
    echo CREATE FileSystem HASH DIRECTORY
    echo [!timestamp!] CREATE FileSystem HASH Directory >> %_TimeStamp%
    echo.
    echo Acquring FileSystem Hash
    echo [!timestamp!] Acquring FileSystem Hash >> %_TimeStamp%
    %hashdeep% -e -r %_FileSystem% > "%_FileSystem_Hash%\FileSystem_Hash.txt"
    goto RUN_STEP_1_Clear

:RUN_STEP_1_Clear
    echo RUN_STEP_1 CLEAR
    exit /b

:RUN_STEP_2
    call :LogStep
    call :GetTimestamp
    set Registry=%NONVOLATILE_DIR%\Registry
    mkdir %Registry%
    echo.
    echo Create Registry Directory 
    echo [!timestamp!] Create Registry Directory >> %_TimeStamp%
    echo.
    set RegistryModule=%Registry%\Module
    mkdir %RegistryModule%
    echo [!timestamp!] Create Registry Module Directory >> %_TimeStamp% 

    if "%net%"=="4" (
        goto RUN_STEP_2_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_2_NET6
    ) else (
        goto RUN_STEP_2_Fore
    )

:RUN_STEP_2_FORE
    call :GetTimestamp
    echo Acquring Registry...
    echo [!timestamp!] Acquring Registry >> %_TimeStamp%
    forecopy_handy -g %Registry%
    goto RUN_STEP_2_HASH

:RUN_STEP_2_NET4
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target RegistryHives --tdest %Registry% >NUL
    %kape%\kape.exe --msource %Registry%\%_FirstCharacter% --module RECmd_AllBatchFiles --mdest %RegistryModule%
    goto RUN_STEP_2_HASH

:RUN_STEP_2_NET6
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target RegistryHives --tdest %Registry% >NUL
    %kape%\kape.exe --msource %Registry%\%_FirstCharacter% --module RECmd_AllBatchFiles --mdest %RegistryModule%
    goto RUN_STEP_2_HASH

:RUN_STEP_2_HASH
    call :GetTimestamp
    set _REGISTRY_HASH=%Registry%\Hash
    mkdir %_REGISTRY_HASH%
    echo.
    echo Create Registry Hash Directory 
    echo [!timestamp!] Create Registry Hash Directory >> %_TimeStamp%
    echo.
    echo Calculate Registry Hash...
    echo [!timestamp!] Calculate Registry Hash... >> %_TimeStamp%
    %hashdeep% -e -r %Registry%  > %REGISTRY_HASH%\REGISTRY_Hash.txt  

    goto RUN_STEP_2_CLEAR

:RUN_STEP_2_CLEAR
    echo RUN_STEP_2 CLEAR
    exit /b

:RUN_STEP_3
    call :LogStep
    call :GetTimestamp
    set _Prefetch=%NONVOLATILE_DIR%\Prefetch
    mkdir %_Prefetch%
    echo.
    echo [RUN_STEP_3] Create Prefetch Directory 
    echo [!timestamp!] Create Prefetch Directory >> %_TimeStamp%

    set _Prefetch_Module=%_Prefetch%\Module
    mkdir %_Prefetch_Module%
    echo [!timestamp!] Create Prefetch Module Directory >> %_TimeStamp%

    if "%net%"=="4" (
        goto RUN_STEP_3_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_3_NET6
    ) else (
        goto RUN_STEP_3_Fore
    )

:RUN_STEP_3_FORE
    call :GetTimestamp
    echo Acquring Prefetch...
    echo [!timestamp!] Acquring Prefetch... >> %_TimeStamp%
    forecopy_handy -p %_Prefetch%
    goto RUN_STEP_3_HASH

:RUN_STEP_3_NET4
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target Prefetch --tdest %_Prefetch% >NUL
    %kape%\kape.exe --msource %_Prefetch%\%_FirstCharacter% --module PECmd --mdest %_Prefetch_Module%
    goto RUN_STEP_3_HASH

:RUN_STEP_3_NET6
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target Prefetch --tdest %_Prefetch% >NUL
    %kape%\kape.exe --msource %_Prefetch%\%_FirstCharacter% --module PECmd --mdest %_Prefetch_Module%
    goto RUN_STEP_3_HASH

:RUN_STEP_3_HASH
    call :GetTimestamp
    set Prefetch_Hash=%_Prefetch%\Hash
    mkdir %Prefetch_Hash%
    echo Create Prefetch Hash Directory
    echo [!timestamp!] Create Prefetch Hash Directory >> %_TimeStamp%
    echo.
    echo Calculate Prefetch Hash...
    echo [!timestamp!] Calculate Prefetch Hash... >> %_TimeStamp%
    %hashdeep% -e -r %_Prefetch% > %Prefetch_Hash%\Prefetch_Hash.txt
    goto RUN_STEP_3_Clear

:RUN_STEP_3_Clear
    echo RUN_STEP_3 CLEAR
    exit /b

:RUN_STEP_4
    call :LogStep
    call :GetTimestamp
    set _eventLog=%NONVOLATILE_DIR%\EventLog
    mkdir %_eventLog%
    echo.
    echo [RUN_STEP_4] Create EventLog Directory
    echo [!timestamp!] Create EventLog Directory >> %_TimeStamp%

    set _eventLogModule=%_eventLog%\EventRipper
    mkdir %_eventLogModule%
    echo [!timestamp!] Create Event Ripper Directory >> %_TimeStamp%


    if "%net%"=="4" (
        goto RUN_STEP_4_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_4_NET6
    ) else (
        goto RUN_STEP_4_Fore
    )

:RUN_STEP_4_NET4
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target CombinedLogs --tdest %_eventLog% >NUL
    %kape%\kape.exe --msource %_eventLog% --module Events-Ripper --mdest %_eventLogModule%
    ::%evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Application.evtx --csv %_eventLog% --csvf "Application_Parser.csv" >NUL
    ::%evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Security.evtx --csv %_eventLog% --csvf "Security_Parser.csv" >NUL
    ::%evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\System.evtx --csv %_eventLog% --csvf "System_Parser.csv" >NUL
    ::%evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Setup.evtx --csv %_eventLog% --csvf "Setup_Parser.csv" >NUL
    
    goto RUN_STEP_4_SERVER

:RUN_STEP_4_NET6
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target CombinedLogs --tdest %_eventLog% >NUL
    %kape%\kape.exe --msource %_eventLog% --module Events-Ripper --mdest %_eventLogModule%
    ::%evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Application.evtx --csv %_eventLog% --csvf "Application_Parser.csv" >NUL
    ::%evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Security.evtx --csv %_eventLog% --csvf "Security_Parser.csv" >NUL
    ::%evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\System.evtx --csv %_eventLog% --csvf "System_Parser.csv" >NUL
    ::%evtxecmd% -f %systemdrive%\Windows\System32\winevt\Logs\Setup.evtx --csv %_eventLog% --csvf "Setup_Parser.csv" >NUL
    
    goto RUN_STEP_4_SERVER

:RUN_STEP_4_SERVER
    call :GetTimestamp
    set _Webserver=%_eventLog%\WebServer
    mkdir %_Webserver%
    echo.
    echo [RUN_STEP_4] Create WebServer Directory 
    echo [!timestamp!] Create WebServer Directory >> %_TimeStamp%
    %kape%\kape.exe --tsource %SystemDrive% --target WebServers --tdest %_Webserver% >NUL
    goto RUN_STEP_4_HASH

:RUN_STEP_4_FORE
    call :GetTimestamp
    echo.
    echo [RUN_STEP_4] Acquring Event Log
    echo [!timestamp!] Acquring Event Log >> %_TimeStamp%
    forecopy_handy -e  %_eventLog%
    goto RUN_STEP_4_HASH

:RUN_STEP_4_HASH
    call :GetTimestamp
    set eventHash=%_eventLog%\Hash
    mkdir %eventHash%
    echo.
    echo [RUN_STEP_4] Create EventLog Hash Directory
    echo [!timestamp!] Create EventLog Hash Directory >> %_TimeStamp%
    echo.
    echo [RUN_STEP_4] Calculate Event Hash...
    echo [!timestamp!] Calculate Event Hash... >> %_TimeStamp%
    %hashdeep% -e -r %_eventLog% > %eventHash%\EventLog_Hash.txt
    goto RUN_STEP_4_Clear

:RUN_STEP_4_Clear
    echo RUN_STEP_4 CLEAR
    exit /b

:RUN_STEP_5
    call :LogStep
    call :GetTimestamp
    set recycleBin=%NONVOLATILE_DIR%\RecycleBin
    mkdir %recycleBin%
    echo.
    echo [RUN_STEP_5] Create RecycleBin Directory
    echo [!timestamp!] Create RecycleBin Directory >> %_TimeStamp%

    set RecycleBin_Module=%recycleBin%\Module
    mkdir %RecycleBin_Module%
    echo [!timestamp!] Create Recycle Bin Module Directory >> %_TimeStamp%

    if "%net%"=="4" (
        goto RUN_STEP_5_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_5_NET6
    ) else (
        goto RUN_STEP_5_FORE
    )
:RUN_STEP_5_NET4
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target RecycleBin --tdest %recycleBin%
    %kape%\kape.exe --msource %recycleBin%\%_FirstCharacter% --module RBCmd --mdest %RecycleBin_Module%
    goto RUN_STEP_5_HASH

:RUN_STEP_5_NET6
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target RecycleBin --tdest %recycleBin%
    %kape%\kape.exe --msource %recycleBin%\%_FirstCharacter% --module RBCmd --mdest %RecycleBin_Module%
    goto RUN_STEP_5_HASH

:RUN_STEP_5_FORE
    call :GetTimestamp
    echo Acquring Recycle Data ...
    echo [!timestamp!] Acquring Recycle Data ... >> %_TimeStamp%
    forecopy_handy -r %SystemDrive%\$Recycle.Bin %recycleBin%
    echo [RUN_STEP_5] xcopy execute
    echo [!timestamp!] xcopy completed(Step5) >> %_TimeStamp%
    xcopy /e /h /y %SystemDrive%\$Recycle.Bin %recycleBin% 2>> %recycleBin%\recycleBin_collect_Error.log
    goto RUN_STEP_5_HASH

:RUN_STEP_5_HASH
    call :GetTimestamp
    set recycleBinHash=%recycleBin%\Hash
    mkdir %recycleBinHash%
    echo [!timestamp!] Create RecycleBin Hash Directory >> %_TimeStamp%
    echo.
    echo Calculate RecycleBin Hash...
    %hashdeep% -e -r %recycleBin% > %recycleBinHash%\RecycleBin_Hash.txt
    echo [!timestamp!] Calculate RecycleBin Hash... >> %_TimeStamp%
    goto RUN_STEP_5_Clear

:RUN_STEP_5_Clear
    echo RUN_STEP_5 CLEAR
    exit /b

:RUN_STEP_6
    call :LogStep
    call :GetTimestamp
    set Browser=%NONVOLATILE_DIR%\Browser
    set _Edge=%Browser%\Edge
    set _Chromium=%Browser%\Chromium
    set _Chrome=%Browser%\Chrome
    set _IE=%Browser%\IE
    set _Firefox=%Browser%\Firefox
    set _WebCache=%Browser%\WebCache

    set _Edge_Hash=%_Edge%\Hash
    set _Chromium_Hash=%_Chromium%\Hash
    set _Chrome_Hash=%_Chrome%\Hash
    set _IE_Hash=%_IE%\Hash
    set _Firefox_Hash=%_Firefox%\Hash
    set _WebCache_Hash=%_WebCache%\Hash

    mkdir %Browser%
    echo.
    echo Create Browser Initial Directory
    echo [!timestamp!] Create Browser Directory >> %_TimeStamp%
    mkdir %_Chrome%
    echo [!timestamp!] Create Chrome Directory >> %_TimeStamp%
    mkdir %_Edge%
    echo [!timestamp!] Create Edge Directory >> %_TimeStamp%
    mkdir %_IE%
    echo [!timestamp!] Create IE Directory >> %_TimeStamp%
    mkdir %_Chromium%
    echo [!timestamp!] Create Chromium Directory >> %_TimeStamp%
    mkdir %_Firefox%
    echo [!timestamp!] Create Firefox Directory >> %_TimeStamp%
    mkdir %_WebCache%
    echo [!timestamp!] Create WebCache Directory >> %_TimeStamp%

    if "%net%"=="4" (
        goto RUN_STEP_6_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_6_NET6
    ) else (
        goto RUN_STEP_6_Fore
    )

:RUN_STEP_6_Fore
    call :GetTimestamp
    :: Chrome
    echo.
    echo Acquring Chrome Data...
    echo [!timestamp!] Acquring Chrome Data... >> %_TimeStamp%

    forecopy_handy -r "%LocalAppData%\Google\Chrome\User Data\Default\Cache" %_Chrome%
    forecopy_handy -r "%LocalAppData%\Google\Chrome\User Data\Default\Download Service" %_Chrome%
    forecopy_handy -r "%LocalAppData%\Google\Chrome\User Data\Default\Network" %_Chrome%
    forecopy_handy -f "%LocalAppData%\Google\Chrome\User Data\Default\History" %_Chrome%

    :: Edge
    echo.
    echo Acquring Edge Data...
    echo [!timestamp!] Acquring Edge Data... >> %_TimeStamp%
    forecopy_handy -r "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" %_Edge% 
    forecopy_handy -r "%LocalAppData%\Microsoft\Edge\User Data\Default\Download Service" %_Edge%
    forecopy_handy -r "%LocalAppData%\Microsoft\Edge\User Data\Default\Network" %_Edge%
    forecopy_handy -f "%LocalAppData%\Microsoft\Edge\User Data\Default\History" %_Edge%

    :: Firefox
    echo.
    echo Acquring Firefox Data...
    echo [!timestamp!] Acquring Firefox Data... >> %_TimeStamp%
    ::forecopy_handy -x %_Firefox%
    
    :: Firefox Cache
    :: xcopy /E /I "%LocalAppData%\Mozilla\Firefox\Profiles\*.default-release\cache2" "%_Firefox%\Cache"
    :: Firefox cookies
    :: xcopy /E /I "%AppData%\Mozilla\Firefox\Profiles\*.default-release\cookies.sqlite" "%_Firefox%\cookies"
    :: User's environment settings
    :: xcopy /E /I "%AppData%\Mozilla\Firefox\Profiles\*.default-release\prefs.js" "%_Firefox%\prefs"
    :: Site-specific permissions
    :: xcopy /E /I "%AppData%\Mozilla\Firefox\Profiles\*.default-release\permissions.sqlite" "%_Firefox%\permissions"
    :: Firefox History, Downloads, Network Error Logging
    :: xcopy /E /I "%AppData%\Mozilla\Firefox\Profiles\*.default-release\places.sqlite" "%_Firefox%\history_downloads_NEL"

    :: Copy entire Firefox profile directories
    xcopy /E /I "%LocalAppData%\Mozilla\Firefox\Profiles" "%_Firefox%\LocalFirefoxProfiles"
    xcopy /E /I /EXCLUDE:%ETC%\browser_exclude.txt "%AppData%\Mozilla\Firefox\Profiles" "%_Firefox%\RoamingFirefoxProfiles"

    :: WebCache
    echo.
    echo Acquring WebCache.DAT...
    echo [!timestamp!] Acquring WebCache.DAT... >> %_TimeStamp%
    forecopy_handy -f "%LocalAppData%\Microsoft\Windows\WebCache\WebCacheV01.DAT" %_WebCache%

    goto Browser_Hash

:RUN_STEP_6_NET4
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target Chrome --tdest %_Chrome% >NUL
    %kape%\kape.exe --tsource %SystemDrive% --target ChromeExtensions --tdest %_Chrome% >NUL
    %kape%\kape.exe --tsource %SystemDrive% --target ChromeFileSystem --tdest %_Chrome% >NUL
    echo [!timestamp!] Acquring Chrome Data... >> %_TimeStamp% 
    
    %kape%\kape.exe --tsource %SystemDrive% --target Edge --tdest %_Edge% >NUL
    echo [!timestamp!] Acquring Edge Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target Firefox --tdest %_Firefox% >NUL
    echo [!timestamp!] Acquring Firefox Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target InternetExplorer --tdest %_IE% >NUL
    echo [!timestamp!] Acquring InternetExplorer Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target EdgeChromium --tdest %_Chromium% >NUL
    echo [!timestamp!] Acquring Chromium Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target BrowserCache --tdest %_WebCache% >NUL
    echo [!timestamp!] Acquring BrowserCache Data... >> %_TimeStamp% 

    goto Browser_Hash

:RUN_STEP_6_NET6
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target Chrome --tdest %_Chrome% >NUL
    %kape%\kape.exe --tsource %SystemDrive% --target ChromeExtensions --tdest %_Chrome% >NUL
    %kape%\kape.exe --tsource %SystemDrive% --target ChromeFileSystem --tdest %_Chrome% >NUL
    echo [!timestamp!] Acquring Chrome Data... >> %_TimeStamp%
    %kape%\kape.exe --tsource %SystemDrive% --target Edge --tdest %_Edge% >NUL
    echo [!timestamp!] Acquring Edge Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target Firefox --tdest %_Firefox% >NUL
    echo [!timestamp!] Acquring Firefox Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target InternetExplorer --tdest %_IE% >NUL
    echo [!timestamp!] Acquring InternetExplorer Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target EdgeChromium --tdest %_Chromium% >NUL
    echo [!timestamp!] Acquring Chromium Data... >> %_TimeStamp% 

    %kape%\kape.exe --tsource %SystemDrive% --target BrowserCache --tdest %_WebCache% >NUL
    echo [!timestamp!] Acquring BrowserCache Data... >> %_TimeStamp% 

    goto Browser_Hash

:Browser_Hash
    call :GetTimestamp
    mkdir %_Chrome_Hash%
    echo [!timestamp!] Create Chrome Hash Directory >> %_TimeStamp%
    echo Calculate Chrome Hash
    echo [!timestamp!] Calculate Chrome Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Chrome% > %_Chrome_Hash%\Chrome_Hash.txt

    mkdir %_Firefox_Hash%
    echo [!timestamp!] Create Firefox Hash Directory >> %_TimeStamp%
    echo Calculate Firefox Hash
    echo [!timestamp!] Calculate Firefox Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Firefox% > %_Firefox_Hash%\Firefox_Hash.txt 

    mkdir %_Edge_Hash%
    echo [!timestamp!] Create Edge Hash Directory >> %_TimeStamp%
    echo Calculate Edge Hash
    echo [!timestamp!] Calculate Edge Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Edge% > %_Edge_Hash%\Edge_Hash.txt 
    
    mkdir %_IE_Hash%
    echo [!timestamp!] Create IE Hash Directory >> %_TimeStamp%
    echo Calculate IE Hash
    echo [!timestamp!] Calculate IE Hash >> %_TimeStamp%
    %hashdeep% -e -r %_IE% > %_IE_Hash%\IE_Hash.txt 
    
    mkdir %_Chromium_Hash%
    echo [!timestamp!] Create Chromium Hash Directory >> %_TimeStamp%
    echo Calculate Whale Hash
    echo [!timestamp!] Calculate Chromium Hash >> %_TimeStamp%
    %hashdeep% -e -r %_Chromium% > %_Chromium_Hash%\Chromium_Hash.txt 

    mkdir %_WebCache_Hash%
    echo [!timestamp!] Create WebCache Hash Directory >> %_TimeStamp%
    echo Calcultae WebCache Hash
    echo [!timestamp!] Calculate WebCache Hash >> %_TimeStamp%
    %hashdeep% -e -r %_WebCache% > %_WebCache_Hash%\WebCache_Hash.txt

    echo RUN_STEP_6 CLEAR
    echo [!timestamp!] RUN_STEP_6 CLEAR>> %_TimeStamp%
    exit /b

:RUN_STEP_7
    call :GetTimestamp
    set _restore=%NONVOLATILE_DIR%\Restore
    mkdir %_restore%
    echo.
    echo [RUN_STEP_7] Create Restore Directory
    echo [!timestamp!] Create Restore Directory >> %_TimeStamp%
    :: forecopy_handy -dr %SYSTEMROOT%\system32\Restore %_restore%
    :: xcopy /E /H /I "%SYSTEMROOT%\system32\Restore" "%_restore%"
    :: echo [!timestamp!] Restore File >> %_TimeStamp%
    :: forecopy_handy -dr %HOMEDRIVE%\System Volume Information\_restore{guid} %_restore%
    if "%net%"=="4" (
        goto RUN_STEP_7_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_7_NET6
    ) else (
        goto RUN_STEP_7_COPY
    )
:RUN_STEP_7_NET4
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target XPRestorePoints --tdest %_restore%
    goto RUN_STEP_7_HASH
:RUN_STEP_7_NET6
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target XPRestorePoints --tdest %_restore%
    goto RUN_STEP_7_HASH
:RUN_STEP_7_COPY
    call :GetTimestamp
    xcopy /E /H /I "%SYSTEMROOT%\system32\Restore" "%_restore%"
    goto RUN_STEP_7_HASH
:RUN_STEP_7_HASH
    call :GetTimestamp
    set Restore_Hash=%_restore%\Hash
    mkdir %Restore_Hash%
    echo.
    echo [RUN_STEP_7] Create Restore Hash Directory
    echo [!timestamp!] Create Restore Hash Directory >> %_TimeStamp%
    %hashdeep% -e -r %_restore% > %Restore_Hash%\Restore_Hash.txt
:RUN_STEP_7_Clear
    echo RUN_STEP_7 CLEAR
    exit /b

:RUN_STEP_8
    call :LogStep
    call :GetTimestamp
    set _USBDetective=%NONVOLATILE_DIR%\USBDetective
    set _USBDetective_Hash=%_USBDetective%\Hash
    echo.
    mkdir %_USBDetective%
    echo Create USBDetective Directory
    echo [!timestamp!] Create USBDetective Directory >> %_TimeStamp%
    
    if "%net%"=="4" (
        goto RUN_STEP_8_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_8_NET6
    ) else (
        goto RUN_STEP_8_Fore
    )
:RUN_STEP_8_Fore
    call :GetTimestamp
    echo.
    echo Acquring USB Logs Information...
    echo [!timestamp!] Acquring Driver Information... >> %_TimeStamp%
    forecopy_handy -t %_USBDetective%
    goto RUN_STEP_8_Hash

:RUN_STEP_8_NET4
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target USBDevicesLogs --tdest %_USBDetective%
    goto RUN_STEP_8_Hash

:RUN_STEP_8_NET6
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target USBDevicesLogs --tdest %_USBDetective%
    goto RUN_STEP_8_Hash

:RUN_STEP_8_Hash
    call :GetTimestamp
    mkdir %_USBDetective_Hash%
    echo.
    echo Create USBDetect Hash Directory
    echo [!timestamp!] Create Driver Hash Direcotry >> %_TimeStamp%
    %hashdeep% -e -r %_USBDetective% > %_USBDetective_Hash%\USB_Hash.txt
    echo.
    echo Calculate USBDetective Hash...
    echo [!timestamp!] Calculate USBDetective Hash... >> %_TimeStamp%
    goto RUN_STEP_8_Clear

:RUN_STEP_8_Clear
    echo RUN_STEP_8 CLEAR
    exit /b

:RUN_STEP_9
    call :LogStep
    call :GetTimestamp
    set _Recent=%NONVOLATILE_DIR%\Recent
    mkdir %_Recent%
    echo.
    echo [RUN_STEP_9] Create Recent Directory
    echo [!timestamp!] Create Recent Directory >> %_TimeStamp%
    set _Recent_Module=%_Recent%\Module
    mkdir %_Recent_Module%
    echo [!timestamp!] Create Recent Module Directory >> %_TimeStamp%
    if  "%net%"=="4" (
        goto RUN_STEP_9_NET4
    ) else if "%net%"=="6" (
        goto RUN_STEP_9_NET6
    ) else (
        goto RUN_STEP_9_FORE
    )

:RUN_STEP_9_NET4
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target LNKFilesAndJumpLists --tdest %_Recent%
    %kape%\kape.exe --msource %_Recent%\%_FirstCharacter% --module LECmd --mdest %_Recent_Module%
    %kape%\kape.exe --msource %_Recent%\%_FirstCharacter% --module JLECmd --mdest %_Recent_Module%
    echo [!timestamp!] LECmd_net4  >> %_TimeStamp%
    goto RUN_STEP_9_Hash

:RUN_STEP_9_NET6
    call :GetTimestamp
    %kape%\kape.exe --tsource %SystemDrive% --target LNKFilesAndJumpLists --tdest %_Recent%
    %kape%\kape.exe --msource %_Recent%\%_FirstCharacter% --module LECmd --mdest %_Recent_Module%
    %kape%\kape.exe --msource %_Recent%\%_FirstCharacter% --module JLECmd --mdest %_Recent_Module%
    echo [!timestamp!] LECmd_net6  >> %_TimeStamp%
    goto RUN_STEP_9_Hash

:RUN_STEP_9_FORE
    call :GetTimestamp
    echo.
    echo Acquring Recent Data ...
    echo [!timestamp!] Acquring Recent Data... >> %_Timestamp%
    forecopy_handy -r "%userprofile%\Desktop" %_Recent%
    forecopy_handy -r "%userprofile%\AppData\Roaming\Microsoft\Windows\Recent" %_Recent%
    forecopy_handy -r "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" %_Recent%
    forecopy_handy -r "%userprofile%\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch"
    goto RUN_STEP_9_Hash

:RUN_STEP_9_Hash
    call :GetTimestamp
    set _Recent_Hash=%_Recent%\Hash
    mkdir %_Recent_Hash%
    echo.
    echo Create Recent Hash Directory
    echo [!timestamp!] Create Recent Hash Directory >> %_TimeStamp%
    %hashdeep% -e -r %_Recent% > %_Recent_Hash%\Recent_Hash.txt
    echo Calculate Recent Hash...
    echo [!timestamp!] Calculate Recent Hash... >> %_TimeStamp%
    echo.
    goto RUN_STEP_9_Clear

:RUN_STEP_9_Clear
    echo RUN_STEP_9 CLEAR
    exit /b

:LogStep
echo ========================== >> %_TimeStamp%
goto :eof

:: Timestamp
:GetTimestamp
set year=!date:~0,4!
set month=!date:~5,2!
set day=!date:~8,2!
set hour=!time:~0,2!
if "!hour:~0,1!" == " " set hour=0!hour:~1,1!
set minute=!time:~3,2!
set second=!time:~6,2!
set timestamp=!year!-!month!-!day!_!hour!-!minute!-!second!
goto :eof

echo [!timestamp!] End Time >> %_TimeStamp%
endlocal

