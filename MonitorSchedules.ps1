name: Deploy Resources

on:
  workflow_dispatch:

env:

  LOGICAPP_DIRECTORY: LogicApp

jobs:
  deploy-and-run:
    runs-on: ubuntu-latest
    environment: qa
    steps:
       - name: Checkout repository
         uses: actions/checkout@v2
        
       - name: Create Azure cred variable
         run: |
          AzureCreds=$(echo '{"clientId": "${{secrets.AZURE_CLIENT_ID}}", "clientSecret": "${{secrets.AZURE_CLIENT_SECRET}}", "subscriptionId": "${{secrets.AZURE_SUBSCRIPTION_ID}}", "tenantId": "${{secrets.AZURE_TENANT_ID}}"}' | jq -c .)
          echo "AzureCreds=$AzureCreds" >> $GITHUB_ENV
          logicAppName=$(jq -r '.parameters.LogicAppName.value' parameters.json)
          echo "LogicAppName=$logicAppName" >> $GITHUB_ENV
          automationAccountName=$(jq -r '.parameters.AutomationAccountName.value' parameters.json)
          echo "AutomationAccountName=$automationAccountName" >> $GITHUB_ENV

       - uses: azure/login@v1
         with:
          creds: ${{ env.AzureCreds }}

    

       - name: Deploy ARM Template
         uses: azure/arm-deploy@v1
         with:
          resourceGroupName: ${{ vars.RESOURCE_GROUP_NAME }}
          template: deploy.json
          parameters: parameters.json 
         
         

       - name: Zip logicapp files
         run: (cd ${{ env.LOGICAPP_DIRECTORY }} && zip -rq ../${{ github.run_id }}.zip ./* -x /*workflow-designtime/*)
       - name: Upload Zip logicapp files
         uses: actions/upload-artifact@master
         with:
          name: build-artifact
          path: ${{ github.run_id }}.zip

       - name: Download logicapp files
         uses: actions/download-artifact@master
         with:
           name: build-artifact
           path: build-art/

       - name: Deploy to Azure Logic App
         uses: Azure/functions-action@v1
         id: la
         with:
          app-name: ${{ env.LogicAppName }}
          package: build-art/${{ github.run_id }}.zip
          resource-group: ${{ vars.RESOURCE_GROUP_NAME }}
          credentials: ${{ secrets.AZURE_CREDENTIALS }}
       - name: Update Runbook Content
         run: |
          ls
          az config set extension.use_dynamic_install=yes_without_prompt
          az automation runbook replace-content --automation-account-name "${{ env.AutomationAccountName }}" --resource-group ${{ vars.RESOURCE_GROUP_NAME }} --name "TurnOnVMs-UpdateStart" --content @TurnOnVMs-UpdateStart.ps1
          az automation runbook publish --resource-group ${{ vars.RESOURCE_GROUP_NAME }} --automation-account-name "${{ env.AutomationAccountName }}" --name "TurnOnVMs-UpdateStart"
          az automation runbook replace-content --automation-account-name "${{ env.AutomationAccountName }}" --resource-group ${{ vars.RESOURCE_GROUP_NAME }} --name "TurnOffVMs-UpdateEnds" --content @TurnOffVMs-UpdateEnds.ps1
          az automation runbook publish --resource-group ${{ vars.RESOURCE_GROUP_NAME }} --automation-account-name "${{ env.AutomationAccountName }}" --name "TurnOffVMs-UpdateEnds"
          az automation runbook replace-content --automation-account-name "${{ env.AutomationAccountName }}" --resource-group ${{ vars.RESOURCE_GROUP_NAME }} --name "MonitorSchedules" --content @MonitorSchedules.ps1
          az automation runbook publish --resource-group ${{ vars.RESOURCE_GROUP_NAME }} --automation-account-name "${{ env.AutomationAccountName }}" --name "MonitorSchedules"


