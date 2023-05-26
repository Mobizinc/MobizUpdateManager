az config set extension.use_dynamic_install=yes_without_prompt
az rest --method put --uri https://management.azure.com/subscriptions/158d9f92-ec1e-433e-8388-6f7157282c13/resourceGroups/mobizupdatemgr-qa-rg/providers/Microsoft.Automation/automationAccounts/mobizupdatemgr-dev-aa35/variables/Test?api-version=2020-01-13-preview --body '{ "properties": { "value": "\"test\"" } }'




