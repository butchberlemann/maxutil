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

[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$SCRIPTNAME = $myinvocation.mycommand.name
$SCRIPTDIR = Split-Path -Path $myinvocation.mycommand.Definition -Parent
$BASENAME = $SCRIPTNAME.split(".")[0]
 

# Dot source Script Modules
.\ScriptModules\Constants.ps1
.\ScriptModules\Admin.ps1
SetConstants "$SCRIPTDIR"

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
   OutLogScreen "INFO" "Backing up all WAS Profiles" "$LOGFILE"
   
   $WASPROFILE = C:\ibm\WebSphere\AppServer\bin\manageprofiles.bat -listProfiles
   $WASPROFILE = $WASPROFILE.trimstart("[")
   $WASPROFILE = $WASPROFILE.trimend("]")
   $WASPROFILE = $WASPROFILE.replace(' ','')
   $PROFILES = $WASPROFILE.split(",")      
   
   #REMOVE BEFORE FLIGHT
   #$PROFILES = "AppSrv01"
 
   foreach ($PROFILE in $PROFILES){
    OutLogScreen "INFO" "Backing up $PROFILE" "$LOGFILE"
    $WASBackup = C:\ibm\WebSphere\AppServer\bin\manageprofiles.bat -backupProfile -profileName $PROFILE -backupFile $WASPROFILEBACKUPLOC\$PROFILE.zip
    
    
    if (!($WASBackup.ToString().StartsWith("INSTCONFSUCCESS"))){
    
        OutLogScreen "FAIL" "$WASBackup" "$LOGFILE"
    }else {
         OutLogScreen "INFO" "$PROFILE Backed up at $WASPROFILEBACKUPLOC" "$LOGFILE" 
    } 
    
    
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

