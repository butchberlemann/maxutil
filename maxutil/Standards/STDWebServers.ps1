
   
   #Funcation to Check the Node Agent Service Account 
Function global:CheckVirturalHosts()
{
   Try
   {
   $VIRTUALHOSTS = "C:\IBM\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\virtualhosts.xml"
   [xml]$VIRTUALHOSTSXML = Get-Content  $VIRTUALHOSTS
   
   $VIRTURALHOSTS = $VIRTUALHOSTSXML.xmi.virtualhost
      
   $TEST = 0 
   foreach ($VIRTURALHOST in $VIRTURALHOSTS ){
     
     if ($VIRTURALHOST.name -eq "maximo_ui"){
         $TEST = $TEST + 1
         OutLogScreen "INFO" "found maximo_ui VH" "$LOGFILE"
     }elseif ($VIRTURALHOST.name -eq "maximo_if"){
        $TEST = $TEST + 1
        OutLogScreen "INFO" "found maximo_if VH" "$LOGFILE"
     }elseif ($VIRTURALHOST.name -eq "maximo_ds"){
        $TEST = $TEST + 1
        OutLogScreen "INFO" "found maximo_ds VH" "$LOGFILE"
        $PORTNUM = $VIRTURALHOST.aliases.port
        if ($PORTNUM -eq "9085"){
            OutLogScreen "INFO" "Datasplice port is correct" "$LOGFILE"
        }else{
           OutLogScreen "FAIL" "VIRTURAL HOST port num $PORTNUM on maximo_ds is not correct" "$LOGFILE"
        }
        
     } 
   }
   
   if ($TEST -ne 3){
    OutLogScreen "FAIL" "All Virtural Hosts not found" "$LOGFILE"
   }
        
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckNodeAgentWinService -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

   #Funcation to Check the Node Agent Service Account 
Function global:CheckWebServerLogFiles()
{
   Try
   {
    foreach ($WEBSERVER in $WEBSERVERS)
    {
   
        #if (Test-Connection -ComputerName $WEBSERVER -Count 1){
             
             $WEBSERVERCONF = "\\"  + $WEBSERVER + "\C$\ibm\HTTPServer\conf\httpd.conf"      
         
             $ACCESSLOGCMD = "C:/IBM/HTTPServer/bin/rotatelogs.exe -l C:/IBM/HTTPServer/logs/access-%a-%m-%d-%Y.log 86400"
             $ERRORLOGCMD = "C:/IBM/HTTPServer/bin/rotatelogs.exe -l C:/IBM/HTTPServer/logs/error-%a-%m-%d-%Y.log 86400"
             
             $ACCEPTDIASBLED = "# Win32DisableAcceptEx"

         
            if (Get-Content $WEBSERVERCONF | Select-String $ACCESSLOGCMD -quiet) {
                OutLogScreen "INFO" "Access Log Handling found" "$LOGFILE"    
             }else{
                OutLogScreen "FAIL" "Access Log Handling NOT found on $WEBSERVER" "$LOGFILE"    
            }
         
            if (Get-Content $WEBSERVERCONF | Select-String $ERRORLOGCMD -quiet) {
                OutLogScreen "INFO" "Error Log Handling found on $WEBSERVER" "$LOGFILE"    
            }else{
                OutLogScreen "FAIL" "Error Log Handling NOT found on $WEBSERVER" "$LOGFILE"    
            }
            
            if (Get-Content $WEBSERVERCONF | Select-String $ACCEPTDIASBLED -quiet) {
                OutLogScreen "FAIL" "Win32DisableAcceptEx not disabled on $WEBSERVER" "$LOGFILE"    
            }else{
                OutLogScreen "INFO" "Win32DisableAcceptEx disabled on $WEBSERVER" "$LOGFILE"    
            }
         
       # }else {
       #     OutLogScreen "FAIL" "Could Not Find $WEBSERVER Moving on..." "$LOGFILE" 
     #   }
    }
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckNodeAgentWinService -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}
