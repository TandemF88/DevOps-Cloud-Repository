$server = "atos-bsw-test-sc"
$rg = "rg-AtosTesting"

$details = Get-AzSqlDatabaseFailoverGroup -ResourceGroupName $rg -ServerName $server
$Report = @()

foreach($group in $details){
        
    foreach($DB in $group.DatabaseNames){
        $Row = "" | Select PrimaryServer, SecondaryServer, FailoverGroupName, DBList
        $Row.PrimaryServer = $group.ServerName
        $Row.SecondaryServer = $group.PartnerServerName
        $Row.FailoverGroupName = $group.FailoverGroupName
        $Row.DBList = $DB
        $Report += $Row
    }
}
$outfile = "C:\temp\Report.csv"
$Report | Export-Csv -Path $outfile -NoTypeInformation