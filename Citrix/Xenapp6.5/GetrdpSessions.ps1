 $ErrorActionPreference = "SilentlyContinue"
 Clear-host
  add-pssnapin Citrix*

 $sessions =  Get-XASession |Sort-Object ServerName| Where-Object { $_.BrowserName -match $app -and $_.Protocol -match 'Rdp'} | ft -AutoSize -Property ServerName,Accountname,state,protocol
 $sessions
Write-Host "Antall sessioner"  $sessions.count 

