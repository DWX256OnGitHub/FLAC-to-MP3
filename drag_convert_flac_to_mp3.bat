@echo off
setlocal EnableDelayedExpansion

rem ------------------------------------------------------------------
rem drag_convert_flac_to_mp3.bat
rem Drag and drop FLAC to MP3 converter script (preserves metadata & tags)
rem Uses local ffmpeg.exe from script directory or ffmpeg.exe from PATH
rem ------------------------------------------------------------------

rem 设置最大并发线程数
set "MAX_THREADS=4"

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
    set "MSG_WAITING=等待所有转换完成..."
    set "MSG_PROGRESS=已完成: "
) else (
    set "MSG_NO_FILES=Please drag and drop FLAC files onto this script, or select one or more files."
    set "MSG_CONVERTING=Converting:"
    set "MSG_SUCCESS=Success:"
    set "MSG_FAILED=Failed:"
    set "MSG_NOT_FLAC=Not a FLAC file:"
    set "MSG_COMPLETE=All processing completed!"
    set "MSG_WAITING=Waiting for all conversions to complete..."
    set "MSG_PROGRESS=Completed: "
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

rem 创建临时目录存储日志
set "TEMP_DIR=%TEMP%\flac_conversion_%RANDOM%"
mkdir "%TEMP_DIR%" 2>nul

rem 初始化计数器
set "CURRENT_THREADS=0"
set "COMPLETED_COUNT=0"
set "TOTAL_FILES=0"

rem 计算总FLAC文件数
for %%F in (%*) do (
    if /I "%%~xF"==".flac" (
        set /A "TOTAL_FILES+=1"
    )
)

echo %MSG_CONVERTING% %TOTAL_FILES% files...
echo.

rem 循环处理每个参数
for %%F in (%*) do (
    rem Check file extension case-insensitively
    if /I "%%~xF"==".flac" (
        rem 等待直到有可用线程
        :wait_for_thread
        if !CURRENT_THREADS! geq %MAX_THREADS% (
            rem 检查是否有完成的任务
            for %%T in ("%TEMP_DIR%\*.done") do (
                type "%%T"
                del "%%T"
                set /A "CURRENT_THREADS-=1"
                set /A "COMPLETED_COUNT+=1"
            )
            timeout /t 1 /nobreak >nul
            goto :wait_for_thread
        )
        
        rem 增加当前线程计数
        set /A "CURRENT_THREADS+=1"
        
        rem 创建唯一标识符
        set "TASK_ID=!CURRENT_THREADS!_!RANDOM!"
        
        rem 在后台启动转换进程并将输出重定向到文件
        start "" /B cmd /c ^
            "%FF% -y -i "%%~fF" -map_metadata 0 -id3v2_version 3 -codec:a libmp3lame -b:a 320k "%%~dpnF.mp3" >"%TEMP_DIR%\!TASK_ID!.log" 2>&1 && \
            (echo %MSG_SUCCESS% "%%~dpnF.mp3" >"%TEMP_DIR%\!TASK_ID!.done") || \
            (echo %MSG_FAILED% "%%~fF" >"%TEMP_DIR%\!TASK_ID!.done")"
            
    ) else (
        echo %MSG_NOT_FLAC% "%%~fF"
    )
)

echo %MSG_WAITING%

rem 等待所有转换完成并显示结果
:wait_all_complete
if %CURRENT_THREADS% gtr 0 (
    rem 检查已完成的任务
    for %%T in ("%TEMP_DIR%\*.done") do (
        type "%%T"
        del "%%T"
        set /A "CURRENT_THREADS-=1"
        set /A "COMPLETED_COUNT+=1"
        echo [%COMPLETED_COUNT%/%TOTAL_FILES%] 
    )
    timeout /t 1 /nobreak >nul
    goto :wait_all_complete
)

echo.
echo %MSG_COMPLETE%

rem 清理临时目录
rmdir /s /q "%TEMP_DIR%" 2>nul

pause