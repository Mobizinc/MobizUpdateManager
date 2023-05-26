az config set extension.use_dynamic_install=yes_without_prompt
az automation variable create --name 'UpdateMgrAutomationAccountName' --value 'Need To Add' --automation-account-name $AutomationAccountName --resource-group $ResourceGroupName
az automation variable create --name 'UpdateMgrRG' --value 'Need To Add' --automation-account-name $AutomationAccountName --resource-group $ResourceGroupName
az automation variable create --name 'UpdateMgrScheduleMonitorQueue' --value 'schedulemonitorqueue' --automation-account-name $AutomationAccountName --resource-group $ResourceGroupName
az automation variable create --name 'UpdateMgrStorageAccount' --value 'Need To Add' --automation-account-name $AutomationAccountName --resource-group $ResourceGroupName
az automation variable create --name 'UpdateMgrSummaryQueue' --value 'updatesummary' --automation-account-name $AutomationAccountName --resource-group $ResourceGroupName
