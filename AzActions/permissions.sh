
role_name="Storage Queue Data Contributor"
# Get the Automation Account resource ID
automation_account_id=$(az automation account show --name "$AutomationAccountName" --resource-group "$ResourceGroupName" --query "id" --output tsv)
automation_objectid=$(az resource show --ids $automation_account_id --query 'identity.principalId' --output tsv)
#mi_clientId=$(az identity show --resource-group "$ResourceGroupName" --name "$UserManagedIdentity"  --query clientId --output tsv)

# Get the Storage Account resource ID
storage_account_id=$(az storage account show --name "$StorageAccountName" --resource-group "$ResourceGroupName" --query "id" --output tsv)

# Check if the role assignment already exists
existing_role_assignment=$(az role assignment list --assignee "$automation_objectid"  --scope "$storage_account_id" --query "[?roleDefinitionName=='$role_name']"  --output tsv)
echo "role: $existing_role_assignment"
# Create the role assignment if it doesn't exist
if [[ -z "$existing_role_assignment" ]]; then
    az role assignment create --assignee-object-id "$automation_objectid" --scope "$storage_account_id"  --role "$role_name"
    az role assignment create --assignee- "$UserManagedIdentity" --scope "$storage_account_id"  --role "$role_name" 
    echo "Role assignment created. $role_name"
else
    echo "Role assignment already exists. $role_name"
fi

role_name="Storage Account Key Operator Service Role"
existing_role_assignment=$(az role assignment list --assignee "$automation_objectid"   --scope "$storage_account_id"  --query "[?roleDefinitionName=='$role_name']" --output tsv)
echo "role: $existing_role_assignment"
# Create the role assignment if it doesn't exist
if [[ -z "$existing_role_assignment" ]]; then
    az role assignment create --assignee-object-id "$automation_objectid" --scope "$storage_account_id" --role "$role_name"
    az role assignment create --assignee- "$UserManagedIdentity"  --scope "$storage_account_id" --role "$role_name"
    echo "Role assignment created. $role_name"
else
    echo "Role assignment already exists. $role_name"
fi
#logicapp
role_name="Storage Queue Data Contributor"
logicapp_id=$(az logicapp show --name "$LogicAppName" --resource-group "$ResourceGroupName"  --query "id" --output tsv) 
# Get the Storage Account resource ID
logicapp_objectid=$(az resource show --ids $logicapp_id --query 'identity.principalId' --output tsv)

storage_account_id=$(az storage account show --name "$StorageAccountName" --resource-group "$ResourceGroupName"  --query "id" --output tsv)

# Check if the role assignment already exists
existing_role_assignment=$(az role assignment list --assignee "$logicapp_objectid" --scope "$storage_account_id"  --query "[?roleDefinitionName=='$role_name']"  --output tsv)

# Create the role assignment if it doesn't exist
if [[ -z "$existing_role_assignment" ]]; then
    az role assignment create --assignee-object-id  "$logicapp_objectid" --scope "$storage_account_id" --role "$role_name"
    echo "Role assignment created. $role_name"
else
    echo "Role assignment already exists. $role_name"
fi
