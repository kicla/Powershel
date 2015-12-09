$logfile = Join-Path $currentDir ("Citrix_Servers_HealthCheck.log")
$PreviuosLogFile = Join-Path $currentDir ("Citrix_Servers_HealthCheck_previuosrun.log")
$resultsHTM = Join-Path $currentDir ("Citrix_Servers_HealthCheck_Results.htm")
$AlertsEmailed = Join-Path $currentDir ("AlertsEmailed.log")
$CurrentAlerts = Join-Path $currentDir ("AlertsCurrent.log")
$AlertEmail = Join-Path $currentDir ("AlertsEmailTimeStamp.log")

Function LogMe() 
{
    Param( [parameter(Mandatory = $true, ValueFromPipeline = $true)] $logEntry,
	   [switch]$display,
	   [switch]$error,
	   [switch]$warning
	   #[switch]$progress
	   )
    if($error) { Write-Host "$logEntry" -Foregroundcolor Red; $logEntry = "[ERROR] $logEntry" }
	elseif($warning) { Write-Host "$logEntry" -Foregroundcolor Yellow; $logEntry = "[WARNING] $logEntry"}
	#elseif ($progress) { Write-Host "$logEntry" -Foregroundcolor Blue; $logEntry = "$logEntry" }
	elseif($display) { Write-Host "$logEntry" -Foregroundcolor Green; $logEntry = "$logEntry" }
    else { Write-Host "$logEntry"; $logEntry = "$logEntry" }

	$logEntry | Out-File $logFile -Append
}



Function CheckCpuUsage() 
{ 
	param ($hostname)
	Try { $CpuUsage=(get-counter -ComputerName $hostname -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 5 -ErrorAction Stop | select -ExpandProperty countersamples | select -ExpandProperty cookedvalue | Measure-Object -Average).average
    	$CpuUsage = "{0:N1}" -f $CpuUsage; return $CpuUsage
	} Catch { "Error returned while checking the CPU usage. Perfmon Counters may be at fault." | LogMe -error; return 101 } 
}



$AvgCPUval = CheckCpuUsage ("swpctx0020")
$AvgCPUval
  if( [int] $AvgCPUval -lt 80) { "CPU usage is normal [ $AvgCPUval % ]" | LogMe -display; $tests.AvgCPU = "SUCCESS", ($AvgCPUval) }
	elseif([int] $AvgCPUval -lt 90) { "CPU usage is medium [ $AvgCPUval % ]" | LogMe -warning; $tests.AvgCPU = "WARNING", ($AvgCPUval) }   	
	elseif([int] $AvgCPUval -lt 95) { "CPU usage is high [ $AvgCPUval % ]" | LogMe -error; $tests.AvgCPU = "ERROR", ($AvgCPUval) }
	elseif([int] $AvgCPUval -eq 101) { "CPU usage test failed" | LogMe -error; $tests.AvgCPU = "ERROR", "Err" }
        else { "CPU usage is Critical [ $AvgCPUval % ]" | LogMe -error; $tests.AvgCPU = "ERROR", ($AvgCPUval) }   
	$AvgCPUval = 0
