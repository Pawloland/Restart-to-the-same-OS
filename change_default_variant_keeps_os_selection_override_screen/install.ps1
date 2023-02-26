$THIS_SCRIPT_NAME = $MyInvocation.MyCommand.Name
$THIS_SCRIPT_PATH = ($MyInvocation.MyCommand.Path -split "\\$THIS_SCRIPT_NAME")[0]
function echowrap { Write-Output "[	$THIS_SCRIPT_NAME	] [	$((get-date).ToString('hh:mm:ss,ff'))	] $args" }

# first, do cleanup of previous installation (if there isn't any, it will error out, but it's ok, we don't care)
# the parameter "delegated" is used to let the uninstall script know that it's being called from this script, so it won't wait for user input at the end and will just exit
& "$THIS_SCRIPT_PATH\uninstall.bat" delegated

echowrap("++++++++++++++++++")
echowrap("Installing...")

echowrap("Detecting reboot event in logs...") 
# find every logged event where ID is 1074 (shutdown, power off, restart and maybe others), get the newest one, check shutdown type, and save unicode localized string specifying shutdown type to a variable
$event_log = Get-WinEvent -LogName system -FilterXPath "*[System[Provider[@Name='User32'] and (EventID=1074)]]" -MaxEvents 1
$restart_name_localized = (([xml]$event_log.toXml()).Event.EventData.Data | Where-Object { $_.Name -eq "param5" } ).InnerText

echowrap("Detected reboot event in logs - '$restart_name_localized'" )
echowrap("Generating XML formatted tasks..." )

# generate XML files with task definitions, because they support all the options available in GUI, and I don't want to learn how to do it properly in PS :D
$set_default_OS_xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>
        &lt;QueryList&gt;&lt;Query Id="0" Path="System"&gt;&lt;Select Path="System"&gt;
        *[System[Provider[@Name='User32'] and (EventID=1074)]]
        and 
        *[EventData[Data[@Name='param5'] and (Data='$restart_name_localized')]]
        &lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;
      </Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <LogonType>Password</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>false</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>false</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>$THIS_SCRIPT_PATH\set_default_OS.bat</Command>
     </Exec>
   </Actions>
 </Task>
"@

$revert_default_OS_xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <LogonType>Password</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>false</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>false</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>$THIS_SCRIPT_PATH\revert_default_OS.bat</Command>
    </Exec>
  </Actions>
</Task>
"@

$password = Read-Host "[	$THIS_SCRIPT_NAME	] [	$((get-date).ToString('hh:mm:ss,ff'))	] Input password for user `"$env:username`" " -AsSecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
echowrap "Adding set task..."
Register-ScheduledTask -TaskName "Save this OS as default - set" -Xml "$set_default_OS_xml" -User "$env:username" -Password "$password" | Out-Null
echowrap "Adding revert task..."
Register-ScheduledTask -TaskName "Save this OS as default - revert" -Xml $revert_default_OS_xml -User "$env:username" -Password "$password" | Out-Null
echowrap("Installing done")
echowrap("++++++++++++++++++")
Read-Host "Press enter to exit..."