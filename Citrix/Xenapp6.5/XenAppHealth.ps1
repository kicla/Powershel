############################################################################
##                                                                        ##
##  SCRIPT.........:  XenAppHealth.ps1                                    ##
##  AUTHOR.........:  Phil Eddies                                         ##
##  LINK...........:  http://www.geekshangout.com/content/citrix-xenapp-health-monitor                                      ##
##  VERSION........:  1.0                                                 ##
##  DATE...........:  10/04/2013                                          ##
##  DESCRIPTION....:  This script collects Server Inofrmation and         ##
##                    displays the results on the screen.                 ##
##                                                                        ##
##                                                                        ##
############################################################################

#-----------------------------------------------------------------------------------
#DEFINE
#-----------------------------------------------------------------------------------
Add-PSSnapin "Citrix.XenApp.Commands"

[int]$Global:REFRESHINTERVAL = "5" # Define the refresh interval (in seconds) for processing
$Global:EXCLUDESERVERS = "" #Define which Citrix servers should be excluded from processing. Comma seperated list, short names only, case insensitive (for example "CORPCTX01,CORPCTX02,CORPCTX05")
$ServerDesktopName = "" #Define the name of you main server desktop if you have one or leave blank, only one server desktop is allowed

$CheckAdditionalServers = $false #If set to $true in addition to monitoring Citrix Servers the Script will also monitor CPU and RAM on servers listed in EXTRASERVERS
$Global:EXTRASERVERS = "Server1,Server2" #Define a list of additional non Citrix windows server to monitor RAM and CPU 

$infiniteLoop = $true #DO NOT CHANGE Create an infinite loop variable

#-----------------------------------------------------------------------------------
#SETUP THE WINDOW
#-----------------------------------------------------------------------------------
Clear-Host #Clear the screen
$a = (Get-Host).UI.RawUI
$a.BackgroundColor = "blue"
$a.ForegroundColor = "white"
$a.WindowTitle = "XenApp Health 1.0"
$a.WindowTitle

$b = $a.WindowSize
$b.Height = 35
$a.WindowSize = $b

$HostInfo = @() #Reset the array
$ExtraHostInfo = @() #Reset the array
$UsersLoggedOn = 0
$firstLoop = $true

#-----------------------------------------------------------------------------------
#FUNCTIONS
#-----------------------------------------------------------------------------------
function ServerOnline {
	$server = "$args" # Create a variable named server from the first passed variable
	$serverload = @(get-xaserverload | Where {$_.ServerName -eq $server}) # Create a query to validate the server is online before proceeding
	foreach ($result in $serverload){
		return $true
	}
}

function inServerDesktop {
    $server = "$args"
    
    $serverdesktop_servers = @(Get-XAServer -BrowserName $ServerDesktopName | select ServerName | Where {$_.ServerName -eq $server})
    
	foreach ($result in $serverdesktop_servers){
		return $true
	}    
}

function clearLineMarker {
     foreach ($result1 in $HostInfo){
        $result1.L = "  "
	}   
    
    foreach ($result2 in $ExtraHostInfo){
        $result2.L = "  "
	}                 

}

#-----------------------------------------------------------------------------------
#MAIN LOOP
#-----------------------------------------------------------------------------------
$excludedservers = $GLOBAL:EXCLUDESERVERS.Split(',')
$extra_servers = $GLOBAL:EXTRASERVERS.Split(',')

do { # Create an infinite loop

    $farmservers = get-xaserver | sort-object -property ServerName # Create an array with all servers sorted alphabetically

    $UsersLoggedOn = 0
    $sessions_farm = @(get-xasession | Where {$_.State -ne "Listening"} | Where {$_.State -ne "Disconnected"} | Where {$_.SessionName -ne "Console"} | group AccountName) # Create a query against server passed through as first variable where protocol is Ica. Disregard disconnected or listening sessions
	foreach ($session_farm in $sessions_farm) {$UsersLoggedOn+=1} # Count number of sessions, if there are any active sessions, go to sleep for 5 minutes
	{}
    
    $server = ""

	foreach ($farmserver in $farmservers){
        #Get the current server name
		$server = $farmserver.ServerName
        $serverLogOnMode = $farmserver.LogOnMode
        
		if ($excludedservers -notcontains $server) {
            if (ServerOnline $server) {
    			#
    			# Get Uptime
    			#
    			$os = gwmi Win32_OperatingSystem -computerName $server
    			$lastbootuptime = $os.ConvertToDateTime($os.LastBootUpTime)
    			$starttime = $OS.converttodatetime($OS.LastBootUpTime)
    			$uptime = New-TimeSpan (get-date $Starttime)
    			#$uptime_string = [string]$uptime.days + " Days " + $uptime.hours + "h " + $uptime.minutes + "m " + $uptime.seconds + "s"
    			$uptime_string = [string]$uptime.days + "d " + $uptime.hours + "h "
    			
    			#
    			# Get Active Sessions
    			#
    			$session_count = 0    
                
                #Gives number of users, remove  | group AccountName to get the number of sessions instead
                $sessions = @(get-xasession | Where {$_.ServerName -eq $server} | Where {$_.State -ne "Listening"} | Where {$_.State -ne "Disconnected"} | Where {$_.SessionName -ne "Console"} | group AccountName) # Create a query against server passed through as first variable where protocol is Ica. Disregard disconnected or listening sessions
    			foreach ($session in $sessions) {$session_count+=1} # Count number of sessions, if there are any active sessions, go to sleep for 5 minutes
    			{}
    			
    			# 
    			# Get Server Load
    			#
    			
    			$server_load = get-xaserverload | Where {$_.ServerName -eq $server}
    			
    			#
    			# CPU and RAM
    			#
    			
    			$SystemInfo = Get-WmiObject -Class Win32_OperatingSystem -computername $server | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory 
     
    			 #Retrieving the total physical memory and free memory 
    			 
    			$TotalRAM = $SystemInfo.TotalVisibleMemorySize/1MB 
    			 
    			$FreeRAM = $SystemInfo.FreePhysicalMemory/1MB 
    			 
    			$UsedRAM = $TotalRAM - $FreeRAM 
    			 
    			$RAMPercentUsed = [Math]::Round(($UsedRAM / $TotalRAM) * 100 ,2)
    			 
    			#Calculating the memory used and rounding it to 2 significant figures 
    			 
    			$CPU = Get-WmiObject win32_processor -computername $server  | Measure-Object -property LoadPercentage -Average | Select Average     
    			 
    			#Get CPU load of machine 
    			 
    			$CPULoad=$CPU.average

    			# Lets throw them into an object for outputting
                clearLineMarker
                
    			$objHostInfo = New-Object System.Object
                $objHostInfo | Add-Member -MemberType NoteProperty -Name "L" -Value "->"
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "SERVER" -Value $server
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "UPTIME" -Value $uptime_string
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "USERS" -Value $session_count
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "LOAD" -Value $server_load
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "RAM%" -Value $RAMPercentUsed
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "CPU%" -Value $CPULoad
                                
                # Shorten ProhibitNewLogOnsUntilRestart to something that will display
                if ($serverLogOnMode -eq "ProhibitNewLogOnsUntilRestart")
                {
                    $objHostInfo | Add-Member -MemberType NoteProperty -Name "LOGON MODE" -Value "##OutForReboot##"
                } else {
                    $objHostInfo | Add-Member -MemberType NoteProperty -Name "LOGON MODE" -Value $serverLogOnMode
                }
				
				# Check if the Server is a member of the server desktop listed in $ServerDesktopName
				if ($ServerDesktopName -eq "")
				{
					#$ServerDesktopName is null
				} else {
					if (inServerDesktop $server)
					{
						$objHostInfo | Add-Member -MemberType NoteProperty -Name "IN DESKTOP" -Value "Yes"
					} else {
						$objHostInfo | Add-Member -MemberType NoteProperty -Name "IN DESKTOP" -Value "##No##"
					}
				}
            } else {
                # SERVER OFFLINE
                
                # Lets throw them into an object for outputting
                clearLineMarker
                
    			$objHostInfo = New-Object System.Object
                $objHostInfo | Add-Member -MemberType NoteProperty -Name "L" -Value "->"
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "SERVER" -Value $server
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "UPTIME" -Value "DOWN"
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "USERS" -Value " "
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "LOAD" -Value " "
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "RAM%" -Value " "
    			$objHostInfo | Add-Member -MemberType NoteProperty -Name "CPU%" -Value " "
                $objHostInfo | Add-Member -MemberType NoteProperty -Name "LOGON MODE" -Value " "
                $objHostInfo | Add-Member -MemberType NoteProperty -Name "IN DESKTOP" -Value " "   
            }
            

            if ($firstLoop)
            {
            
            }else{
                #Delete the server from the array first
                $HostInfo = $HostInfo  |? {$_.SERVER -ne $server}
            }

			# Lets dump our info into an array
			$HostInfo += $objHostInfo
            
            Clear-Host
            Write-Host "USERS LOGGED ON: " $UsersLoggedOn
            $HostInfo | Sort-Object SERVER | format-table -auto
            $ExtraHostInfo | Sort-Object SERVER | format-table -auto
		}	
        
        }
		
		if ($CheckAdditionalServers -eq $true) # If EXTRASERVERS is not blank
		{
			 foreach ($extraserver in $extra_servers){
				 $SystemInfo = Get-WmiObject -Class Win32_OperatingSystem -computername $extraserver | Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory 
	 
	#			 Retrieving the total physical memory and free memory 
				 
				 $TotalRAM = $SystemInfo.TotalVisibleMemorySize/1MB 
				 
				 $FreeRAM = $SystemInfo.FreePhysicalMemory/1MB 
				 
				 $UsedRAM = $TotalRAM - $FreeRAM 
				 
				 $RAMPercentUsed = [Math]::Round(($UsedRAM / $TotalRAM) * 100 ,2)
				 
	#			Calculating the memory used and rounding it to 2 significant figures 
				 
				 $CPU = Get-WmiObject win32_processor -computername $extraserver  | Measure-Object -property LoadPercentage -Average | Select Average     
				 
	#			Get CPU load of machine 
				 
			   $CPULoad=$CPU.average

	#			Lets throw them into an object for outputting
				clearLineMarker
				
				 $objExtraHostInfo = New-Object System.Object
				 $objExtraHostInfo | Add-Member -MemberType NoteProperty -Name "L" -Value "->"
				 $objExtraHostInfo | Add-Member -MemberType NoteProperty -Name "SERVER" -Value $extraserver
				 $objExtraHostInfo | Add-Member -MemberType NoteProperty -Name "RAM%" -Value $RAMPercentUsed
				 $objExtraHostInfo | Add-Member -MemberType NoteProperty -Name "CPU%" -Value $CPULoad
				
				if ($firstLoop)
				{
				
				} else {
					 #Delete the server from the array first
					 $ExtraHostInfo = $ExtraHostInfo  |? {$_.SERVER -ne $extraserver}
				 }
				
				 $ExtraHostInfo += $objExtraHostInfo
				
				 Clear-Host
				 Write-Host "USERS LOGGED ON: " $UsersLoggedOn
				 $HostInfo | Sort-Object SERVER | format-table -auto
				 $ExtraHostInfo | Sort-Object SERVER | format-table -auto
			}
		}
	
    $firstLoop = $false
	start-sleep -s ($REFRESHINTERVAL) # Sleep for REFRESHINTERVAL


	
} while ($infiniteLoop -eq $true) # Infinite loop