#Request for Details, Store it on variables
Write-Host -NoNewline -ForegroundColor Green "Please enter the VM name you would like to remove from the pool:"
$VMName = Read-Host
Write-Host -NoNewline -ForegroundColor Green "Please enter the Host pool Name:"
$PoolName = Read-Host
Write-Host -NoNewline -ForegroundColor Green "Please enter the Host pool RG:"
$PoolRG = Read-Host

$scriptfile = new-temporaryfile 

$command = 'reg add HKLM\SOFTWARE\Microsoft\RDInfraAgent /v IsRegistered /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Microsoft\RDInfraAgent /v RegistrationToken /t REG_SZ /d TOKEN /f
net stop RDAgentBootLoader
net start RDAgentBootLoader
'

$vm = $VMName + ".bhcs.pvt"

#Removes Requested WVD from the WVD HostPool
Remove-AzWvdSessionHost -ResourceGroupName $poolrg -HostPoolName $PoolName -Name $vm

#Retrieves the Registration Token for the Pool and stores it on a variable
$token = Get-AzWvdHostPoolRegistrationToken -HostPoolName $PoolName -ResourceGroupName $PoolRG

$command = $command.replace('TOKEN',$token.Token)

out-file $scriptfile -Encoding ascii -InputObject $command ;

#Executes the script stored on the $command variable, this will add the registration token for the pool on the server back again, and restart the required services, the server will be added back to the host pool and it can be reassigned to a new user.
Invoke-AzVMRunCommand -ResourceGroupName $PoolRG -VMName $VMName -CommandId 'RunPowerShellScript' -ScriptPath $scriptfile