#Funcation to Check the Node Agent Service Account 
Function global:CheckNodeAgentWinService()
{
   Try
   {
    
    
    $NODEAGENTSERVICE =  get-wmiobject Win32_service | where-object {$_.name -like '*nodeagent*'} 
    [string]$SERVICEACCOUNT = $NODEAGENTSERVICE.startname.tostring()
    [string]$SERVICESTATE = $NODEAGENTSERVICE.state.tostring()
    [string]$SERVICESTARTMODE = $NODEAGENTSERVICE.startmode.tostring()
 
    #Check that the service is running as correct service account
    if ($WASSERVICEACCOUNT -eq $SERVICEACCOUNT){
        OutLogScreen "INFO" "Service Account Checked" "$LOGFILE"
    }else {
        OutLogScreen "FAIL" "Wrong Service account $WASSERVICEACCOUNT is not $SERVICEACCOUNT" "$LOGFILE"
    } 
    #check that the service is running
    if ($SERVICESTATE -eq "Running"){
        OutLogScreen "INFO" "Service Running" "$LOGFILE"
    }else {
        OutLogScreen "Warn" "Node Agent Win Service is not running please check" "$LOGFILE"
    } 
    #Check that the service is set to auto run. 
    if ($SERVICESTARTMODE -eq "Auto"){
        OutLogScreen "INFO" "Service set to Auto Start" "$LOGFILE"
    }else {
        OutLogScreen "FAIL" "Node Agent not set to auto start please check" "$LOGFILE"
    } 
        
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckNodeAgentWinService -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

Function global:CheckJMSOraDriver()
{
   Try
   {
   
    if (Test-Path ("C:\ibm\WebSphere\AppServer\lib\ojdbc5.jar")){
        OutLogScreen "INFO" "ojdbc5.jar Checked" "$LOGFILE"
    }else{
        OutLogScreen "FAIL" "ojdbc5.jar Check" "$LOGFILE"
    }
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckJMSOraDriver -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

 #Funcation to Check the Node Agent Service Account 
Function global:CheckFileSweeper()
{
   Try
   {
        $YESTERDAY =  ((Get-Date).AddDays(-1)).ToString("yyyyMMdd") + "_"
        $SEARCHDIR = $LOGSDIR + "\*"        
        $FILESEARCHSTRING =  "FileSweeper_" + $YESTERDAY + "*.log"
        
        if ((Test-Path $SEARCHDIR -include $FILESEARCHSTRING )){
            OutLogScreen "INFO" "FileSweeper for yesterday found" "$LOGFILE"
        }else{
            OutLogScreen "FAIL" "FileSweeper for yesterday NOT found" "$LOGFILE"
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
Function global:CheckPOSEND
{
   Try
   {
        
        $POSENDLOG = "C:\POSEND\log\poprint_file_transfer.log"
        
        if ((Test-Path $POSENDLOG )){
            OutLogScreen "INFO" "POSEND LOG found" "$LOGFILE"
            $YESTERDAY =  ((Get-Date).AddDays(-1)).ToString("M/d/yyyy")
            $TODAY =  ((Get-Date)).ToString("M/d/yyyy")
            $POSENDLASTRUN = Get-Item $POSENDLOG | select LastWriteTime
            $POSENDLASTRUNDATE = $POSENDLASTRUN.LastWriteTime.ToString("M/d/yyyy")
            
            if (($POSENDLASTRUNDATE -eq $YESTERDAY) -or ($POSENDLASTRUNDATE -eq $TODAY) ){
                OutLogScreen "INFO" "POSEND Running" "$LOGFILE"
            }else{
                OutLogScreen "FAIL" "POSEND last run $POSENDLASTRUNDATE" "$LOGFILE"    
            }
            
                    
        }else{
            OutLogScreen "FAIL" "POSEND LOG Not Found" "$LOGFILE"
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
Function global:FireWallCheck
{
   Try
   {
        
    $FIREWALLSETTINGS = netsh advfirewall show allprofiles
    $ARRAYVALUEFORFIREWALLS = "State                                 OFF"
        
    if ($FIREWALLSETTINGS -contains $ARRAYVALUEFORFIREWALLS){
         OutLogScreen "INFO" "FireWalls are turned off" "$LOGFILE"            
    }else{
         OutLogScreen "FAIL" "Check FireWalls" "$LOGFILE"
         #Run the following to turn all firewalls off.
         #netsh advfirewall set allprofiles state off
    }
    
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckNodeAgentWinService -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

 
