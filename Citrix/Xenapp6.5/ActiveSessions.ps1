$ErrorActionPreference = "SilentlyContinue"
add-pssnapin Citrix*

param ([String]$app)
foreach ($session in (Get-XASession | Where-Object { 
$_.BrowserName -match $app -and $_.State -match 'Active'} | 
select AccountName, ServerName, LogonTime, ConnectTime, CurrentTime, SessionID | 
Sort-Object LogonTime -Descending))
{
 $logon = (Get-Date) - $session.LogOnTime
 $connect = (Get-Date) - $session.ConnectTime
 "$($session.AccountName) logged on to $($session.ServerName) {0:00}:{1:00}:{2:00}" 
 
}