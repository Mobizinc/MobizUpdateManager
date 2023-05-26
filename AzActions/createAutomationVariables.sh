az config set extension.use_dynamic_install=yes_without_prompt
az automation variable create --name 'UpdateMgrAutomationAccountName' --value 'Need to Add' --automation-account-name $AutomationAccountName --resource-group $ResourceGroupName

