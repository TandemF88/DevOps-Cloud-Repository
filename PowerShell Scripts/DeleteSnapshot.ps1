$snapshots = Import-csv "C:\Temp\snapshotlist.csv" | select snapshot
$Resource = @(Import-csv "C:\Temp\snapshotlist.csv" | select RG)
$count = 0

foreach ($snapshot in $snapshots){

    $RG = $resource[$count]
    $RG = $RG -replace ".*=" -replace "}"
    $snapshot = $snapshot -replace ".*=" -replace "}"
    Remove-AzSnapshot -ResourceGroupName $RG -SnapshotName $snapshot -Force
    $count += 1

}