$vmListFile = "vmlist.csv"
$vmList = Import-Csv $vmListFile
$subscription = 'subnameoftheworkspace'
Connect-AzAccount -Tenant 'tenantid'
Set-AzContext -subscription $subscription
$PublicSettings = @{ "workspaceId" = "xxxxx" }
$ProtectedSettings = @{ "workspaceKey" = "xxxxx" }
ForEach ($vm in $vmList) {
    $VMName = $vm.name
    $ResourceGroupName = $vm.resourcegroup
    $Location = $vm.location
    Write-Host "Processing $VMName"
    Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" `
    -ResourceGroupName "$ResourceGroupName" `
    -VMName "$VMName" `
    -Publisher "Microsoft.EnterpriseCloud.Monitoring" `
    -ExtensionType "MicrosoftMonitoringAgent" `
    -TypeHandlerVersion 1.0 `
    -Settings $PublicSettings `
    -ProtectedSettings $ProtectedSettings `
    -Location "$Location"
}
