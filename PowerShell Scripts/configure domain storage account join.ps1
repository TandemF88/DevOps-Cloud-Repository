$rg = "RG-ADBMR"
$saname = "bswhadbackup"
$said = "S-1-5-21-985149797-871377110-929701000-1001949"



# Set the feature flag on the target storage account and provide the required AD domain information
Set-AzStorageAccount `
        -ResourceGroupName $rg `
        -Name $saname `
        -EnableActiveDirectoryDomainServicesForFile $true `
        -ActiveDirectoryDomainName "bhcs" `
        -ActiveDirectoryNetBiosDomainName "BHCS" `
        -ActiveDirectoryForestName "bhcs.pvt" `
        -ActiveDirectoryDomainGuid "cf29f6b9-196c-4a07-b283-e15d3f235700" `
        -ActiveDirectoryDomainsid "S-1-5-21-985149797-871377110-929701000" `
        -ActiveDirectoryAzureStorageSid $said `
        #-ActiveDirectorySamAccountName "brooklynfslogix" `
        #-ActiveDirectoryAccountType "Computer"