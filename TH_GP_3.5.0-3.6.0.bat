@REM No command output.
@echo off
REM Delayed expansion of variables. Necessary in for loops.
SetLocal EnableDelayedExpansion
REM Set working directory to current directory. Otherwise it will not work in ProgramFiles folder with admin permissions.
set WorkingDirForAdmin=%~dp0
REM Check if all necessary files are present.
echo Checking if all necessary files to update the game from Patch 3.5.0 to 3.6.0 are present...
REM Entry point to retry patch application.
:SelectionY
REM Create variable for patch finished.
set PatchFinished=False
REM Create variable for common check operation.
set FileMissing=False
REM Create variables for languages.
set ChineseInstalled=False
set EnglishInstalled=False
set JapaneseInstalled=False
set KoreanInstalled=False
REM Create variable for language check operation.
set CurrentLanguage=None
REM Create temporary variable for audio validation.
set LangCheck=None
REM Check which languages are installed.
for /F "usebackq delims=" %%i in ("!WorkingDirForAdmin!GenshinImpact_Data\Persistent\audio_lang_14") do (
	if "%%i"=="Chinese" (
		set ChineseInstalled=True
		set CurrentLanguage=Chinese
	)
	if "%%i"=="English(US)" (
		set EnglishInstalled=True
		set CurrentLanguage=English
	)
	if "%%i"=="Japanese" (
		set JapaneseInstalled=True
		set CurrentLanguage=Japanese
	)
	if "%%i"=="Korean" (
		set KoreanInstalled=True
		set CurrentLanguage=Korean
	)
	REM Check if required TH_GP_AudioPatch_[language]_3.5.0-3.6.0.txt files are present, variable will be set to true if at least one file is missing. All missing files will be listed.
	if NOT exist "!WorkingDirForAdmin!TH_GP_AudioPatch_!CurrentLanguage!_3.5.0-3.6.0.txt" (
		echo "TH_GP_AudioPatch_!CurrentLanguage!_3.5.0-3.6.0.txt" is missing.
		set FileMissing=True
		set CurrentLanguage=None
	)
)
if NOT exist "!WorkingDirForAdmin!TH_GP_AudioPatch_Common_3.5.0-3.6.0.txt" (
	echo "TH_GP_AudioPatch_Common_3.5.0-3.6.0.txt" is missing.
	set FileMissing=True
)
REM Result of check if all audio patch files are present.
if "%FileMissing%"=="True" (
	goto RetryQuery
) else (
	goto MoveLanguageFiles
)
:MoveLanguageFiles
REM Move audio files from Persistent to StreamingAssets.
REM (command to copy/move files/folders) (source folder) (target folder) (include all subdirectories, even empty ones) (copy data, attributes, timestamps for files) (copy data, attributes, timestamps for folders) (remove files/folders from source after copy)
robocopy "!WorkingDirForAdmin!GenshinImpact_Data\Persistent\AudioAssets" "!WorkingDirForAdmin!GenshinImpact_Data\StreamingAssets\Audio\GeneratedSoundBanks\Windows" /e /copy:DAT /dcopy:DAT /move
REM Recreate AudioAssets folder. Robocopy will delete it after the copy/move operation is done.
mkdir "!WorkingDirForAdmin!GenshinImpact_Data\Persistent\AudioAssets"
REM Check if required audio and patch files are present, variable will be set to true if at least one file is missing. All missing files will be listed.
for /L %%i in (1,1,4) do (
	if "%%i"=="1" (
		if "%ChineseInstalled%"=="True" (
			set CurrentLanguage=Chinese
		) else (
			set CurrentLanguage=None
		)
	)
	if "%%i"=="2" (
		if "%EnglishInstalled%"=="True" (
			set CurrentLanguage=English
		) else (
			set CurrentLanguage=None
		)
	)
	if "%%i"=="3" (
		if "%JapaneseInstalled%"=="True" (
			set CurrentLanguage=Japanese
		) else (
			set CurrentLanguage=None
		)
	)
	if "%%i"=="4" (
		if "%KoreanInstalled%"=="True" (
			set CurrentLanguage=Korean
		) else (
			set CurrentLanguage=None
		)
	)
	if NOT "!CurrentLanguage!"=="None" (
		if "!CurrentLanguage!"=="English" (
			set "LangCheck=English(US)"
		) else (
			set LangCheck=!CurrentLanguage!
		)
		for /F "usebackq delims=" %%j in ("!WorkingDirForAdmin!TH_GP_AudioPatch_!CurrentLanguage!_3.5.0-3.6.0.txt") do (
			if NOT exist "!WorkingDirForAdmin!GenshinImpact_Data\StreamingAssets\Audio\GeneratedSoundBanks\Windows\!LangCheck!\%%~nxj" (
				
				echo "!WorkingDirForAdmin!GenshinImpact_Data\StreamingAssets\Audio\GeneratedSoundBanks\Windows\!LangCheck!\%%~nxj" is missing.
				set FileMissing=True
			)
			if NOT exist "!WorkingDirForAdmin!%%j.hdiff" (
				echo "!WorkingDirForAdmin!%%j.hdiff" is missing.
				set FileMissing=True
			)
		)
	)
)
REM Check if required common audio and patch files are present, variable will be set to true if at least one file is missing. All missing files will be listed.
for /F "usebackq delims=" %%i in ("!WorkingDirForAdmin!TH_GP_AudioPatch_Common_3.5.0-3.6.0.txt") do (
	if NOT exist "!WorkingDirForAdmin!GenshinImpact_Data\StreamingAssets\Audio\GeneratedSoundBanks\Windows\%%~nxi" (
		echo "!WorkingDirForAdmin!GenshinImpact_Data\StreamingAssets\Audio\GeneratedSoundBanks\Windows\%%~nxi" is missing.
		set FileMissing=True
	)
	if NOT exist "!WorkingDirForAdmin!%%i.hdiff" (
		echo "!WorkingDirForAdmin!%%i.hdiff" is missing.
		set FileMissing=True
	)
)
REM Check if patch application is present, variable will be set to true if at least one file is missing. All missing files will be listed.
if NOT exist "!WorkingDirForAdmin!hpatchz.exe" (
	echo "!WorkingDirForAdmin!hpatchz.exe" is missing.
	set FileMissing=True
)
REM Result of check if all audio, patch and patch application files are present.
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
robocopy "!WorkingDirForAdmin!GenshinImpact_Data\StreamingAssets\Audio\GeneratedSoundBanks\Windows" "!WorkingDirForAdmin!GenshinImpact_Data\StreamingAssets\AudioAssets" /e /copy:DAT /dcopy:DAT /move
for /L %%i in (1,1,4) do (
	if "%%i"=="1" (
		if "%ChineseInstalled%"=="True" (
			set CurrentLanguage=Chinese
		) else (
			set CurrentLanguage=None
		)
	)
	if "%%i"=="2" (
		if "%EnglishInstalled%"=="True" (
			set CurrentLanguage=English
		) else (
			set CurrentLanguage=None
		)
	)
	if "%%i"=="3" (
		if "%JapaneseInstalled%"=="True" (
			set CurrentLanguage=Japanese
		) else (
			set CurrentLanguage=None
		)
	)
	if "%%i"=="4" (
		if "%KoreanInstalled%"=="True" (
			set CurrentLanguage=Korean
		) else (
			set CurrentLanguage=None
		)
	)
	if NOT "!CurrentLanguage!"=="None" (
		for /F "usebackq delims=" %%j in ("!WorkingDirForAdmin!TH_GP_AudioPatch_!CurrentLanguage!_3.5.0-3.6.0.txt") do (
			REM Remove read-only attribute from audio files. Necessary for patch application.
			attrib -R "!WorkingDirForAdmin!%%j"
			REM (command to apply patch) (original file) (patch file)	  (output file, larger size afterwards)
			REM	 hpatchz -f				  name1.pck		  name1.pck.hdiff  name1.pck
			"!WorkingDirForAdmin!hpatchz.exe" -f "!WorkingDirForAdmin!%%j" "!WorkingDirForAdmin!%%j.hdiff" "!WorkingDirForAdmin!%%j"
		)
	)
)
for /F "usebackq delims=" %%i in ("!WorkingDirForAdmin!TH_GP_AudioPatch_Common_3.5.0-3.6.0.txt") do (
	REM Remove read-only attribute from audio files. Necessary for patch application.
	attrib -R "!WorkingDirForAdmin!%%i"
	REM (command to apply patch) (original file) (patch file)	  (output file, larger size afterwards)
	REM  hpatchz -f				  name1.pck		  name1.pck.hdiff  name1.pck
	"!WorkingDirForAdmin!hpatchz.exe" -f "!WorkingDirForAdmin!%%i" "!WorkingDirForAdmin!%%i.hdiff" "!WorkingDirForAdmin!%%i"
)
set PatchFinished=True
REM Delete obsolete audio and patch files after patch application.
for /L %%i in (1,1,4) do (
	if "%%i"=="1" (
		if "%ChineseInstalled%"=="True" (
			set CurrentLanguage=Chinese
		) else (
			set CurrentLanguage=None
		)
	)
	if "%%i"=="2" (
		if "%EnglishInstalled%"=="True" (
			set CurrentLanguage=English
		) else (
			set CurrentLanguage=None
		)
	)
	if "%%i"=="3" (
		if "%JapaneseInstalled%"=="True" (
			set CurrentLanguage=Japanese
		) else (
			set CurrentLanguage=None
		)
	)
	if "%%i"=="4" (
		if "%KoreanInstalled%"=="True" (
			set CurrentLanguage=Korean
		) else (
			set CurrentLanguage=None
		)
	)
	if NOT "!CurrentLanguage!"=="None" (
		REM Delete obsolete language .hdiff files after patch application.
		for /F "usebackq delims=" %%k in ("!WorkingDirForAdmin!TH_GP_AudioPatch_!CurrentLanguage!_3.5.0-3.6.0.txt") do (
			if exist "!WorkingDirForAdmin!%%k.hdiff" (
				del "!WorkingDirForAdmin!%%k.hdiff"
			)
		)
	)
)
REM Delete obsolete common audio files after patch application.
for /F "usebackq delims=" %%i in ("!WorkingDirForAdmin!TH_GP_Cleanup_3.5.0-3.6.0.txt") do (
		if exist "!WorkingDirForAdmin!%%i" (
			REM Remove read-only attribute from obsolete files. Necessary for deletion.
			attrib -R "!WorkingDirForAdmin!%%i"
			del "!WorkingDirForAdmin!%%i"
		)
	)
)
REM Delete obsolete common audio .hdiff files after patch application.
for /F "usebackq delims=" %%i in ("!WorkingDirForAdmin!TH_GP_AudioPatch_Common_3.5.0-3.6.0.txt") do (
	if exist "!WorkingDirForAdmin!%%i.hdiff" (
		del "!WorkingDirForAdmin!%%i.hdiff"
	)
)
REM Delete source file for TH_GP_Cleanup_[language]_3.5.0-3.6.0.txt and the file itself.
if exist "!WorkingDirForAdmin!deletefiles.txt" (
	del "!WorkingDirForAdmin!deletefiles.txt"
)
if exist "!WorkingDirForAdmin!TH_GP_Cleanup_3.5.0-3.6.0.txt" (
	del "!WorkingDirForAdmin!TH_GP_Cleanup_3.5.0-3.6.0.txt"
)
REM Delete source file for TH_GP_AudioPatch_[language]_3.5.0-3.6.0.txt and the file itself.
if exist "!WorkingDirForAdmin!hdifffiles.txt" (
	del "!WorkingDirForAdmin!hdifffiles.txt"
)
if exist "!WorkingDirForAdmin!TH_GP_AudioPatch_Common_3.5.0-3.6.0.txt" (
	del "!WorkingDirForAdmin!TH_GP_AudioPatch_Common_3.5.0-3.6.0.txt"
)
if exist "!WorkingDirForAdmin!TH_GP_AudioPatch_Chinese_3.5.0-3.6.0.txt" (
	del "!WorkingDirForAdmin!TH_GP_AudioPatch_Chinese_3.5.0-3.6.0.txt"
)
if exist "!WorkingDirForAdmin!TH_GP_AudioPatch_English_3.5.0-3.6.0.txt" (
	del "!WorkingDirForAdmin!TH_GP_AudioPatch_English_3.5.0-3.6.0.txt"
)
if exist "!WorkingDirForAdmin!TH_GP_AudioPatch_Japanese_3.5.0-3.6.0.txt" (
	del "!WorkingDirForAdmin!TH_GP_AudioPatch_Japanese_3.5.0-3.6.0.txt"
)
if exist "!WorkingDirForAdmin!TH_GP_AudioPatch_Korean_3.5.0-3.6.0.txt" (
	del "!WorkingDirForAdmin!TH_GP_AudioPatch_Korean_3.5.0-3.6.0.txt"
)
REM Delete patch application.
if exist "!WorkingDirForAdmin!hpatchz.exe" (
	del "!WorkingDirForAdmin!hpatchz.exe"
)
REM Delete diff application if someone extracted it too.
if exist "!WorkingDirForAdmin!hdiffz.exe" (
	del "!WorkingDirForAdmin!hdiffz.exe"
)
rmdir /S /Q "!WorkingDirForAdmin!GenshinImpact_Data\StreamingAssets\Audio\"
echo Deleted all obsolete files after patch. Patch application is finished now. Enjoy the game.
echo.
goto End
:End
pause
if "%PatchFinished%"=="True" (
	if exist "!WorkingDirForAdmin!TH_GP_3.5.0-3.6.0.bat" (
		del "!WorkingDirForAdmin!TH_GP_3.5.0-3.6.0.bat"
	)
)