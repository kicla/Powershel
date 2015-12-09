#$farm = new-Object -com "MetaframeCOM.MetaframeFarm"
#$farm.Initialize(1)
#write-host "Total users on each citrix application" -fore yellow
#$farm.sessions | select UserName,AppName | group AppName | Sort Count -desc | select Count,Name | ft -auto
#$livesessions = ($farm.Sessions).count
#write-host "The number of current citrix sessions is" $livesessions -fore red
#write-host " "

#write-host "Total sessions on each citrix server" -fore yellow
#$farm.sessions | select ServerName,AppName | group ServerName | sort name | select Count,Name | ft -auto
#
#write-host " "

$ErrorActionPreference = "SilentlyContinue"
Clear-host
add-pssnapin Citrix*

write-host "Total sessions på hver citrix server" -fore yellow
Get-XASession |select Servername,Appname |group ServerName |Sort name|select count,name | ft -AutoSize

Write-Host "Total antall ICA connections : " -fore yellow
$Active = Get-XASession |Sort-Object ServerName| Where-Object { $_.BrowserName -match $app -and $_.Protocol -match 'Ica'-and $_.State -match 'Active' } | ft -AutoSize -Property ServerName,Accountname,state,protocol
$active.count
