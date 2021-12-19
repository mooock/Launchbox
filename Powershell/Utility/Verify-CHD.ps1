Function Verify-CHD {
[CmdletBinding()]
param (
    $Source='E:\Launchbox\Launchbox\Games\Sony Playstation 2',
    $ChdmanEXE='f:\CHD\chdman.exe'
)
    $Extensions = '*.chd'
    If (Test-Path $ChdmanEXE) {

    } else {
        Write-error "CHDMAN not found"
        break
    }

     $Files = Get-ChildItem $Source -Recurse -Include $Extensions

    Foreach ($file in $files) {
        $chdoutput = &$ChdmanEXE info -i $file.fullname | select -Skip 1

        $DataSHA1    = ($chdoutput -split ':')[24].Trim()
        $Ratio       = ($chdoutput -split ':')[20].Trim()
        $CHDSIZE     = ($chdoutput -split ':')[18].Trim()
        $Logicalsize = ($chdoutput -split ':')[6].Trim()
        $WrongSHA1   = '0000000000000000000000000000000000000000'

        If ($DataSHA1 -eq $WrongSHA1) {
            $datacrc = 'Mismatch'
        } else {$datacrc = 'OK'}

        [PSCUSTOMOBJECT]@{
            Source        = $file.FullName
            Logicalsize   = $Logicalsize
            CHDSize       = $CHDSIZE 
            Ratio         = $Ratio
            CRC           = $datacrc
        }   
    }
}
