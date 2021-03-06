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

  
    
   $XCOPYRESULTS = xcopy C:\ibm\SMP\maximo\applications\trm \\mspmaxadm3.csu.org\c$\ibm\SMP\maximo\applications\trm\ /D /Y /S
   
   OutLogScreen "INFO" "$XCOPYRESULTS" "$LOGFILE"
   
   OutLogScreen "DONE" "$NOW" "$LOGFILE"
}
Catch
{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   OutLogScreen "FAIL" "Main -- $ErrorMessage $FailedItem" "$LOGFILE"
}
