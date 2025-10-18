$pgrg = 'RG-HealthRules'
$pg = 'BILayerProximityGroup'
$vmrg = 'RG-HEALTHRULES'
$vms = 'aus-dwprod02-Zone3'


$ppg = Get-AzProximityPlacementGroup -ResourceGroupName $pgrg -Name $pg
$vm = Get-AzVM -ResourceGroupName $vmrg -Name $vms
Stop-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName
Update-AzVM -VM $vm -ResourceGroupName $vm.ResourceGroupName -ProximityPlacementGroupId $ppg.Id
Start-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName