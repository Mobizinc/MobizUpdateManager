
$storageRGName=Get-AutomationVariable -Name "UpdateMgrRG"
$storageAccountName=Get-AutomationVariable -Name "UpdateMgrStorageAccount"
$scheduleMonitorQueue=Get-AutomationVariable -Name "UpdateMgrScheduleMonitorQueue"
$automationAccountName=Get-AutomationVariable -Name "UpdateMgrAutomationAccountName"
$scheduleMonitorTable=Get-AutomationVariable -Name "UpdateMgrMonitorTable"
$hoursToMonitor=Get-AutomationVariable -Name "UpdateMgrMonitorScope"
$defaultUserMIAppID=Get-AutomationVariable -Name "defaultUserMIAppID"

$StartDate=(GET-DATE)


#Set context and get Schedules
$AzureContext = (Connect-AzAccount -Identity -AccountId  $defaultUserMIAppID ).context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
$schedules=Get-AzAutomationSoftwareUpdateConfiguration -AutomationAccountName $automationAccountName  -ResourceGroupName $storageRGName



#Get Key and set Storage Context
$key = (Get-AzStorageAccountKey -ResourceGroupName $storageRGName -Name $storageAccountName)[0].Value
$updateMgrStoragecontext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key
$queue = Get-AzStorageQueue -Name $scheduleMonitorQueue -Context $updateMgrStoragecontext
$storageTable = Get-AzStorageTable -Name $scheduleMonitorTable -Context $updateMgrStoragecontext
$cloudTable = $storageTable.CloudTable

foreach ($schedule in $schedules)
{
  #Check for next run range- filter
  $schedulesToCommunicate=Get-AzAutomationSoftwareUpdateConfiguration -AutomationAccountName $automationAccountName  -ResourceGroupName $storageRGName -Name $schedule.Name
  $scheduleTimeSpan= NEW-TIMESPAN -Start $StartDate -End $schedule.ScheduleConfiguration.NextRun.UtcDateTime
  $nextRun= ($schedule.ScheduleConfiguration.NextRun.UtcDateTime).ToString("dd/MM/yyyy HH:mm:ss")

  $scopes=@()
  $scheduledScanScopes=$hoursToMonitor.split(',')
  foreach ($nextRunScope in $scheduledScanScopes){
            $timespan = new-timespan -hours $nextRunScope -minutes 15
            if($scheduleTimeSpan -lt $timespan){
                $moniteredScheduleNextRun=Get-AzTableRow -table $cloudTable `
                                -customFilter "(schedueleName eq '$($schedule.Name)' and nextRun eq '$($nextRun)' and scope eq '$($nextRunScope)')"
                                if($null -eq $moniteredScheduleNextRun){
                                        Write-Output " Processing communication of $($schedule.Name) for next run $($nextRun) with scope $($nextRunScope)"
                                        $scopes+=$nextRunScope
                                    }else{
                                        Write-Output " $($schedule.Name) for next run $($nextRun) already communicated with scope $($nextRunScope) "
                                    }
            }
  }


        if($scopes.length -gt 0){

            $vmIds=@()
            $AzureContext = (Connect-AzAccount -Identity -AccountId  $defaultUserMIAppID ).context

                $subs = Get-AzSubscription

                Foreach ($sub in $subs)
                    {
                        $subName = $sub.Name
                    
                        select-AzSubscription $sub | Out-Null
                        $vms = Get-AzVM | select name,resourceGroupName,tags
                            Foreach ($vm in $vms)
                            {
                               
                                if($vm.tags['Patch_Schedule'] -eq $schedule.Name.trim()){                        
                                    $vmIds+=@{
                                                machineName=$vm.name
                                                subscription=$subName
                                                resourceGroup=$vm.resourceGroupName
                                        }
                                }

                            }
                    }

                $scheduleDetails=@{
                name=$schedule.Name    
                nextRun=$nextRun
                vmIds=$vmIds
                scope=($scopes | measure-object -minimum).minimum                
                }

            
            $scheduleDetails =$scheduleDetails | ConvertTo-Json -Depth 5 
                        

            Write-Output "Notifying $($schedule.Name) which is scheduled at $($schedule.ScheduleConfiguration.NextRun.UtcDateTime) for the scan time $($StartDate)"

            $queueMessage = [Microsoft.Azure.Storage.Queue.CloudQueueMessage]::new($scheduleDetails)
            $response=$queue.CloudQueue.AddMessageAsync($queueMessage)

            foreach ($scope in $scopes)
            {
               Add-AzTableRow `
                    -table $cloudTable `
                    -partitionKey "monitor" `
                    -rowKey (New-Guid) -property @{"schedueleName"=$schedule.Name ;"nextRun"=$nextRun;"scope"=$scope} | Out-null

            }

        }else{
            Write-Output "Skipping $($schedule.Name) which is scheduled at $($schedule.ScheduleConfiguration.NextRun.UtcDateTime) for the scan time $($StartDate)"
        }

}
