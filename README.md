# FLAC-to-MP3

Scripts that convert FLAC audio files to MP3s.

将FLAC音频文件转换为MP3的脚本工具。

## License / 许可证

This project is licensed under the GNU General Public License v3.0 (GPLv3).

本项目采用GNU通用公共许可证v3.0 (GPLv3)授权。

## Features / 功能特点

- Converts FLAC files to high-quality MP3 (320kbps) / 将FLAC文件转换为高质量MP3(320kbps)
- Preserves metadata and tags / 保留元数据和标签
- Multi-threaded conversion for faster processing / 多线程转换以提高处理速度
- Supports both batch (.bat) and PowerShell (.ps1) versions / 支持批处理(.bat)和PowerShell(.ps1)两个版本
- Bilingual interface (English/Chinese) / 双语界面（英语/中文）
- Automatically uses local ffmpeg.exe if available / 自动使用本地ffmpeg.exe（如果可用）

## Requirements / 系统要求

- Windows operating system / Windows操作系统
- ffmpeg executable / ffmpeg可执行文件

## How To Use? / 使用方法

### Files Required / 准备文件

1. Either `.bat` or `.ps1` script file from this repository / 本仓库中的 `.bat` 或 `.ps1` 脚本文件
2. `ffmpeg.exe` (can be placed in the same directory as the script or available in system PATH) / ffmpeg.exe（可以放在与脚本相同的目录中或在系统PATH中可用）

### Run / 运行

#### Batch Script Version / 批处理脚本版本

Drag the FLAC files you want to convert onto the `drag_convert_flac_to_mp3.bat` file, and the MP3s will be output to the source directory.
<br>将需要转换的FLAC文件拖到`drag_convert_flac_to_mp3.bat`上，MP3会输出到源目录。

#### PowerShell Script Version / PowerShell脚本版本

Drag the FLAC files you want to convert onto the `drag_convert_flac_to_mp3.ps1` file, and the MP3s will be output to the source directory.
<br>将需要转换的FLAC文件拖到`drag_convert_flac_to_mp3.ps1`上，MP3会输出到源目录。

Alternatively, right-click the script and choose "Run with PowerShell".
<br>或者右键点击脚本并选择"使用PowerShell运行"。

### Notes / 注意事项

- The scripts support converting multiple files simultaneously (up to 4 concurrent conversions) / 脚本支持同时转换多个文件（最多4个并发转换）
- Both English and Chinese interfaces are automatically selected based on your system language / 英语和中文界面会根据您的系统语言自动选择
- Converted MP3 files will be created in the same directory as the original FLAC files / 转换后的MP3文件将在与原始FLAC文件相同的目录中创建
- Conversion quality is set to 320kbps CBR for maximum compatibility / 转换质量设置为320kbps CBR以实现最大兼容性

## Technical Details / 技术细节

The scripts utilize FFmpeg to perform the actual conversion process. They implement multi-threading to allow simultaneous conversion of multiple files, significantly reducing total processing time when converting many files.

脚本利用FFmpeg执行实际的转换过程。它们实现了多线程处理，允许同时转换多个文件，从而在转换许多文件时显著减少总处理时间。