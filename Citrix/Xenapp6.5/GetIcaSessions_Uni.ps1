#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.1.35
# Created on:   12.01.2015 14:27
# Created by:   Kim Clausen
# Organization: Keystep
# Filename: GetIcaSessions_un.ps1
#========================================================================
$ErrorActionPreference = "SilentlyContinue"
Clear-host
add-pssnapin Citrix*

$sessionsActive =  Get-XASession |Sort-Object AccountName -Unique| Where-Object { $_.BrowserName -match $app -and $_.Protocol -match 'Ica'-and $_.State -match 'Active' } | ft -AutoSize -Property ServerName,Accountname,state,protocol
$SessionsRDP = Get-XASession |Sort-Object AccountName -Unique| Where-Object { $_.BrowserName -match $app -and $_.Protocol -match 'Rdp'-and $_.State -match 'Active' } | ft -AutoSize -Property ServerName,Accountname,state,protocol

$a = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"

$out_String = $a + "," + $sessionsActive.count + "," + $SessionsRDP.count

Out-File -FilePath p:\kicla\UserCount.txt -Append -InputObject $out_String
Write-Host "Out_String :" $out_String