#Backup Script for Server Win2003Licensed
Select-AzSubscription -Subscription "BIIR"

$vm = "Win2003Licensed"
$rg = "RG-BIIR_CDT"
$date1 = (get-date).adddays(-14)
$date2 = (get-date)
$date1 = get-date $date1 -format "MMddyy"
$date2 = get-date $date2 -format "MMddyy"

#Delete 2 week old Snapshots
Remove-AzSnapshot -ResourceGroupName $rg -SnapshotName "BackupOS$date1-$vm" -Force
Remove-AzSnapshot -ResourceGroupName $rg -SnapshotName "BackupDataDisk$date1-$vm" -Force

#Create Current Week Snapshots
$vmdetails = Get-Azvm -ResourceGroupName $rg -Name $vm

$snapshot = New-AzSnapshotConfig -SourceUri $vmdetails.StorageProfile.OsDisk.ManagedDisk.id -Location $vmdetails.Location -CreateOption copy -Tag @{DeleteAfter="Never"}

New-AzSnapshot -Snapshot $snapshot -SnapshotName "BackupOS$date2-$vm" -ResourceGroupName $rg

$snapshot = New-AzSnapshotConfig -SourceUri $vmdetails.StorageProfile.DataDisks.ManagedDisk.id -Location $vmdetails.Location -CreateOption copy -Tag @{DeleteAfter="Never"}

New-AzSnapshot -Snapshot $snapshot -SnapshotName "BackupDataDisk$date2-$vm" -ResourceGroupName $rg