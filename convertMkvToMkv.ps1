param (
    [Parameter(Mandatory = $true)][string]$path
)

$filelist = Get-ChildItem $path -filter *.mkv -recurse

$num = $filelist | Measure-Object
$filecount = $num.count
 
$i = 0;
ForEach ($file in $filelist) {
    $i++;
    $oldfile = $file.DirectoryName + "\" + $file.BaseName + $file.Extension;
    $mkvOutputName = $path + "\title_t00.mkv";

    $newfile = $file.BaseName + ".mkv";
      
    $progress = ($i / $filecount) * 100
    $progress = [Math]::Round($progress, 2)
 
    Write-Host -------------------------------------------------------------------------------
    Write-Host Make MKV batch
    Write-Host "Processing - $oldfile"
    Write-Host "New file - $newfile"
    Write-Host "File $i of $filecount - $progress%"
    Write-Host -------------------------------------------------------------------------------
     
    $proc = Start-Process "C:\Program Files (x86)\MakeMKV\makemkvcon64.exe" -ArgumentList "mkv file:`"$oldfile`" all `"$path`"" -Wait -NoNewWindow -PassThru
    
    if ($proc.ExitCode -ne 0) {
        throw "$_ exited with status code $($proc.ExitCode)"
    }
    else {
        Remove-Item "$oldfile"
        Rename-Item "$mkvOutputName" "$newfile"
    }
}