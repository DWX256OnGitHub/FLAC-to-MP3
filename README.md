# FLAC-to-MP3

Scripts that convert FLAC audio files to MP3s.
<br>将FLAC音频文件转换为MP3的脚本。

## Features /功能

- Converts FLAC files to high-quality MP3 (320kbps) / 将FLAC文件转换为高质量MP3 (320kbps)
- Preserves all metadata and tags / 保留所有元数据和标签
- Simple drag-and-drop interface / 简单的拖放界面
- Works with multiple files at once / 支持批量处理多个文件
- Automatically uses local ffmpeg.exe if available / 如果可用，自动使用本地的ffmpeg.exe

## Requirements /系统要求

- Windows OS / Windows操作系统
- ffmpeg.exe (included in this repository or available in PATH) / ffmpeg.exe（本仓库提供或PATH中可用）

## Installation /安装方法

1. Download or clone this repository / 下载或克隆此仓库
2. Ensure ffmpeg.exe is either:
   - In the same directory as the batch script / 与批处理脚本同一目录
   - Available in your system PATH / 在系统PATH中可用

<br>

1. 下载或克隆此仓库
2. 确保ffmpeg.exe位于以下任一位置：
   - 与批处理脚本同一目录
   - 在您的系统PATH中

## Usage /使用方法

### Files Required /准备文件

1. .bat file in this repo. /本仓库下的 .bat 文件
2. ffmpeg.exe in this repo or from official ffmpeg repo. /本仓库下的 ffmpeg.exe 或者官方仓库的ffmpeg.exe

### Run /运行

Drag the FLAC files you want to convert onto the .bat file, and the MP3s will be output to the source directory.
<br>将需要转换的flac文件拖到.bat上，mp3会输出到源目录。

## Technical Details /技术细节

The script uses the following ffmpeg command:
<br>脚本使用以下ffmpeg命令：

`ffmpeg.exe -y -i "input.flac" -map_metadata 0 -id3v2_version 3 -codec:a libmp3lame -b:a 320k "output.mp3"`

Parameters explained:
<br>参数说明：

- `-y` - Overwrite output files without asking / 无提示覆盖输出文件
- `-i` - Input file / 输入文件
- `-map_metadata 0` - Copy all metadata from input to output / 复制所有元数据
- `-id3v2_version 3` - Use ID3v2 tags for better compatibility / 使用ID3v2标签以获得更好兼容性
- `-codec:a libmp3lame` - Use LAME MP3 encoder / 使用LAME MP3编码器
- `-b:a 320k` - Set audio bitrate to 320 kbps / 设置音频比特率为320kbps

## Troubleshooting /故障排除

If conversion fails:
<br>如果转换失败：

1. Ensure ffmpeg.exe is properly placed / 确保ffmpeg.exe放置正确
2. Check that the FLAC files are not corrupted / 检查FLAC文件是否损坏
3. Verify you have write permissions in the source directory / 确认您在源目录中有写入权限

## License /许可证

This project is licensed under the GNU General Public License v3.0 (GPLv3).
<br>该项目基于GNU通用公共许可证v3.0 (GPLv3)授权。

You are free to use, modify, and distribute this software under the terms of the GPLv3 license.
<br>您可以根据GPLv3许可证的条款自由使用、修改和分发此软件。

See [LICENSE](LICENSE) file for full license text.
<br>有关完整许可文本，请参阅[LICENSE](LICENSE)文件。

## Contributing /贡献

Contributions are welcome! Please feel free to submit issues or pull requests.
<br>欢迎贡献！请随时提交问题或拉取请求。