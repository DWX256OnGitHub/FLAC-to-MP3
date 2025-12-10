@echo off
rem ------------------------------------------------------------------
rem drag_convert_flac_to_mp3.bat
rem 把多个 FLAC 文件拖到此脚本上进行转换（保留 metadata & 封面）
rem 优先使用脚本同目录下的 ffmpeg.exe，否则使用 PATH 中的 ffmpeg.exe
rem ------------------------------------------------------------------

rem 找到 ffmpeg.exe：优先脚本目录下的 ffmpeg.exe
set "LOCAL_FF=%~dp0ffmpeg.exe"
if exist "%LOCAL_FF%" (
    set "FF=%LOCAL_FF%"
) else (
    set "FF=ffmpeg.exe"
)

rem 检查是否传入了参数（没有拖放任何文件）
if "%~1"=="" (
    echo 请把 FLAC 文件拖到此脚本上（可一次拖多个文件）.
    pause
    exit /b
)

rem 循环处理每个参数（每个参数在拖放时会被自动用引号包起来）
for %%F in (%*) do (
    rem 检查文件扩展名（不区分大小写）
    if /I "%%~xF"==".flac" (
        echo -------------------------------
        echo Converting: "%%~fF"
        rem 输出同目录同名 mp3（覆盖已有的 mp3）
        "%FF%" -y -i "%%~fF" -map_metadata 0 -id3v2_version 3 -codec:a libmp3lame -b:a 320k "%%~dpnF.mp3"
        if errorlevel 1 (
            echo 转换失败: "%%~fF"
        ) else (
            echo 转换完成: "%%~dpnF.mp3"
        )
    ) else (
        echo 跳过（非 FLAC）: "%%~fF"
    )
)

echo.
echo 全部处理完成！
pause
