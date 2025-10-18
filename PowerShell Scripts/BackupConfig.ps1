#Get the content from CSV on the column ServerList and store it on the variable $Servers
#$Servers = Import-csv "C:\Temp\ServerList.csv" | select ServerList
#Get the content from CSV on the column ResourceGroup and store it on the Array $Resource
#$Resource = @(Import-csv "C:\Temp\ServerList.csv" | select ResourceGroup)
#counter to keep track of each value on the $Resource Array
$count = 0

$Servers = Get-AzVM

foreach($server in $servers){
    #$RG = $resource[$count]
    #$RG = $RG -replace ".*=" -replace "}"
    #$Server = $server -replace ".*=" -replace "}"

    $details = Get-AzRecoveryServicesBackupStatus -Name $server.name -ResourceGroupName $server.ResourceGroupName -Type AzureVM

    $details = Get-AzRecoveryServicesBackupStatus -Name dev6.3 -ResourceGroupName RG-BIIR-SERVERS -Type AzureVM

    $count += 1 

    $backup = $details.BackedUp
    $vault = $details.VaultId
    $name = $server.name
    $RG = $server.ResourceGroupName

    if($details.BackedUp -eq $true){
        $container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vault -FriendlyName $name #-Status "Registered" 
        $backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -VaultId $vault
        }

    Add-Content C:\Temp\BackupReport.txt "$name, $backup, $vault, $RG"

}