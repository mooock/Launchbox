Function Set-LaunchboxCompatibility {
param (
$Name,
$Compatibility = 'Perfect',
$Path = 'C:\Launchbox\Nintendo Switch.xml',
$CustomfieldName = 'Nintendo Switch Compatibility',
[Switch]$WriteData
)

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

    $URI      = 'https://yuzu-emu.org/game/'
    $Web      = Invoke-WebRequest $URI
    $Complist = Parse-Webrequst -WebRequest $web -TableNumber 1

    [XML]$data = [System.Xml.XmlDocument](Get-Content -Path $Path)  

    ForEach ($Customfield in $data.LaunchBox.CustomField){
        
        $Game  = ($data.LaunchBox.Game | where id -eq $Customfield.Gameid)
        #$Game  = ($data.LaunchBox.Game | where Title -like $Name)

        [STRING]$GameID = ($Game.id).Trim()
        [STRING]$Title  = ($Game.Title).Trim()

        $WebCompatibility = 'Unknown'
        $Complist | ForEach-Object {
            $FuzzySearch = $_.'Game title' -replace ': ',' '
            $FuzzySearch = $FuzzySearch -replace '™',''
            $FuzzySearch = $FuzzySearch -replace '!',''
            $FuzzySearch = $FuzzySearch -replace "’",''
            $FuzzySearch = $FuzzySearch -replace "Æ",''

            $Title = $Title -replace ': ',' '
            $Title = $Title -replace '™',''
            $Title = $Title -replace '!',''
            $Title = $Title -replace "’",''

            If ($FuzzySearch -like $Title) {
                $WebCompatibility = $_.'Compatibility'
            }
        }

        $LaunchboxLookupIDs     = $data.LaunchBox.CustomField 
        $LaunchboxLookupID      = $LaunchboxLookupIDs | where GameID -eq $GameID
        $LaunchboxCompatibility = ($LaunchboxLookupID).value

        $WebResult = switch ($WebCompatibility)
        {
            "Unknown"    {0; break }
            "Not Tested" {1; break }
            "Won't Boot" {2; break }
            "Intro/Menu" {3; break }
            "Bad"        {4; break }
            "Okay"       {5; break }
            "Great"      {6; break }
            "Perfect"    {7; break }
        }

        $LaunchboxResult = switch ($LaunchboxCompatibility)
        {
            "Unknown"    {0; break }
            "Not Tested" {1; break }
            "Won't Boot" {2; break }
            "Intro/Menu" {3; break }
            "Bad"        {4; break }
            "Okay"       {5; break }
            "Great"      {6; break }
            "Perfect"    {7; break }
        }

        If ($GameID -and $WriteData -and $WebCompatibility) {
            #Only Write better results fetched from web
            If ($WebResult -gt $LaunchboxResult) {
                $data.LaunchBox.CustomField | Where-Object {$_.GameID -eq $GameID -and $_.Name -like $CustomfieldName} | ForEach-Object {$_.value = $WebCompatibility}
            }
        }

        If ($WebCompatibility -and ($Customfield.name -like $CustomfieldName)) {
                [PSCUSTOMOBJECT]@{
                Name                   = $Title
                Compatibility          = $WebCompatibility
                GameId                 = $GameID
                WebCompatibility       = $WebResult
                LaunchboxCompatibility = $LaunchboxResult 
            }
        }
    }

    #Stores Changes to XML file if write switch is set
    If ($GameID -and $WriteData -and $ValidGameID) {
            $data.Save($Path)
        }
}
