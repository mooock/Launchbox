Function Compress-CHD {
[CmdletBinding()]
param (
    $Source='D:\Convert\Source',
    $Destination='D:\Convert\destination',
    $ChdmanEXE='f:\CHD\chdman.exe',
    zip ="C:\Program Files\7-Zip\7z.exe",
    [STRING[]]$Extension = ('iso','bin','gz'),
    $Threads = 6
    
)
    Get-Process -Name chdman -ErrorAction SilentlyContinue | Stop-Process

    If (Test-Path $ChdmanEXE) {

    } else {
        Write-error "CHDMAN not found"
        break
    }
    $SecondsRemaining = 1
    $StartTime   = $(get-date)
    $Processname = 'chdman'
    $ThreadCount = 0
    $Extensions  = $Extension | ForEach-Object {"*.$_"}   
    $files = Get-ChildItem $Source -Recurse -Include $Extensions
    $Total = $files.count    

    ForEach ($file in $files) {
        $ThreadCount++  
        $destinationfile = Join-Path $Destination -ChildPath ($file.BaseName + '.chd')
        $Compressedfile  = $false
        $Sourcefile      = $file.FullName
        $fileExtension   = $file.Extension

        if ($file.Extension -like ".gz") {
            Write-Verbose "Extracting Source file $Sourcefile"
            Write-Progress -Status "Extracting Source file $Sourcefile" -Activity "Extracting" -ParentId 1
            $outtemp = "$Source" +"\temp"
            &zip e $Sourcefile -o"$outtemp"
            $file = Get-ChildItem $outtemp -Recurse -Include $Extensions
            
            If ($file.count -eq 1) {
                $movedestinationPath = Split-Path $file.DirectoryName -Parent
                Move-Item -LiteralPath $file.FullName -Destination $movedestinationPath
                $file = get-childitem -LiteralPath (join-path -path $movedestinationPath -ChildPath $file.name)
                Remove-Item -Path $outtemp
                $Compressedfile = $true
                $Sourcefile    = $file.FullName
                $fileExtension = $file.Extension
            }
        }
   
        #Creating missing Cue file, to not have Chdman crash
        if ($fileExtension -like ".bin") {
            $Cuefile = join-path -path $file.DirectoryName -ChildPath ($file.BaseName + '.cue')
            Write-Verbose "Creating missing cue file $Cuefile"
            Write-Progress -Status "Creating missing cue file $Cuefile" -Activity "Creating Cue File" -ParentId 1
            if (-not (Test-Path $Cuefile)) {
                $binfilename = $file.Name
$Cuefiledata = @"
FILE "$binfilename" BINARY
  TRACK 01 MODE2/2352
    INDEX 01 00:00:00
"@
                Set-Content -Value $Cuefiledata -LiteralPath $Cuefile
                sleep 1
                $Sourcefile  = $Cuefile
            }
        }

        $ArgList = (
        'createcd',
        '-i',
        "`"$Sourcefile`"",
        '-o',
        "`"$destinationfile`""
        ) -join ' '

        Write-Verbose "Start-Process -NoNewWindow -FilePath $ChdmanEXE -ArgumentList $ArgList -PassThru"
        Write-Progress -Status "$ChdmanEXE $ArgList" -Activity "Building CHD file" -ParentId 1
        $process = Start-Process -FilePath $ChdmanEXE -ArgumentList $ArgList -PassThru

        If ($Compressedfile) {
            $process.WaitForExit()
            Write-Verbose "Cleaning up decompressed files"
            Write-Progress -Status "Cleaning up decompressed files" -Activity "Removing Files"
            Remove-item -LiteralPath $Sourcefile
            if ($fileExtension -like ".bin") {
                Remove-item -LiteralPath (Join-Path -path $movedestinationPath -ChildPath $file.name)
            }
        }

        [PSCUSTOMOBJECT]@{
            Source      = $Sourcefile
            Destination = $destinationfile
            Exitcode    = $process.ExitCode
        }   
    
        sleep 2

        Do {
            $ThreadProcesses  = (get-process -Name $Processname).count
            $processcount     = (get-process -Name chdman -ErrorAction SilentlyContinue).count
            $DestinationCount = (Get-ChildItem -path $Destination).count
            $Processed        = ($DestinationCount - $processcount) 
            sleep 10
            
            $DestinationSize  = ((Get-ChildItem -Path $Destination | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
            $elapsedTime      = $(get-date) - $StartTime
            $MBperSec         = $DestinationSize / $elapsedTime.totalseconds

            If ($Processed -eq 0) {
                $RemainingTime = 99999999
            } else {
                $RemainingTime    = ($elapsedTime.TotalSeconds / $Processed * $Total) - $elapsedTime.TotalSeconds
            }

            $sizeold = $size
            $size    = [MATH]::Round($DestinationSize)
            $Speed   = [MATH]::Round(($MBperSec),2)
            $TimeFullformat = "$($elapsedTime.Minutes)" +":" + "$($elapsedTime.seconds)"
            If ($Processed -eq 0) {
                Write-Progress -Status "Processed $size MB Speed $Speed Mb/s" -Activity "Processing Chdman Compression $Processed of total $Total - Elapsed Time $TimeFullformat" -PercentComplete ($Processed / $Total * 100) -Id 2
            }
            else {
                Write-Progress -Status "Processed $size MB Speed $Speed Mb/s" -Activity "Processing Chdman Compression $Processed of total $Total - Elapsed Time $TimeFullformat" -PercentComplete ($Processed / $Total * 100) -SecondsRemaining $RemainingTime -Id 2
            }
            
        } while ($ThreadProcesses -ge $Threads -or $Total -eq $Processed)
    }
}
