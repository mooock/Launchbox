Function Set-LaunchboxXMLModify {
param (
$Compatibility   = 'Super Nintendo Entertainment System',
$Path            = 'C:\Launchbox\Data\Platforms\Super Nintendo Entertainment System.xml',
$URI             = 'https://retroachievements.org/gameList.php?c=3',
$CustomfieldName = 'Retroachievements',
$OldValue        = 'Super Nintendo Entertainment System No Retroachievements',
[Switch]$WriteData
)

    #Import Functions
    Function Parse-Webrequst {
param(
    [Parameter(Mandatory = $true)]
    [Microsoft.PowerShell.Commands.HtmlWebResponseObject] $WebRequest,
  
    [Parameter(Mandatory = $true)]
    [int] $TableNumber
)

## Extract the tables out of the web request
$tables = @($WebRequest.ParsedHtml.getElementsByTagName("TABLE"))
$table  = $tables[$TableNumber]
$titles = @()
$rows = @($table.Rows)

## Go through all of the rows in the table
foreach($row in $rows)
{
    $cells = @($row.Cells)
   
    ## If we've found a table header, remember its titles
    if($cells[0].tagName -eq "TH")
    {
        $titles = @($cells | % { ("" + $_.InnerText).Trim() })
        continue
    }

    ## If we haven't found any table headers, make up names "P1", "P2", etc.
    if(-not $titles)
    {
        $titles = @(1..($cells.Count + 2) | % { "P$_" })
    }

    ## Now go through the cells in the the row. For each, try to find the
    ## title that represents that column and create a hashtable mapping those
    ## titles to content
    $resultObject = [Ordered] @{}
    for($counter = 0; $counter -lt $cells.Count; $counter++)
    {
        $title = $titles[$counter]
        if(-not $title) { continue }  

        $resultObject[$title] = ("" + $cells[$counter].InnerText).Trim()
    }

    ## And finally cast that hashtable to a PSCustomObject
    [PSCustomObject] $resultObject
}
}

    #parse weblist to psobject
    Write-Progress -Activity "Downloading web information from $URI" -PercentComplete 10
    $Web      = Invoke-WebRequest $URI
    $Weblist  = Parse-Webrequst -WebRequest $web -TableNumber 1
    $Weblist  = $Weblist | select -SkipLast 1

    #Get Launchbox list into XML
    Write-Progress -Activity "Reading Launchbox list from $Path" -PercentComplete 20
    [XML]$data = [System.Xml.XmlDocument](Get-Content -Path $Path)  
    $Gamelist = $data.LaunchBox.Game

    #Build Gamelist from launchbox
    Write-Progress -Activity "Building Gamelist from Launchbox" -PercentComplete 40
    $GameIdList = $data.LaunchBox.CustomField | ForEach-Object {
        $Game  = ($Gamelist | where id -eq $_.Gameid)
        [STRING]$Title  = ($Game.Title).Trim()
        [PSCUSTOMOBJECT]@{
            GameTitle = $Title
            GameID    = $_.Gameid
            Name      = $_.Name
            Value     = $_.Value
        }
    }

    #Compare Result
    Write-Progress -Activity "Comparing web results" -PercentComplete 60
    $ComparedList = Foreach ($WebItem in $Weblist) {
        ForEach ($GameId in $GameIdList){
        
        if ($WebItem.Title -match '|') {
            $WebItemTitle = $WebItem.Title -replace '|',''
        } else {
            $WebItemTitle = $WebItem.Title
        }

        if ($GameId.GameTitle -like '*+*') {
            $GameIdTitle = $GameId.GameTitle -replace '\+',''
        } else {
            $GameIdTitle = $GameId.GameTitle
        }

            If ($WebItemTitle -like $GameIdTitle) {
                [PSCUSTOMOBJECT]@{
                    GameTitle = $GameIdTitle
                    GameID    = $GameId.Gameid
                    Name      = $GameId.Name
                    Value     = $GameId.Value
                }
            }
        }
    }

    Write-Progress -Activity "Updating XML Data" -PercentComplete 80
    ForEach ($ComparedItem in $ComparedList) {
        $FieldUpdate = $false
        #Write Changed data
        If ($WriteData) {
            #Only Write to non modified results
            Write-Progress -Activity "Updating XML Data" -PercentComplete 90
            $data.LaunchBox.CustomField | Where-Object {
                $_.GameID -eq $ComparedItem.GameID -and
                $_.Name  -like $CustomfieldName -and
                $_.value -like $OldValue
            } | ForEach-Object {
                $FieldUpdate = $true
                $_.value = $Compatibility
            }
        }

        #Output to screen
        [PSCUSTOMOBJECT]@{
            GameTitle   = $ComparedItem.GameTitle
            GameID      = $ComparedItem.Gameid
            Name        = $ComparedItem.Name
            Value       = $ComparedItem.Value
            Fieldupdate = $FieldUpdate
        }
    }

    #Stores Changes to XML file if write switch is set
    If ($WriteData) {
        Write-Progress -Activity "Saving data to $path" -PercentComplete 90
        $data.Save($Path)
    }
}
