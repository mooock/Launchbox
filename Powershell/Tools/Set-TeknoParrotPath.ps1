Function Set-TeknoParrotPath {
Param(
    $Path        = "E:\Launchbox\Emulators\TeknoParrot\UserProfiles\",
    $PathReplace = "E:\Launchbox\Arcade PC",
    $Pathnew     = "E:\Launchbox\Launchbox\Games",
    $SavePath    = "E:\Launchbox\Emulators\TeknoParrot\NewUserProfiles",
    [SWITCH]$Confirm,
    [SWITCH]$MD5 = $False
)
    If ($Confirm -and -not (Test-Path $SavePath)) {
        New-Item -Path $SavePath -Force -ItemType Directory | Out-Null
    }

    Get-ChildItem $Path | where Extension -like ".xml" | ForEach-Object {
        [XML]$XMLfile = Get-Content $_.FullName
        $Currentpath = $XMLfile.GameProfile.GamePath
        $Newpath     = $XMLfile.GameProfile.GamePath.Replace($PathReplace,$Pathnew)
    
        If ($Confirm) {
            $XMLfile.GameProfile.GamePath = $Newpath
            $FullSavePath = Join-Path -Path $SavePath -ChildPath  $_.Name
            $XMLfile.Save("$FullSavePath")
        }

            $Status = $false
            $Filehash = ""

        If (test-path $Newpath) {
            If ($MD5) {
                $Filehash = (Get-FileHash -Path $Newpath -Algorithm MD5).hash
            }
            $Status = $True
        }
    
        [PSCUSTOMOBJECT]@{
            Path    = $currentpath
            NewPath = $Newpath
            Testpath = $status
            Filehash = $Filehash
        }
    }
}
