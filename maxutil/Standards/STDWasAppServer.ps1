#Funcation to Check for RMI server
Function global:CheckMaximoAppServers($NODENAME, $APPSERVERNAME)
{
   Try
   {
   OutLogScreen "INFO" "$APPSERVERNAME on $NODENAME" "$LOGFILE"
   
   $SERVERXML = "C:\IBM\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\nodes\$NODENAME\servers\$APPSERVERNAME\server.xml"
  
   [xml]$WASSERVERXML = Get-Content $SERVERXML
   $GENJVMARG = $WASSERVERXML.Server.processDefinitions.jvmEntries.genericJvmArguments
   $JVMINITIALHEALSIZE= $WASSERVERXML.Server.processDefinitions.jvmEntries.initialHeapSize
   $JVMMAXHEAPSIZE= $WASSERVERXML.Server.processDefinitions.jvmEntries.maximumHeapSize
   
   
   if ($JVMINITIALHEALSIZE -eq $JVMMINHEAPSIZE){
     OutLogScreen "INFO" "JVMINITIALHEALSIZE check" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "JVMINITIALHEALSIZE is $JVMINITIALHEALSIZE should be $JVMMINHEAPSIZE" "$LOGFILE"
   }
   
   if($JVMMAXHEAPSIZE -eq $JVMMAXHEAPSIZE){
     OutLogScreen "INFO" "JVMMAXHEAPSIZE check" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "JVMINITIALHEALSIZE is $JVMMAXHEAPSIZE should be $JVMMAXHEAPSIZE" "$LOGFILE"
   }
   
   
   if ($APPSERVERNAME.Contains("DataSplice")){
    OutLogScreen "WARN" "skipping -Dmxe.name check on $APPSERVERNAME" "$LOGFILE"
   }else{
    
    if ($GENJVMARG.Contains("-Dmxe.name=${WAaS_SERVER_NAME}")){
         OutLogScreen "INFO" "-Dmxe.name prop check" "$LOGFILE"
    }else{
         OutLogScreen "FAIL" "Could not find -Dmxe.name please check $APPSERVERNAME on $NODENAME" "$LOGFILE"
    }
   }

   if ($GENJVMARG.Contains("-Dsun.rmi.dgc.ackTimeout=10000")){
     OutLogScreen "INFO" "-Dsun.rmi.dgc.ackTimeout prop check" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "Could not find -Dsun.rmi.dgc.ackTimeout=10000 please check $APPSERVERNAME on $NODENAME" "$LOGFILE"
   }
  
   if ($GENJVMARG.Contains("-Djava.net.preferIPv4Stack=true")){
     OutLogScreen "INFO" "-Djava.net.preferIPv4Stack prop check" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "Could not find -Djava.net.preferIPv4Stack please check $APPSERVERNAME on $NODENAME" "$LOGFILE"
   }
   
   $RULESPATH = "-Drm.home=\\$TRMRULESERVER\C$"
   
   if ($GENJVMARG.Contains($RULESPATH)){
     OutLogScreen "INFO" "-Drm.home prop check" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "Could not find -Drm.home please check $APPSERVERNAME on $NODENAME" "$LOGFILE"
   }
   
    $MONITORINGPOLICY = $WASSERVERXML.server.processDefinitions.monitoringPolicy.nodeRestartState
   
   if ($MONITORINGPOLICY -eq "PREVIOUS"){
     OutLogScreen "INFO" "nodeRestartState checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "nodeRestartState not PREVIOUS please check $APPSERVERNAME on $NODENAME" "$LOGFILE"
   }  
   
   CheckAppServerLogs $NODENAME $APPSERVERNAME

   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckMaximoAppServers -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

#Funcation to Check for RMI server
Function global:CheckAppServerLogs($NODENAME, $APPSERVERNAME)
{
   Try
   {
   OutLogScreen "INFO" " Logs for $APPSERVERNAME on $NODENAME" "$LOGFILE"
   
   $SERVERXML = "C:\IBM\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\nodes\$NODENAME\servers\$APPSERVERNAME\server.xml"
   [xml]$WASSERVERXML = Get-Content $SERVERXML
   $GENJVMARG = $WASSERVERXML.Server.processDefinitions.jvmEntries.genericJvmArguments
   
   
   $ROLLOVERTYPE = $WASSERVERXML.server.errorStreamRedirect.rolloverType
   
   if ($ROLLOVERTYPE -eq "TIME"){
     OutLogScreen "INFO" "errorStreamRedirect.rolloverType checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "errorStreamRedirect.rolloverType not TIME please check $APPSERVERNAME on $NODENAME" "$LOGFILE"
   }  
   
   $NUMOFBACKUPS = $WASSERVERXML.server.errorStreamRedirect.maxNumberOfBackupFiles
   
   if ($NUMOFBACKUPS -eq "30"){
     OutLogScreen "INFO" "errorStreamRedirect.maxNumberOfBackupFiles checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "errorStreamRedirect.maxNumberOfBackupFiles not 30 please check $APPSERVERNAME on $NODENAME" "$LOGFILE"
   }  
   
   $ROLLOVERTYPE = $WASSERVERXML.server.outputStreamRedirect.rolloverType
   
   if ($ROLLOVERTYPE -eq "TIME"){
     OutLogScreen "INFO" "outputStreamRedirect.rolloverType checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "outputStreamRedirect.rolloverType not TIME please check $APPSERVERNAME on $NODENAME" "$LOGFILE"
   }  
   
   $NUMOFBACKUPS = $WASSERVERXML.server.outputStreamRedirect.maxNumberOfBackupFiles
   
   if ($NUMOFBACKUPS -eq "30"){
     OutLogScreen "INFO" "outputStreamRedirect.maxNumberOfBackupFiles checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "outputStreamRedirect.maxNumberOfBackupFiles not 30 please check $APPSERVERNAME on $NODENAME" "$LOGFILE"
   }

   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckAppServerLogs -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

#Funcation to Check for RMI server
Function global:CheckForRMIServerxml()
{
   Try
   {
  
   
    $HOSTSERVER = $env:COMPUTERNAME  
    $HOSTNUMBER = "RMIREG" + $HOSTSERVER.substring($HOSTSERVER.length -2)
    $HOSTSERVER = $HOSTSERVER + "Node01"
   
   
   
   $RMIAPPSERVERPATH = "C:\ibm\WebSphere\AppServer\Profiles\Custom01\config\cells\Cell01\nodes\$HOSTSERVER\servers\$HOSTNUMBER\server.xml"
   
   [xml]$RMISERVERXML = Get-Content $RMIAPPSERVERPATH
   
   $MONITORINGPOLICY = $RMISERVERXML.server.processDefinitions.monitoringPolicy.nodeRestartState
   
   
   if ($MONITORINGPOLICY -eq "PREVIOUS"){
     OutLogScreen "INFO" "nodeRestartState checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "nodeRestartState set to $MONITORINGPOLICY check $HOSTNUMBER" "$LOGFILE"
   }   
   
    
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckForRMIServerxml -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

#Funcation to Check for RMI server
Function global:CheckCluster()
{
   Try
   {
    $CLUSTERLOC = "C:\ibm\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\clusters\Maximo_UI"
    if ((Test-Path $CLUSTERLOC)){   
        OutLogScreen "INFO" "Maximo_UI Cluster Found" "$LOGFILE"    
    }else{
        OutLogScreen "FAIL" "Maximo_UI Cluster Not Found" "$LOGFILE" 
    }  
  
    $CLUSTERLOC = "C:\ibm\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\clusters\Maximo_IF"
    if ((Test-Path $CLUSTERLOC)){   
        OutLogScreen "INFO" "Maximo_IF Cluster Found" "$LOGFILE"    
    }else{
        OutLogScreen "FAIL" "Maximo_IF Cluster Not Found" "$LOGFILE" 
    }
    
    $SIBENGIFLOC = "C:\ibm\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\clusters\Maximo_IF\sib-engines.xml"
    if ((Test-Path $SIBENGIFLOC)){   
        OutLogScreen "INFO" "if sib-engines.xml Found" "$LOGFILE"    
    }else{
        OutLogScreen "FAIL" "if sib-engines.xml Not Found" "$LOGFILE" 
    }  
    
    $SIBENGUILOC = "C:\ibm\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\clusters\Maximo_UI\sib-engines.xml"
    if ((Test-Path $SIBENGUILOC)){   
        OutLogScreen "INFO" "ui sib-engines.xml Found" "$LOGFILE"    
    }else{
        OutLogScreen "FAIL" "ui sib-engines.xml Not Found" "$LOGFILE" 
    }
    
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckCluster -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}
