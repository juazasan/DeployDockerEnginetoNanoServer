# Installs Windows Container feature
Install-PackageProvider nuget -Force | Out-File .\installDocker.log -Append -Force
Install-PackageProvider NanoServerPackage -Force | Out-File .\installDocker.log -Append -Force
Install-NanoServerPackage -Name Microsoft-NanoServer-Containers-Package | Out-File .\installDocker.log -Append -Force

# Prepares Docker Engine to be run
copy-item .\dockerd.exe -Destination c:\windows\system32 -Force | Out-File .\installDocker.log -Append -Force
mkdir c:\programdata\docker | Out-File .\installDocker.log -Append -Force
copy-item .\runDockerDaemon.cmd -Destination C:\ProgramData\docker | Out-File .\installDocker.log -Append -Force
netsh advfirewall firewall add rule name="Docker daemon " dir=in action=allow protocol=TCP localport=2376 | Out-File .\installDocker.log -Append -Force

# Creates a scheduled task to start docker.exe at computer start up.
$dockerData = "$($env:ProgramData)\docker"
$dockerDaemonScript = "$dockerData\runDockerDaemon.cmd"
$dockerLog = "$dockerData\daemon.log"
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c $dockerDaemonScript > $dockerLog 2>&1" -WorkingDirectory $dockerData
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -Priority 5
Register-ScheduledTask -TaskName Docker -Action $action -Trigger $trigger -Settings $settings -User SYSTEM -RunLevel Highest | Out-File .\installDocker.log -Append -Force
Start-ScheduledTask -TaskName Docker | Out-File .\installDocker.log -Append -Force
shutdown /r /t 0 /f /c "Docker installed" /sync