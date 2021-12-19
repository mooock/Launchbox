Function Compress-7zip {
[CmdletBinding()]
param (
    $Source='C:\Launchbox\Source',
    $Destination='C:\Launchbox\Destination',
    $7zip ="C:\Program Files\7-Zip\7z.exe",
    $Extensions = '*.smc'
)
    $files = Get-ChildItem $Source -Recurse -Include $Extensions 
    $Filestotal = $files.Count
    $i=0
    foreach ($file in $files) {
        $i++
        $destinationfile = ($Destination + '\'+ $file.BaseName + '.7z')
        [PSCUSTOMOBJECT]@{
            Source = $file.fullname
            Destination = $destinationfile
        }
        &$7zip a -mx8 $destinationfile $file.FullName | Out-Null
        Write-Progress -Activity 'Compressing files' -Status "File Compression $($file.name)" -PercentComplete ($i / $Filestotal * 100)
     }
}
