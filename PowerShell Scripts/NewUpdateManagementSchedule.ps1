#Get the content from CSV on the column ServerList and store it on the variable $Servers
$Servers = Import-csv "C:\Temp\ServerList.csv" | select ServerList
#Get the content from CSV on the column ResourceGroup and store it on the Array $Resource
$Resource = @(Import-csv "C:\Temp\ServerList.csv" | select ResourceGroup)
#counter to keep track of each value on the $Resource Array
$count = 0
$computers = $null

$autname = "CDT-ComputeInfrastructure-AutoAcct"
$autrg = "RG_Compute_CDT"


foreach ($server in $servers){

    $RG = $resource[$count]
    $RG = $RG -replace ".*=" -replace "}"
    $Server = $server -replace ".*=" -replace "}"

    $vmid = get-azvm -ResourceGroupName $RG -Name $Server

    $computers += @($vmid.Id)

    $count += 1 
}

$startTime = Get-Date -Year 2024 -Month 9 -Day 12 -Hour 19 -Minute 30 -Second 0

$TimeZone = ([System.TimeZoneInfo]::Local).Id

$sched = New-AzAutomationSchedule `
    -ResourceGroupName $autrg `
    -AutomationAccountName $autname `
    -Name September24PatchingDevWindows `
    -Description Patching `
    -OneTime `
    -StartTime $startTime `
    -Timezone $TimeZone `
    -ForUpdateConfiguration

New-AzAutomationSoftwareUpdateConfiguration  `
    -ResourceGroupName $autrg `
    -AutomationAccountName $autname `
    -Schedule $sched `
    -Windows `
    -AzureVMResourceId $computers `
    -Duration (New-TimeSpan -Hours 3) `
    -IncludedUpdateClassification Security,UpdateRollup,critical `
    -RebootSetting Always