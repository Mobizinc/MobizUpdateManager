$logFile = Get-Date -Format "yyyyMMddHHmmss"
$vmListFile = "vmlist.csv"
$vmList = Import-Csv $vmListFile
$iterator = 0
Connect-AzAccount -Tenant 'tenantid'
ForEach ($vm in $vmList) {
    $subscription = $vm.subscription
    $resourceGroup = $vm.resourcegroup
    $vmName = $vm.name
    $tagValue = $vm.tagvalue
    Try {    
       
            Set-AzContext -Subscription $subscription | Out-Null
            $vmObj = $null
            #Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Status
            $vmObj = Get-AzVM  -Name  $vmName -Status | Select Tags,PowerState,Id
            #$vmObj
            If ($null -ne $vmObj)
            {
                #$vmState = (Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Status).Statuses[1].displayStatus
                If ($vmObj.PowerState -notlike '*stop*' -and $vmObj.PowerState -notlike '*deallocat*' )
                {
                    $iterator = $iterator + 1
                    $assignedTags = $vmObj.Tags
                    If(-Not $assignedTags.ContainsKey('Patch_Schedule')) {
                        $assignedTags.Add("Patch_Schedule", $tagValue)
                    }
                    Else {
                        $assignedTags["Patch_Schedule"] = $tagValue
                    }
                    
                    
                    Update-AzTag -ResourceId $vmObj.Id -Tag $assignedTags -Operation Replace | Out-Null
                    Write-Host "$iterator. Assigned tag to VM $vmName"
                }
            }
            Else {
                Write-Host "VM not found $vmName"
            }
        
    }
    Catch {
        $responseBody = $_
        if ($_.Exception.Response) {
            $result = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($result)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd();
        }
        $responseBody | Out-File -FilePath ".\$logFile.log" -Append
    }
}
