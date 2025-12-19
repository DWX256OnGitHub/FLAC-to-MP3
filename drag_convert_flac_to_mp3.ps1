# ------------------------------------------------------------------
# drag_convert_flac_to_mp3.ps1
# Drag and drop FLAC to MP3 converter script (preserves metadata & tags)
# Uses local ffmpeg.exe from script directory or ffmpeg.exe from PATH
# ------------------------------------------------------------------

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Files = @()
)

# 设置最大并发线程数
$MaxThreads = 4

# 检测系统语言
try {
    $OSLanguage = (Get-WinSystemLocale).Name
} catch {
    $OSLanguage = "en-US"
}

# 根据检测到的语言设置消息
if ($OSLanguage -like "zh*" -or $OSLanguage -like "*CN*" -or $OSLanguage -like "*TW*") {
    $Messages = @{
        NoFiles = "请拖拽 FLAC 文件到此脚本上, 或者选择一个或多个文件."
        Converting = "正在转换:"
        Success = "转换成功:"
        Failed = "转换失败:"
        NotFlac = "不是 FLAC 文件:"
        Complete = "全部处理完成!"
        Waiting = "等待所有转换完成..."
        Progress = "已完成: "
    }
} else {
    $Messages = @{
        NoFiles = "Please drag and drop FLAC files onto this script, or select one or more files."
        Converting = "Converting:"
        Success = "Success:"
        Failed = "Failed:"
        NotFlac = "Not a FLAC file:"
        Complete = "All processing completed!"
        Waiting = "Waiting for all conversions to complete..."
        Progress = "Completed: "
    }
}

# 查找 ffmpeg.exe - 优先使用脚本目录下的版本
$LocalFF = Join-Path $PSScriptRoot "ffmpeg.exe"
if (Test-Path $LocalFF) {
    $FF = $LocalFF
} else {
    $FF = "ffmpeg.exe"
}

# 检查是否传递了参数（没有有效文件被拖放）
if ($Files.Count -eq 0) {
    Write-Host $Messages.NoFiles
    Read-Host "Press Enter to continue"
    exit
}

# 过滤出FLAC文件并计算总数
$FlacFiles = $Files | Where-Object { [System.IO.Path]::GetExtension($_) -eq ".flac" }
$TotalFiles = $FlacFiles.Count

Write-Host "$($Messages.Converting) $TotalFiles files..."
Write-Host ""

# 创建临时目录存储日志
$TempDir = Join-Path $env:TEMP "flac_conversion_$([System.Guid]::NewGuid().ToString())"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# 初始化计数器
$CurrentThreads = 0
$CompletedCount = 0
$Jobs = @()

# 处理每个FLAC文件
foreach ($File in $FlacFiles) {
    # 检查文件扩展名（不区分大小写）
    if ([System.IO.Path]::GetExtension($File) -eq ".flac") {
        # 等待直到有可用线程
        while ($CurrentThreads -ge $MaxThreads) {
            # 检查已完成的任务
            $FinishedJobs = $Jobs | Where-Object { $_.State -eq "Completed" }
            foreach ($Job in $FinishedJobs) {
                try {
                    $Result = Receive-Job $Job
                    Write-Host $Result
                } catch {
                    Write-Host "$($Messages.Failed) Job Error"
                }
                Remove-Job $Job
                $CurrentThreads--
                $CompletedCount++
                Write-Host "[$CompletedCount/$TotalFiles]"
            }
            
            # 移除已完成的任务
            $Jobs = $Jobs | Where-Object { $_.State -ne "Completed" }
            
            Start-Sleep -Milliseconds 100
        }
        
        # 增加当前线程计数
        $CurrentThreads++
        
        # 创建输出文件路径
        $OutputFile = [System.IO.Path]::ChangeExtension($File, ".mp3")
        
        # 在后台启动转换进程
        $Job = Start-Job -ScriptBlock {
            param($FFmpegPath, $InputFile, $OutputFile, $SuccessMsg, $FailedMsg)
            
            try {
                # 执行转换
                $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
                $ProcessInfo.FileName = $FFmpegPath
                $ProcessInfo.Arguments = "-y -i `"$InputFile`" -map_metadata 0 -id3v2_version 3 -codec:a libmp3lame -b:a 320k `"$OutputFile`""
                $ProcessInfo.UseShellExecute = $false
                $ProcessInfo.RedirectStandardOutput = $true
                $ProcessInfo.RedirectStandardError = $true
                $ProcessInfo.CreateNoWindow = $true
                
                $Process = New-Object System.Diagnostics.Process
                $Process.StartInfo = $ProcessInfo
                $Process.Start() | Out-Null
                $Process.WaitForExit()
                
                if ($Process.ExitCode -eq 0 -and (Test-Path $OutputFile)) {
                    return "$SuccessMsg `"$OutputFile`""
                } else {
                    return "$FailedMsg `"$InputFile`""
                }
            } catch {
                return "$FailedMsg `"$InputFile`""
            }
        } -ArgumentList $FF, $File, $OutputFile, $Messages.Success, $Messages.Failed
        
        $Jobs += $Job
    } else {
        Write-Host "$($Messages.NotFlac) `"$File`""
    }
}

Write-Host $Messages.Waiting

# 等待所有转换完成并显示结果
while ($CurrentThreads -gt 0) {
    # 检查已完成的任务
    $FinishedJobs = $Jobs | Where-Object { $_.State -eq "Completed" }
    foreach ($Job in $FinishedJobs) {
        try {
            $Result = Receive-Job $Job
            Write-Host $Result
        } catch {
            Write-Host "$($Messages.Failed) Job Error"
        }
        Remove-Job $Job
        $CurrentThreads--
        $CompletedCount++
        Write-Host "[$CompletedCount/$TotalFiles]"
    }
    
    # 移除已完成的任务
    $Jobs = $Jobs | Where-Object { $_.State -ne "Completed" }
    
    Start-Sleep -Milliseconds 100
}

Write-Host ""
Write-Host $Messages.Complete

# 清理临时目录
try {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    # 忽略清理错误
}

Read-Host "Press Enter to continue"