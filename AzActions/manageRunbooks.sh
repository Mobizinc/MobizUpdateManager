az config set extension.use_dynamic_install=yes_without_prompt
az automation runbook replace-content --automation-account-name $AutomationAccountName --resource-group $ResourceGroupName --name "TurnOnVMs-UpdateStart" --content @TurnOnVMs-UpdateStart.ps1
az automation runbook publish --resource-group $ResourceGroupName --automation-account-name $AutomationAccountName --name "TurnOnVMs-UpdateStart"
az automation runbook replace-content --automation-account-name $AutomationAccountName --resource-group $ResourceGroupName --name "TurnOffVMs-UpdateEnds" --content @TurnOffVMs-UpdateEnds.ps1
az automation runbook publish --resource-group $ResourceGroupName --automation-account-name $AutomationAccountName --name "TurnOffVMs-UpdateEnds"
az automation runbook replace-content --automation-account-name $AutomationAccountName --resource-group $ResourceGroupName --name "MonitorSchedules" --content @MonitorSchedules.ps1
az automation runbook publish --resource-group $ResourceGroupName --automation-account-name $AutomationAccountName --name "MonitorSchedules"