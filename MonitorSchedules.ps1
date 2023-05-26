$storageRGName=Get-AutomationVariable -Name "UpdateMgrRG"
$storageAccountName=Get-AutomationVariable -Name "UpdateMgrStorageAccount"
$scheduleMonitorQueue=Get-AutomationVariable -Name "UpdateMgrScheduleMonitorQueue"
$automationAccountName=Get-AutomationVariable -Name "UpdateMgrAutomationAccountName"

$timespan = new-timespan -hours 1 -minutes 15
$StartDate=(GET-DATE)

#Set context and get Schedules
$AzureContext = (Connect-AzAccount -Identity ).context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
$schedules=Get-AzAutomationSoftwareUpdateConfiguration -AutomationAccountName $automationAccountName  -ResourceGroupName $storageRGName


#Get Key and set Storage Context
$key = (Get-AzStorageAccountKey -ResourceGroupName $storageRGName -Name $storageAccountName)[0].Value
$updateMgrStoragecontext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key
$queue = Get-AzStorageQueue –Name $scheduleMonitorQueue –Context $updateMgrStoragecontext
