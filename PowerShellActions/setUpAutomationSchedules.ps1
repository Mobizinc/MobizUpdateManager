$AutomationAccountName = $env:AutomationAccountName
$ResourceGroupName = $env:ResourceGroupName

#Create Schedule
$StartTime = (Get-Date "13:00:00").AddDays(1)
New-AzAutomationSchedule -AutomationAccountName $AutomationAccountName -Name "MonitorScheduleHourly" -StartTime $StartTime -HourInterval 1 -ResourceGroupName $ResourceGroupName

$runbookName = "MonitorSchedules"
$scheduleName = "MonitorScheduleHourly"

#Associate Schedule
Register-AzAutomationScheduledRunbook -AutomationAccountName $AutomationAccountName `
-Name $runbookName -ScheduleName $scheduleName `
-ResourceGroupName $ResourceGroupName