
[array]$vm = get-azvm -status

$a = New-Object -comobject Excel.Application
$a.visible = $True 

$b = $a.Workbooks.add()

$c = $b.Worksheets.add()

$intRow = 2


$c.Cells.Item(1,2) = "Hostname"
$c.Cells.Item(1,3) = "OS"
$c.Cells.Item(1,4) = "Subscription"
$c.Cells.Item(1,5) = "ResourceGroup"
$c.Cells.Item(1,6) = "CPU Cores"
$c.Cells.Item(1,7) = "Installed Ram inGB"
$c.Cells.Item(1,8) = "OS DiskSize inMB"
$c.Cells.Item(1,9) = "CPU Usage %"
$c.Cells.Item(1,10) = "Ram Usage inGB"
$c.Cells.Item(1,2).font.bold = $True
$c.Cells.Item(1,3).font.bold = $True
$c.Cells.Item(1,4).font.bold = $True
$c.Cells.Item(1,5).font.bold = $True
$c.Cells.Item(1,6).font.bold = $True
$c.Cells.Item(1,7).font.bold = $True
$c.Cells.Item(1,8).font.bold = $True
$c.Cells.Item(1,9).font.bold = $True
$c.Cells.Item(1,10).font.bold = $True
$c.Cells.Item(1,2).borders.linestyle = 1
$c.Cells.Item(1,3).borders.linestyle = 1
$c.Cells.Item(1,4).borders.linestyle = 1
$c.Cells.Item(1,5).borders.linestyle = 1
$c.Cells.Item(1,6).borders.linestyle = 1
$c.Cells.Item(1,7).borders.linestyle = 1
$c.Cells.Item(1,8).borders.linestyle = 1
$c.Cells.Item(1,9).borders.linestyle = 1
$c.Cells.Item(1,10).borders.linestyle = 1

foreach ($server in $vm){

    if ($server.PowerState -eq "VM running") {
        
        try{    
        $size = get-azvmsize -location $server.Location | ?{ $_.name -eq $server.HardwareProfile.VmSize }

           }
        catch{
            $server

        }
        $ID = (Get-AZvm -ResourceGroupName $server.ResourceGroupName -Name $server.Name).Id
        $CPUUsage = Get-AzMetric -ResourceId $ID -TimeGrain 00:01:00 -DetailedOutput -metricnames "Percentage CPU"
        $CPUUsage = $CPUUsage.data | Select-Object -first 1        
        $RAMUsage = Get-AzMetric -ResourceId $server.Id -TimeGrain 00:01:00 -DetailedOutput -metricnames "Available Memory Bytes"
        $RAMUsage = $RAMUsage.data | Select-Object -first 1      
        
        $ramgb = $size.MemoryInMB / 1024
        $availram =  ($ramgb - ($RAMUsage.average / 1024 / 1024 / 1024))   
        
            $c.Cells.Item($intRow, 2) = $server.Name
            $c.Cells.Item($intRow, 3) = $server.LicenseType
            $c.Cells.Item($intRow, 4) = "Enterprise Dev/Test"
            $c.Cells.Item($intRow, 5) = $server.ResourceGroupName
            $c.Cells.Item($intRow, 6) = $size.NumberOfCores
            $c.Cells.Item($intRow, 7) = $ramgb
            $c.Cells.Item($intRow, 8) = $size.OSDiskSizeInMB / 1024
            $c.Cells.Item($intRow, 9) = [math]::Round($CPUUsage.average,2)
            $c.Cells.Item($intRow, 10) = [math]::Round($availram,2)          
            $c.Cells.Item($intRow, 2).borders.linestyle = -4118
            $c.Cells.Item($intRow, 3).borders.linestyle = -4118
            $c.Cells.Item($intRow, 4).borders.linestyle = -4118
            $c.Cells.Item($intRow, 5).borders.linestyle = -4118
            $c.Cells.Item($intRow, 6).borders.linestyle = -4118
            $c.Cells.Item($intRow, 7).borders.linestyle = -4118
            $c.Cells.Item($intRow, 8).borders.linestyle = -4118
            $c.Cells.Item($intRow, 9).borders.linestyle = -4118
            $c.Cells.Item($intRow, 10).borders.linestyle = -4118
            
            if ($CPUUsage.Average -gt 90){
                $c.Cells.Item($intRow,9).interior.colorindex = 9
                $c.Cells.Item($intRow,9).font.bold = $True
                
            }
            else{

                $c.Cells.Item($intRow,9).interior.colorindex = 4
                $c.Cells.Item($intRow,9).font.bold = $True

            }

            $rampercentage = ($availram / $ramgb) * 100
            if ($rampercentage -gt 90){
                $c.Cells.Item($intRow,10).interior.colorindex = 9
                $c.Cells.Item($intRow,10).font.bold = $True
                
            }
            else{

                $c.Cells.Item($intRow,10).interior.colorindex = 4
                $c.Cells.Item($intRow,10).font.bold = $True

            }


            $intRow += 1

    }

}

$c.Columns.AutoFit()


