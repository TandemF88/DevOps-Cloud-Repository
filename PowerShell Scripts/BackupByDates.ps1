$vms =  Get-Content ".\serverlist.txt"
$dates =  Get-Content ".\dates.txt"
$vault = Get-AzRecoveryServicesVault -ResourceGroupName "RG-HealthRules" -Name "RecoveryBackupHRPRD-east"
$jobsArray = @()

foreach ($vm in $vms) {    

    foreach ($date in $dates) {
        $JobsCompleted = Get-AzRecoveryServicesBackupJob -VaultId $vault.ID -Status Completed -From (Get-Date -Date $date).ToUniversalTime() -To (Get-Date -Date $date).AddDays(1).ToUniversalTime() -BackupManagementType AzureVM | Where-Object {$_.WorkloadName -eq $vm}
        $JobsFailed = Get-AzRecoveryServicesBackupJob -VaultId $vault.ID -Status Failed -From (Get-Date -Date $date).ToUniversalTime() -To (Get-Date -Date $date).AddDays(1).ToUniversalTime() -BackupManagementType AzureVM | Where-Object {$_.WorkloadName -eq $vm}
        $jobsArray += $JobsCompleted
        $jobsArray += $JobsFailed
        Write-Host "Getting details for server $vm and date $date" 
    }
}
Write-Host "Done!"

$jobsArray | Export-Csv BackupDetails.csv -NoTypeInformation