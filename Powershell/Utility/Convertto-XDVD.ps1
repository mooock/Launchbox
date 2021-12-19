Function Convertto-XDVD {
param (
    $Path7Zip        = "P:\Compression\7zip\7z.exe",
    $Pathextractxiso = "P:\Burning\CreateISO\exiso.exe",
    $ConvertFromPath = "L:\XBOXO",
    $ConvertToPath   = "X:\ISO",
    $ExtractPath     = "E:\Convert\Extract"
)
    $files = (get-childitem $ConvertFromPath -Filter "*.7z").FullName
    $TotalFileCount = $files.Count
    $ConvertToPathFiles = (get-childitem $ConvertToPath).Name
    $i = 0
    Foreach ($file in $files) {
        $i++
        $7ZipRootFolderName = ((&$Path7Zip l $file | select -Last 5)[0] -split '  ' | select -Last 1) + ".iso"
        $FileExist = $ConvertToPathFiles -contains $7ZipRootFolderName
        If (-not $FileExist) {
            Write-Progress -Activity "Extracting $file" -Status "$i of $TotalFileCount Processed" -PercentComplete ($i / $TotalFileCount * 100)
            &$Path7Zip x $file -o"$ExtractPath"

            $ExtractFolders = (Get-ChildItem -Path $ExtractPath)
            $ExtractFoldersCount = (get-childitem $ExtractFolders.FullName -Recurse).count

            Write-Progress -Activity "Converting $ExtractFoldersCount files to XDVD" -Status "$i of $TotalFileCount Processed" -PercentComplete ($i / $TotalFileCount * 100)
            Foreach ($ExtractFolder in $ExtractFolders) {
                $Isoname = $ExtractFolder.Name + ".iso"
                &$Pathextractxiso -c $ExtractFolder.FullName (Join-Path -Path $ConvertToPath -ChildPath $Isoname)
                $ExtractFolders | Remove-Item -Recurse -Force
            }
        }
    }
}
