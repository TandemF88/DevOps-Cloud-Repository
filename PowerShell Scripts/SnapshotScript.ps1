#Get the content from CSV on the column ServerList and store it on the variable $Servers
$Servers = Import-csv "C:\Temp\ServerList.csv" | select ServerList
#Get the content from CSV on the column ResourceGroup and store it on the Array $Resource
$Resource = @(Import-csv "C:\Temp\ServerList.csv" | select ResourceGroup)
#counter to keep track of each value on the $Resource Array
$count = 0

#variable to store the Date for the deleteaftertag (14 days on the future since it was created)
$date = (get-date).adddays(7)
$date = get-date $date -format "MM/dd/yy"


#Loop to get through the servers list
foreach ($server in $servers){
    
    #Line 12-14 Gets the contents so we can Match both VM Name and Resource Group, it cleans the string so we just return the exact value for each.
    $RG = $resource[$count]
    $RG = $RG -replace ".*=" -replace "}"
    $Server = $server -replace ".*=" -replace "}"

    #VM details for the current vm on the list
    $vmdetails = Get-Azvm -ResourceGroupName $RG -Name $server

    #Creates Snapshot for the OS Disk of the current VM the snapshot is created on the same location as the VM, it will tag it to be deleted after 7 days
    $snapshot = New-AzSnapshotConfig -SourceUri $vmdetails.StorageProfile.OsDisk.ManagedDisk.id -Location $vmdetails.Location -CreateOption copy -Tag @{DeleteAfter="$date"}


    if ((Get-AzSnapshot -ResourceGroupName $RG -SnapshotName "PatchingSnapshot-$server" -ErrorAction SilentlyContinue) -ne $null){
        
        
        Remove-AzSnapshot -ResourceGroupName $RG -SnapshotName "PatchingSnapshot-$server" -Force

    }
    Try{    

        New-AzSnapshot -Snapshot $snapshot -SnapshotName "PatchingSnapshot-$server" -ResourceGroupName $RG         
        #Creates a file named snapshotlist.txt and appends a list of all the created snapshots for easy tracking.
        Add-Content C:\Temp\snapshotlist.txt "PatchingSnapshot-$server,$RG"

    }

    Catch{

        Add-Content C:\Temp\snapshotlist.txt "ErrorPatchingSnapshot-$server,$RG"

    }

    #Counter increased to +1 on each run, this will get the next value on the string for the $Resource Array so we can match it correctly to each VM en the provided list. 
    $count += 1 
}