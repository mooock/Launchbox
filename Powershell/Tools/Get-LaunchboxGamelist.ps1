Function Get-LaunchboxGamelist {
param (
$Path = 'E:\Launchbox\Launchbox\Data\Platforms\arcade.xml'

)
[XML]$Launchbox = [System.Xml.XmlDocument](Get-Content -Path $Path)
$Launchbox.LaunchBox.AlternateName | ForEach-Object { $LaunchboxID[$_.GameID] = $_.Name }
    $Launchbox.LaunchBox.Game | ForEach-Object {
        [PSCUSTOMOBJECT]@{
            Name = $_.Title
            Filename = $_.ApplicationPath | Split-Path -Leaf
            ApplicationPath = $_.ApplicationPath
            ID = $_.ID
            DatabaseID = $_.DatabaseID
        }
    }
}
