
role_name="Storage Queue Data Contributor"
# Get the Automation Account resource ID
automation_account_id=$(az automation account show --name "$AutomationAccountName" --resource-group "$ResourceGroupName" --query "id" --output tsv)

# Get the Storage Account resource ID
storage_account_id=$(az storage account show --name "$StorageAccountName" --resource-group "$ResourceGroupName" --query "id" --output tsv)

# Check if the role assignment already exists
existing_role_assignment=$(az role assignment list --assignee "$AutomationAccountName" --resource-group "$ResourceGroupName" --scope "$storage_account_id" --output tsv)
echo "role: $existing_role_assignment"
# Create the role assignment if it doesn't exist
if [[ -z "$existing_role_assignment" ]]; then
    az role assignment create --assignee "$AutomationAccountName" --scope "$storage_account_id"  --role "$role_name"
    echo "Role assignment created. $role_name"
else
    echo "Role assignment already exists. $role_name"
fi

role_name="Storage Account Key Operator Service Role"
existing_role_assignment=$(az role assignment list --assignee "$AutomationAccountName"  --scope "$storage_account_id" --resource-group "$ResourceGroupName" --output tsv)
echo "role: $existing_role_assignment"
# Create the role assignment if it doesn't exist
if [[ -z "$existing_role_assignment" ]]; then
    az role assignment create --assignee "$AutomationAccountName" --scope "$storage_account_id" --role "$role_name"
    echo "Role assignment created. $role_name"
else
    echo "Role assignment already exists. $role_name"
fi
#logicapp
role_name="Storage Queue Data Contributor"
logicapp_id=$(az logicapp show --name "$LogicAppName" --resource-group "$ResourceGroupName"  --query "id" --output tsv) 
# Get the Storage Account resource ID
storage_account_id=$(az storage account show --name "$StorageAccountName" --resource-group "$ResourceGroupName"  --query "id" --output tsv)

# Check if the role assignment already exists
existing_role_assignment=$(az role assignment list --assignee "$LogicAppName" --scope "$storage_account_id" --resource-group "$ResourceGroupName"  --output tsv)

# Create the role assignment if it doesn't exist
if [[ -z "$existing_role_assignment" ]]; then
    az role assignment create --assignee  "$LogicAppName" --scope "$storage_account_id" --role "$role_name"
    echo "Role assignment created. $role_name"
else
    echo "Role assignment already exists. $role_name"
fi
