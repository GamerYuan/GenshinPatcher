@REM No command output.
@echo off
REM Delayed expansion of variables. Necessary in for loops.
SetLocal EnableDelayedExpansion
REM Set working directory to current directory. Otherwise it will not work in ProgramFiles folder with admin permissions.
set WorkingDirForAdmin=%~dp0
REM Check if all files listed in TH_GP_AudioPatch_2.5.0-2.6.0.txt are present.
echo Checking if all necessary files for Patch 2.5 are present...
REM Entry point to retry patch application.
:SelectionY
REM Create variable for patch finished.
set PatchFinished=False
REM Create variable for check operation.
set FileMissing=False
REM Check if all files are present, variable will be set to false if at least one file is missing. All missing files will be listed.
for /F "usebackq delims=" %%i in ("!WorkingDirForAdmin!TH_GP_AudioPatch_2.5.0-2.6.0.txt") do (
    if NOT exist "!WorkingDirForAdmin!%%i" (
        echo "!WorkingDirForAdmin!%%i" is missing.
        set FileMissing=True
    )
    if NOT exist "!WorkingDirForAdmin!%%i.hdiff" (
        echo "!WorkingDirForAdmin!%%i.hdiff" is missing.
        set FileMissing=True
    )
)
if NOT exist "!WorkingDirForAdmin!hpatchz.exe" (
    echo "!WorkingDirForAdmin!hpatchz.exe" is missing.
    set FileMissing=True
)
REM Result of check if all files are present.
if "%FileMissing%"=="True" (
    goto RetryQuery
) else (
    goto ApplyPatch
)
REM If one file is missing ask the user to retry after getting the necessary files.
:RetryQuery
echo.
echo At least one file is missing. Please extract/download the necessary files listed above and try again.
REM Query if user wants to try again now.
:Query
set /P selection=Retry patch application now? (y / n): 
for %%a in (Y N) do if /i '%selection%'=='%%a' goto :Selection%%a
echo Wrong input. Valid inputs: 'y' for retry and 'n' for abort.
goto Query
REM Entry point if user decided to abort the patch application.
:SelectionN
echo Aborted patch application. Exiting after next button press.
echo.
goto End
:ApplyPatch
echo All necessary files are present. Applying patch now...
echo.
REM (command to apply patch) (original file) (patch file)     (output file, larger size afterwards)
REM  hpatchz -f               name1.pck       name1.pck.hdiff  name1.pck
for /F "usebackq delims=" %%i in ("!WorkingDirForAdmin!TH_GP_AudioPatch_2.5.0-2.6.0.txt") do (
    "!WorkingDirForAdmin!hpatchz.exe" -f "!WorkingDirForAdmin!%%i" "!WorkingDirForAdmin!%%i.hdiff" "!WorkingDirForAdmin!%%i"
)
set PatchFinished=True
REM Delete obsolete files after patch application.
for /F "usebackq delims=" %%i in ("!WorkingDirForAdmin!TH_GP_Cleanup_2.5.0-2.6.0.txt") do (
	if "%%i"=="mhypbase.dll" (
		attrib -R "!WorkingDirForAdmin!%%i"
		del "!WorkingDirForAdmin!%%i"
	) else (
		del "!WorkingDirForAdmin!%%i"
	)
)
REM Delete source file for TH_GP_Cleanup_2.5.0-2.6.0.txt and the file itself.
del "!WorkingDirForAdmin!deletefiles.txt"
del "!WorkingDirForAdmin!TH_GP_Cleanup_2.5.0-2.6.0.txt"
REM Delete obsolete .hdiff files after patch application.
for /F "usebackq delims=" %%i in ("!WorkingDirForAdmin!TH_GP_AudioPatch_2.5.0-2.6.0.txt") do (
    del "!WorkingDirForAdmin!%%i.hdiff"
)
REM Delete source file for TH_GP_AudioPatch_2.5.0-2.6.0.txt and the file itself.
del "!WorkingDirForAdmin!hdifffiles.txt"
del "!WorkingDirForAdmin!TH_GP_AudioPatch_2.5.0-2.6.0.txt"
REM Delete patch application.
del "!WorkingDirForAdmin!hpatchz.exe"
REM Delete diff application if someone extracted it too.
if exist "!WorkingDirForAdmin!hdiffz.exe" (
    del "!WorkingDirForAdmin!hdiffz.exe"
)
echo Deleted all obsolete files after patch. Patch application is finished now. Enjoy the game.
echo.
goto End
:End
pause
if "%PatchFinished%"=="True" (
    del "!WorkingDirForAdmin!TH_GP_2.5.0-2.6.0.bat"
)