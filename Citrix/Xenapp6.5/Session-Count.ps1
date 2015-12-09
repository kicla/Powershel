#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.1.35
# Created on:   12.01.2015 14:27
# Created by:   Kim Clausen
# Organization: Keystep
# Filename: Log_SessionCount.ps1
#========================================================================
$ErrorActionPreference = "SilentlyContinue"
add-pssnapin Citrix*
param ([string]$Out_Data = "c:\scripts\data")

#Sjekk om kataloger finnes.
#########################
if (-not (Test-Path $Out_data))
{
  Write-Host "Error :`"$Out_data`" does not exist." -ForegroundColor 'Red'
	Write-Host "Making data catalog :"$Out_Data
	New-Item -ItemType Directory -Force -Path $Out_Data
	
}


$sessionsActive =  Get-XASession |Sort-Object ServerName| Where-Object { $_.BrowserName -match $app -and $_.Protocol -match 'Ica'-and $_.State -match 'Active' } | ft -AutoSize -Property ServerName,Accountname,state,protocol

$a = Get-Date -Format "HH:mm:ss"
$b = Get-Date -Format "ddMMyyyy"
$FileName = $Out_Data +'\' + $b + ".txt"

$Header = "Time,Ica"
$out_String = $a + "," + $sessionsActive.count


If (Test-Path $FileName){
	out-file -FilePath $FileName -Append -InputObject $out_String
}Else{
  out-file -FilePath $FileName -Append -InputObject $Header
  out-file -FilePath $FileName -Append -InputObject $out_String	
}


