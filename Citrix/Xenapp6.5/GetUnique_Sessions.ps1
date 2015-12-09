$ErrorActionPreference = "SilentlyContinue"
Clear-host
add-pssnapin Citrix*

$sessionsActive =  Get-XASession |Sort-Object AccountName -Unique| Where-Object { $_.BrowserName -match $app -and $_.Protocol -match 'Ica'-and $_.State -match 'Active' } | ft -AutoSize -Property ServerName,Accountname,state,protocol
$SessionsRDP = Get-XASession |Sort-Object AccountName -Unique| Where-Object { $_.BrowserName -match $app -and $_.Protocol -match 'Rdp'-and $_.State -match 'Active' } | ft -AutoSize -Property ServerName,Accountname,state,protocol

#$sessionsActive =  Get-XASession |Sort-Object ServerName| Where-Object { $_.BrowserName -match $app -and $_.Protocol -match 'Ica'-and $_.State -match 'Active' } | ft -AutoSize -Property ServerName,Accountname,state,protocol
$sessionsDiscon =  Get-XASession |Sort-Object ServerName| Where-Object { $_.BrowserName -match $app -and $_.Protocol -match 'Ica'-and $_.State -match 'Disconnected' } | ft -AutoSize -Property ServerName,Accountname,state,protocol
#$SessionsRDP = Get-XASession |Sort-Object ServerName| Where-Object { $_.BrowserName -match $app -and $_.Protocol -match 'Rdp'-and $_.State -match 'Active' } | ft -AutoSize -Property ServerName,Accountname,state,protocol
Write-Host "Disconnected Ica Sessioner" -fore yellow 
$sessionsDiscon 


Write-Host "Antall Unique active ICA sessioner : "  $sessionsActive.count 
Write-host "Antall disconnected Ica Sessioner : " $sessionsDiscon.Count
Write-Host "Antall Unique active RDP Sessioner : " $SessionsRDP.Count
