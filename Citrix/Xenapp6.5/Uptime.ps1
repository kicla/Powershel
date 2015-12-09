Get-XAServer |Sort-Object ServerName| % {

	$server = $_.ServerName
	If (!(Test-Connection -ComputerName $server -BufferSize 16 -Count 1 -ea 0 -quiet))
		{
			Write-Host $server “  Server down“ -foregroundcolor red
		}
	Else
		{
			#Må legge inn en sjekk om RPC er tilgjengelig.
			$wmi=Get-WmiObject -class Win32_OperatingSystem -computer $server
			$LBTime=$wmi.ConvertToDateTime($wmi.Lastbootuptime)
			[TimeSpan]$uptime=New-TimeSpan $LBTime $(get-date)
			Write-host $server “Uptime: ” $uptime.days“:”$uptime.hours“:”$uptime.minutes -foregroundcolor Yellow
		}	
	 
}