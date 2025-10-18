
[array]$vm = get-azvm -status
$cont = 0

$vmobjs = @()

foreach ($server in $vm){

    if ($vm[$cont].PowerState -eq "VM running") {
            
        $size = get-azvmsize -location $vm[$cont].Location | ?{ $_.name -eq $vm[$cont].HardwareProfile.VmSize }
        $ID = (Get-AZvm -ResourceGroupName $vm[$cont].ResourceGroupName -Name $vm[$cont].Name).Id
        $CPUUsage = Get-AzMetric -ResourceId $ID -TimeGrain 00:01:00 -DetailedOutput -metricnames "Percentage CPU"
        $CPUUsage = $CPUUsage.data | Select-Object -first 1        
        $RAMUsage = Get-AzMetric -ResourceId $server.Id -TimeGrain 00:01:00 -DetailedOutput -metricnames "Available Memory Bytes"
        $RAMUsage = $RAMUsage.data | Select-Object -first 1        
        $vmInfo = [pscustomobject]@{
            'Hostname' = $vm[$cont].Name
            'OS' = $vm[$cont].LicenseType
            'Subscription' = 
            'ResourceGroup' = $vm[$cont].ResourceGroupName
            'CPU Cores' = $size.NumberOfCores
            'Installed Ram inGB' = $size.MemoryInMB / 1024
            'OS DiskSize inMB' = $size.OSDiskSizeInMB / 1024
            'CPU Usage %' = $CPUUsage.average
            'Ram Usage inMB' = ($size.OSDiskSizeInMB / 1024 - ($RAMUsage.average / 1024 / 1024 / 1024))            
        }  
        $vmobjs += $vmInfo      
    }
    $cont += 1

}

$vmobjs | Export-excel -Path C:\Temp\CapacityReport.xlsx


