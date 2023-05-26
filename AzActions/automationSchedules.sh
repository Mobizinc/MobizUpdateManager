az config set extension.use_dynamic_install=yes_without_prompt
automationAccountToTarget=$(az automation account show --name $AutomationAccountName --resource-group $ResourceGroupName --query "id" --output tsv)


# Create and Asscociate Schedule MonitorUpdateManagementHourly
az automation schedule create --automation-account-name $AutomationAccountName  --resource-group $ResourceGroupName -n "MonitorUpdateManagementHourly" --frequency Hour --interval 1

#Get Schedule
schedule=$(az automation schedule show --name "MonitorUpdateManagementHourly" --automation-account-name $AutomationAccountName --resource-group $ResourceGroupName --query "id" --output tsv)

#Get Runbook
runbook=$(az automation runbook show --name "MonitorSchedules" --account $automationAccountToTarget --query "id" --output tsv)

#Associate Schedule
az automation runbook register --schedule $schedule --runbook $runbook --account $automationAccountToTarget
