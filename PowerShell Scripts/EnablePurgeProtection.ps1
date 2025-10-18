#Store the list of vaults on a $vaults Variable
$vaults = Import-csv "C:\Temp\VaultList.csv"

#this foreach loop will go through each vault value stored on the $vaults variable and then will use the command set-azresource to change the properties in the vault, we will change the "enablepurgeprotection" property to a value of "true"
foreach ($vault in $vaults){


    ($resource = Get-AzResource -ResourceId (Get-AzKeyVault -VaultName $vault).ResourceId).Properties | Add-Member -MemberType "NoteProperty" -Name "enablePurgeProtection" -Value "true"

    Set-AzResource -resourceid $resource.ResourceId -Properties $resource.Properties

}