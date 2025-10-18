# Get all VMs from file
$vms =  Get-Content "C:\Temp\serverlist.csv"

foreach ($vm in $vms) {
    # Working on the following VM
    $charArray = $vm.Split(",")
    Write-Host $charArray[0]

    # Get the VM extensions
    $extensions = Get-AzVMExtension -ResourceGroupName $charArray[1] -VMName $charArray[0]

    foreach ($extension in $extensions) {
        # Check if the extension is MMA (Microsoft Monitoring Agent)
        if ($extension.Publisher -eq "Microsoft.EnterpriseCloud.Monitoring" -and $extension.ExtensionType -eq "MicrosoftMonitoringAgent") {
            Write-Host "Uninstalling MMA extension from VM $charArray[0] in Resource Group $resourceGroupName..."
            Write-Host $extension.Name

            # Uninstall the extension
            Remove-AzVMExtension -ResourceGroupName $charArray[1] -VMName $charArray[0] -Name $extension.Name -Force
        }
    }
    Write-Host " "
}

Write-Host "Script completed."

