$storageRGName=Get-AutomationVariable -Name "UpdateMgrRG"
$storageAccountName=Get-AutomationVariable -Name "UpdateMgrStorageAccount"
$scheduleMonitorQueue=Get-AutomationVariable -Name "UpdateMgrScheduleMonitorQueue"
$automationAccountName=Get-AutomationVariable -Name "UpdateMgrAutomationAccountName"



foreach ($schedule in $schedules)
{
  #Check for next run range- filter
  $schedulesToCommunicate=Get-AzAutomationSoftwareUpdateConfiguration -AutomationAccountName $automationAccountName  -ResourceGroupName $storageRGName -Name $schedule.Name
  

    
    $scheduleTimeSpan= NEW-TIMESPAN –Start $StartDate –End $schedule.ScheduleConfiguration.NextRun.UtcDateTime
    

        if($scheduleTimeSpan -lt $timespan){
            $vmIds=@()
            $AzureContext = (Connect-AzAccount -Identity ).context

                $subs = Get-AzSubscription

                Foreach ($sub in $subs)
                    {
                        $subName = $sub.Name
                    # Write-Output "Processing subscription $($subName)"
                        select-AzSubscription $sub | Out-Null
                        $vms = Get-AzVM |select name,resourceGroupName,tags
                            Foreach ($vm in $vms)
                            {
                            # Write-Output "Processing VM $($vm.name)"                    
                                if($vm.tags['Patch_Schedule'] -eq $schedule.Name.trim()){                        
                                    $vmIds+=@{
                                                machineName=$vm.name
                                                subscription=$subName
                                                resourceGroup=$vm.resourceGroupName
                                        }
                                }

                            }
                    }

            
                $nextRun= ($schedule.ScheduleConfiguration.NextRun.UtcDateTime).ToString("dd/MM/yyyy HH:mm:ss")
                
                $scheduleDetails=@{
                name=$schedule.Name    
                nextRun=$nextRun
                vmIds=$vmIds
                }

            
            $scheduleDetails =$scheduleDetails | ConvertTo-Json -Depth 5 -Encoding UTF8
            
            Write-Output "Notifying $($schedule.Name) which is scheduled at $($schedule.ScheduleConfiguration.NextRun.UtcDateTime) for the scan time $($StartDate)"

            $queueMessage = [Microsoft.Azure.Storage.Queue.CloudQueueMessage]::new($scheduleDetails)
            $queueMessage.AsBytes = [System.Text.Encoding]::UTF8.GetBytes($queueMessage.AsString)
            $queue.CloudQueue.AddMessageAsync($queueMessage)
        }else{
            Write-Output "Skipping $($schedule.Name) which is scheduled at $($schedule.ScheduleConfiguration.NextRun.UtcDateTime) for the scan time $($StartDate)"
        }

}

