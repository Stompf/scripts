param (
    [Parameter(Mandatory = $true)][string]$path,
    [switch]$useDirectoryName,
    [switch]$testRun
)

Get-ChildItem $path -File -recurse | Where-Object { $_.Name.Contains(' - ') } | Rename-Item -NewName { $_.Name -replace ' - ', '.' }
Get-ChildItem $path -File -recurse | Where-Object { $_.Name.Contains(' ') } | Rename-Item -NewName { $_.Name -replace ' ', '.' }

$filelist = Get-ChildItem $path -filter *.avi -recurse

$num = $filelist | Measure-Object
$filecount = $num.count
 
if ($testRun.IsPresent) {
    Write-Host "Test flag active, will only convert first file and not delete source"
}

$i = 0;
ForEach ($file in $filelist) {
    $i++;
    $oldfile = $file.DirectoryName + "\" + $file.BaseName + $file.Extension;

    if ($useDirectoryName.IsPresent) {
        $newfile = $file.DirectoryName + "\" + $file.Directory.Name + ".mp4";
    }
    else {
        $newfile = $file.DirectoryName + "\" + $file.BaseName + ".mp4";
    }
      
    $progress = ($i / $filecount) * 100
    $progress = [Math]::Round($progress, 2)
 
    Write-Host -------------------------------------------------------------------------------
    Write-Host Handbrake Batch Encoding
    Write-Host "Processing - $oldfile"
    Write-Host "New file - $newfile"
    Write-Host "File $i of $filecount - $progress%"
    Write-Host -------------------------------------------------------------------------------
     
    $proc = Start-Process "C:\Program Files\HandBrake\HandBrakeCLI.exe" -ArgumentList "-O -Z `"Fast 1080p30`" -i `"$oldfile`" -o `"$newfile`" -v=1" -Wait -NoNewWindow -PassThru
    
    if ($proc.ExitCode -ne 0) {
        throw "$_ exited with status code $($proc.ExitCode)"
    }
    elseif ($testRun.IsPresent) {
        Write-Host "Test run completed"
        break;
    }
    else {
        Remove-Item "$oldfile"
    }
}