@echo off
rem ------------------------------------------------------------------
rem drag_convert_flac_to_mp3.bat
rem Drag and drop FLAC to MP3 converter script (preserves metadata & tags)
rem Uses local ffmpeg.exe from script directory or ffmpeg.exe from PATH
rem ------------------------------------------------------------------

rem Detect system language
for /f "tokens=3" %%a in ('reg query "HKCU\Control Panel\International\Geo" /v NameSpace 2^>nul') do set "LANG_CODE=%%a"

rem Set messages based on detected language
if "%LANG_CODE%"=="ZH" (
    set "MSG_NO_FILES=请拖拽 FLAC 文件到此脚本上, 或者选择一个或多个文件."
    set "MSG_CONVERTING=正在转换:"
    set "MSG_SUCCESS=转换成功:"
    set "MSG_FAILED=转换失败:"
    set "MSG_NOT_FLAC=不是 FLAC 文件:"
    set "MSG_COMPLETE=全部处理完成!"
) else (
    set "MSG_NO_FILES=Please drag and drop FLAC files onto this script, or select one or more files."
    set "MSG_CONVERTING=Converting:"
    set "MSG_SUCCESS=Success:"
    set "MSG_FAILED=Failed:"
    set "MSG_NOT_FLAC=Not a FLAC file:"
    set "MSG_COMPLETE=All processing completed!"
)

rem Find ffmpeg.exe - prefer local version over PATH version
set "LOCAL_FF=%~dp0ffmpeg.exe"
if exist "%LOCAL_FF%" (
    set "FF=%LOCAL_FF%"
) else (
    set "FF=ffmpeg.exe"
)

rem Check if no parameters were passed (no valid files dropped)
if "%~1"=="" (
    echo %MSG_NO_FILES%
    pause
    exit /b
)

rem Loop through each parameter - any invalid files will be automatically skipped by the extension check
for %%F in (%*) do (
    rem Check file extension case-insensitively
    if /I "%%~xF"==".flac" (
        echo -------------------------------
        echo %MSG_CONVERTING% "%%~fF"
        rem Create mp3 with same name in same directory as the original flac
        "%FF%" -y -i "%%~fF" -map_metadata 0 -id3v2_version 3 -codec:a libmp3lame -b:a 320k "%%~dpnF.mp3"
        if errorlevel 1 (
            echo %MSG_FAILED% "%%~fF"
        ) else (
            echo %MSG_SUCCESS% "%%~dpnF.mp3"
        )
    ) else (
        echo %MSG_NOT_FLAC% "%%~fF"
    )
)

echo.
echo %MSG_COMPLETE%
pause