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
     $metrics = Get-AzMetric -ResourceId $vm.Id -StartTime (get-date).adddays(-29) -EndTime (get-date) `
     -TimeGrain 00:30:00 -MetricNames "Percentage CPU" -AggregationType Average -WarningAction Ignore
    
    if($metrics.data){
    $metrics.data | %{
          $obj = "" | select vm_name,timestamp,CPUPercent
          $obj.vm_Name = $vm.name
          $obj.Timestamp = $_.timestamp
          $obj.CPUPercent = $_.average / 100
          $results += $obj
         }
    }
    
$count += 1 
}

$results | export-csv -Path "C:\Temp\Results.csv" -NoTypeInformation