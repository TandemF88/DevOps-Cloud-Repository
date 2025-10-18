#Get the content from CSV on the column ServerList and store it on the variable $Servers
$Servers = Import-csv "C:\Temp\ServerList.csv" | select ServerList
#Get the content from CSV on the column ResourceGroup and store it on the Array $Resource
$Resource = @(Import-csv "C:\Temp\ServerList.csv" | select ResourceGroup)
$count = 0
$results = @()
foreach($Server in $Servers){
    $RG = $resource[$count]
    $RG = $RG -replace ".*=" -replace "}"
    $Server = $Server -replace ".*=" -replace "}"
    $vm = Get-AzVM -ResourceGroupName "$RG" -name "$Server"
    Write-host " VM: " $Server
    $metrics = Get-AzMetric -ResourceId $vm.Id -StartTime (get-date).adddays(-1) -EndTime (get-date) `
        -TimeGrain 00:30:00 -MetricNames "Available Memory Bytes" -AggregationType Average -WarningAction Ignore

    if($metrics.data){
        $metrics.data | %{
            $obj = "" | select vm_name,timestamp,AvailRamGB
            $obj.vm_Name = $vm.name
            $obj.Timestamp = $_.timestamp
            $obj.AvailRamGB = $_.average / 1073741824
            $results += $obj
        }
    }
    
$count += 1 
}

$results | export-csv -Path "C:\Temp\Results2.csv" -NoTypeInformation