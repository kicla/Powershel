$ErrorActionPreference = "SilentlyContinue"
add-pssnapin Citrix*

 
    #   
    #      .SYNOPSIS   
    #          Finds all sessions of a user 
    #        .DESCRIPTION 
    #          Finds all sessions of a user within the current Citrix farm,  
    #        where the user name contains a part of the string you passed  
    #         to the -AccountName parameter 
    # 
    #         Requires Citrix.XenApp.Commands PSSnapIn 
    #      .NOTES   
    #         File Name: Find-XASessions.ps1   
    #         Author:    Axel Kara, axel.kara@gmx.de   
    #      .EXAMPLE   
    #          Find-XASessions -AccountName "m" 
    #   
        
        #Here you can change the properties that should be returned 
        $Properties = 'AccountName','ServerName','SessionId','SessionName','State','ClientName' 
     
        #Query and filter all sessions 
        Get-XASession | Select-Object -Property $Properties | Where-Object {$_.AccountName.ToUpper().Contains($BrukerNavn.ToUpper())} | Format-Table 
     
   