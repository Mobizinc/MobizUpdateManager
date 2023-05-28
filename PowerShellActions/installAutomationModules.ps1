
$AutomationAccountName = $env:AutomationAccountName
$ResourceGroupName = $env:ResourceGroupName
#Install AZTable Module
New-AzAutomationModule -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName -Name 'AzTable' -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/AzTable/2.1.0"