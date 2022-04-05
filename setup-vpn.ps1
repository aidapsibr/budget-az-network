#Requires -RunAsAdministrator

Param (
  # Name of the VPN Connection
  [Parameter(Mandatory = $true)][string] $environmentName,
  [string] $region = "westus2",
  [switch] $preserveFiles
)

$vpnName = "${environmentName}-${region}"

New-Item .\temp -ItemType Directory

$url = az network vnet-gateway vpn-client generate -g "${environmentName}-${region}-hub" -n "${environmentName}-${region}-hub-gateway"
Invoke-WebRequest ($url -replace '"', "")  -OutFile ./temp/vpn.zip
Expand-Archive -LiteralPath .\temp\vpn.zip -DestinationPath .\temp\vpn -Force
[xml]$vpn = Get-Content -Path .\temp\vpn\Generic\VpnSettings.xml
$vpnProfile = $vpn.VpnProfile.VpnServer

$vpnConnection = Get-VpnConnection -Name $vpnName -ErrorAction Ignore
if ($null -ne $vpnConnection -and $vpnConnection.Length -gt 0) {
  if ($vpnConnection.ConnectionStatus -eq "Connected") {
    rasdial $vpnName /DISCONNECT;
  }
  Remove-VpnConnection -Name $vpnName -Confirm:$false
}

Add-VpnConnection -Name $vpnName -ServerAddress $vpnProfile -TunnelType Sstp -AuthenticationMethod Eap -EncryptionLevel Required -SplitTunneling -EapConfigXmlStream (New-EapConfiguration -Tls -VerifyServerIdentity -UserCertificate).EapConfigXmlStream
Add-VpnConnectionRoute -ConnectionName $vpnName -DestinationPrefix 10.0.0.0/12

$scheduledTaskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2022-04-03T08:53:59.0208464</Date>
    <Author>AIDA</Author>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <ExecutionTimeLimit>PT1M</ExecutionTimeLimit>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Application"&gt;&lt;Select Path="Application"&gt;*[System[Provider[@Name='RasClient'] and EventID=20225]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>false</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments> -command "Set-NetIPInterface $vpnName -InterfaceMetric 24"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

Unregister-ScheduledTask -TaskName "Set Routes for $vpnName" -Confirm:$false -ErrorAction Ignore

# this is a way to bump our DNS priority so resolution happens for private DNS
# with OpenVPN you can just provide suffixes, but for a budget SSTP... we have to improvise
Register-ScheduledTask -TaskName "Set Routes for $vpnName" -Xml $scheduledTaskXml -User "SYSTEM" -Force

if ($preserveFiles -ne $true) {
  Remove-Item .\temp -Recurse
}

Write-Output "VPN created!"