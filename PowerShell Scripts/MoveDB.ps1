$fogroup = Get-AzSqlDatabaseFailoverGroup -ResourceGroupName "Central-RG" -ServerName "sqlserveruscentral"

foreach ($group in $fogroup){

    Remove-AzSqlDatabaseFailoverGroup -ResourceGroupName "Central-RG" -ServerName "sqlserveruscentral" -FailoverGroupName $group.FailoverGroupName
    Start-Sleep -seconds 60
    New-AzSqlDatabaseFailoverGroup -ResourceGroupName "Central-RG" -ServerName "sqlserveruscentral" -PartnerResourceGroupName "East-RG" -PartnerServerName "sqlserveruseast" -FailoverGroupName $group.FailoverGroupName -FailoverPolicy Automatic -GracePeriodWithDataLossHours 1
    foreach($DB in $group.DatabaseNames){
        Get-AzSqlDatabase -ResourceGroupName "Central-RG" -ServerName "sqlserveruscentral" -DatabaseName $DB | Add-AzSqlDatabaseToFailoverGroup -ResourceGroupName "Central-RG" -ServerName "sqlserveruscentral" -FailoverGroupName $group.FailoverGroupName
    }
}