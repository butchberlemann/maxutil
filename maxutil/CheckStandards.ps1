# C:\Windows\system32\WindowsPowerShell\v1.0\PowerShell.exe
#***************************************************************************************
#  Description:  
#
#  Inputs:       
#                      
#  Syntax:        
#  Outputs:      
#
#  Author:       Butch Berlemann
#**********************************************************************************
Param(
      [Parameter(Position = 0, Mandatory = $true, HelpMessage="env ? DEV, TST, QA, PRD, PTCH, LOC")]
      [string]
      [alias("env")]
      [ValidateCount(0,4)]
      $ADMINSERVERENV
)

[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$SCRIPTNAME = $myinvocation.mycommand.name
$SCRIPTDIR = Split-Path -Path $myinvocation.mycommand.Definition -Parent
$BASENAME = $SCRIPTNAME.split(".")[0]
 

# Dot source Script Modules
.\ScriptModules\Constants.ps1
.\ScriptModules\Admin.ps1
.\Standards\STDWinServer.ps1
.\Standards\STDWasAppServer.ps1
.\Standards\STDJMS.ps1
.\Standards\STDWebServers.ps1
.\Standards\STDDataSplice.ps1
SetConstants "$SCRIPTDIR"


#Funcation to Check for RMI server
Function CheckAllAppServerConfig()
{
   Try
   {
   [xml]$WASNODEGROUPXML = Get-Content "C:\IBM\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\nodegroups\DefaultNodeGroup\nodegroup.xml"

   $NODECOUNT = 0
   $NODENAME = $WASNODEGROUPXML.nodegroup.members[$NODECOUNT].nodename
   
   while ($NODENAME -ne $null){
    
    $SERVERINDEX = "C:\IBM\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\nodes\$NODENAME\serverindex.xml"
   [xml]$WASSERVERINDXXML = Get-Content  $SERVERINDEX
    
    $DATASPLICESERVER = "NONE"
    $SERVERCOUNT = 0
    $SERVERNAME =  $WASSERVERINDXXML.serverindex.serverentries[$SERVERCOUNT].serverName
    $SERVERTYPE =  $WASSERVERINDXXML.serverindex.serverentries[$SERVERCOUNT].serverType
    
   
    
    while ($SERVERNAME -ne $null){
                 
        if ( $SERVERTYPE -eq "APPLICATION_SERVER"){  
             
             if (!($SERVERNAME.Contains("RMIREG"))){
                CheckMaximoAppServers $NODENAME $SERVERNAME
             }else{
                OutLogScreen "WARN" "Skipping RMI Server $SERVERNAME run this script on $NODENAME to check RMI " "$LOGFILE"    
             }
             
     
             if($SERVERNAME.Contains("DataSplice")){
                $DATASPLICESERVER =  $SERVERNAME
                OutLogScreen "INFO" "Found $DATASPLICESERVER on $NODENAME" "$LOGFILE"
                
                $SPECIALENDPOINTCOUNT = 0 
                $ENDPOINTNAME = $WASSERVERINDXXML.serverindex.serverentries[$SERVERCOUNT].specialEndpoints[$SPECIALENDPOINTCOUNT].endPointName  
                
                while ($ENDPOINTNAME -ne $null){
                    if($ENDPOINTNAME -eq "WC_defaulthost"){
                        $PORTNUMBER = $WASSERVERINDXXML.serverindex.serverentries[$SERVERCOUNT].specialEndpoints[$SPECIALENDPOINTCOUNT].endPoint.Port
                        if ($PORTNUMBER -eq "9085"){
                            OutLogScreen "INFO" "DataSplice MXServer set to $PORTNUMBER" "$LOGFILE" 
                        }else{
                            OutLogScreen "FAIL" "$SERVERNAME on $NODENAME WC_defaulthost is set to $PORTNUMBER" "$LOGFILE" 
                        }
                        
                    }
                    
                    $SPECIALENDPOINTCOUNT =   $SPECIALENDPOINTCOUNT + 1 
                    $ENDPOINTNAME = $WASSERVERINDXXML.serverindex.serverentries[$SERVERCOUNT].specialEndpoints[$SPECIALENDPOINTCOUNT].endPointName
                }
             }
             
             
                    
        
        }elseif(( $SERVERTYPE -eq "NODE_AGENT")){
            OutLogScreen "INFO" "$NODENAME $SERVERNAME" "$LOGFILE" 
            CheckAppServerLogs $NODENAME "nodeagent"
            
        }
        
        $SERVERCOUNT = $SERVERCOUNT + 1
        $SERVERNAME =  $WASSERVERINDXXML.serverindex.serverentries[$SERVERCOUNT].serverName
        $SERVERTYPE =  $WASSERVERINDXXML.serverindex.serverentries[$SERVERCOUNT].serverType
    }
    
    if ($NODENAME.Contains("CellManager")){
         OutLogScreen "WARN" "Skipped DataSplice check on $NODENAME" "$LOGFILE" 
    }elseif($NODENAME.Contains("adm")) {
         OutLogScreen "WARN" "Skipped DataSplice check on $NODENAME" "$LOGFILE" 
    }else{
        if ($DATASPLICESERVER -eq "NONE"){
           OutLogScreen "FAIL" "No DataSplice server found on $NODENAME" "$LOGFILE" 
        }
    }
    
    $NODECOUNT = $NODECOUNT + 1
    $NODENAME = $WASNODEGROUPXML.nodegroup.members[$NODECOUNT].nodename
    
   }
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckNodeAgent -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}


$NOW=GetCurrentDateTime
.\ScriptModules\Logs.ps1
$LOGNAME = $BASENAME + "_" + $CURRENTDATETIME + ".log"
# Make a log file 
$LOGFILE= New-Item "$LOGSDIR\$LOGNAME" -Type File -Force
# Write info to the log file and to the user screen.
OutLogScreen "INIT" "$SCRIPTNAME $NOW" "$LOGFILE"
OutLogScreen "INFO" "The log files are in $LOGSDIR" "$LOGFILE"

Try
{
   
   #
   #OutLogScreen "INFO" "Checking Service accounts" "$LOGFILE"

$TESTINGMODE = "NO"
OutLogScreen "WARN" "Are we in test mode ... $TESTINGMODE" "$LOGFILE"

if ($TESTINGMODE -eq "NO"){   
   
   CheckNodeAgentWinService
   CheckJMSOraDriver
   FireWallCheck
   
   
   if ($DMGRSERVER -eq 'Y'){

    CheckAllAppServerConfig
    CheckCluster
    CheckJMSResources
    CheckJMSQ
    CheckVirturalHosts
    CheckWebServerLogFiles 
    CheckFileSweeper
    CheckPOSEND
    CheckDataSplice
    
   }else{
    CheckForRMIServerxml
   }
}else{
    OutLogScreen "WARN" "Script in testing mode " "$LOGFILE"
    
    #CheckVirturalHosts
}
   
   $NOW=GetCurrentDateTime
   OutLogScreen "DONE" "$NOW" "$LOGFILE"
}
Catch
{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   OutLogScreen "FAIL" "Main -- $ErrorMessage $FailedItem" "$LOGFILE"
}
