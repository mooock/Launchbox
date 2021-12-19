Function Convertfrom-XCI2NSP {
param(
  $Path      = "R:\NintendoSwitch\_Utility\4nxci-v4.03_GUI",
  $infile    = 'R:\NintendoSwitch\_XCi',
  $outfile   = 'R:\NintendoSwitch\_NSP',
  $Processed = "R:\NintendoSwitch\_Processed"
)
$i = 0
$key   = "$Path" + '\keys.dat'
$exe   = "$Path" + '\4nxci.exe'
$Files = (Get-ChildItem -Path $infile).FullName
    Foreach ($file in $files) {
        $i++
        sleep 1
        $total = ($($Files).Count)
        Write-Progress -Activity "Converting files" -Status "Processing $($file) - Completed $i \ $total" -PercentComplete (($i / $($Files).Count) * 100)
        & $exe $file --keyset $key --keepncaid --rename --outdir $outfile
        Move-Item -Path $file -Destination $Processed
    }
}
