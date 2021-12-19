Function Get-LaunchboxEboot {
Param(
$path = "E:\Launchbox\Launchbox\Games\Sony Playstation 3",
$output = 
)
    Get-ChildItem $path -Recurse -Filter "Eboot.bin" | ForEach-Object {
        [PSCUSTOMOBJECT]@{
            Name = (($_.DirectoryName).Replace("$path","") -split '\\')[1]
            Fullname = $_.FullName
        }
    }
}
