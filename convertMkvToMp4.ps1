param (
    [Parameter(Mandatory = $true)][string]$path,
    [switch]$useSrtSubs,
    [switch]$burnInEng,
    [switch]$testRun
)

$filelist = Get-ChildItem $path -filter *.mkv -recurse

$num = $filelist | Measure-Object
$filecount = $num.count
 
$i = 0;
ForEach ($file in $filelist) {
    $i++;
    $oldfile = $file.DirectoryName + "\" + $file.BaseName + $file.Extension;
    $newfile = $file.DirectoryName + "\" + $file.BaseName + ".mp4";
    
    $srtFile = "";

    if ($useSrtSubs.IsPresent) {
        Write-Host "Use srt is present"

        $enSrt = $file.DirectoryName + "\" + $file.BaseName + ".en.srt";
        $engSrt = $file.DirectoryName + "\" + $file.BaseName + ".eng.srt";
        $srt = $file.DirectoryName + "\" + $file.BaseName + ".srt";

        if ([System.IO.File]::Exists($enSrt)) {
            Write-Host "Found .en.srt file: $enSrt"
            $srtFile = $enSrt;
        }
        elseif ([System.IO.File]::Exists($engSrt)) {
            Write-Host "Found .eng.srt file: $engSrt"
            $srtFile = $engSrt;
        }
        elseif ([System.IO.File]::Exists($srt)) {
            Write-Host "Found .srt file: $srt"
            $srtFile = $srt;
        }
    }

    $progress = ($i / $filecount) * 100
    $progress = [Math]::Round($progress, 2)
 
    Write-Host -------------------------------------------------------------------------------
    Write-Host Handbrake Batch Encoding
    Write-Host "Processing - $oldfile"
    Write-Host "New file - $newfile"
    Write-Host "File $i of $filecount - $progress%"
    Write-Host -------------------------------------------------------------------------------
     
    $srtArg = "";
    if ($srtFile) {
        $srtArg = "--srt-file=`"$srtFile`" --srt-codeset UTF-8 --srt-burn"
        Write-Host "srt args: $srtArg"
    }
    elseif ($burnInEng.IsPresent) {
        Write-Host "burnInEng is present"
        
        $srtArg = "--subtitle=`"1`" --subtitle-forced --subtitle-burned"
        Write-Host "srt args: $srtArg"
    }

    $proc = Start-Process "C:\Program Files\HandBrake\HandBrakeCLI.exe" -ArgumentList "-O -Z `"Fast 1080p30`" -i `"$oldfile`" -o `"$newfile`" -v=1 $srtArg --all-audio" -Wait -NoNewWindow -PassThru
    
    if ($proc.ExitCode -ne 0) {
        throw "$_ exited with status code $($proc.ExitCode)"
    }
    elseif ($testRun.IsPresent) {
        Write-Host "Test run completed"
        break;
    }
    else {
        Remove-Item "$oldfile"

        if ($srtFile) {
            Remove-Item "$srtFile"
        }
    }
}