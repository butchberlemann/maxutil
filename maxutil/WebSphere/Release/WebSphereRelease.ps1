[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$SCRIPTNAME = $myinvocation.mycommand.name
$SCRIPTDIR = Split-Path -Path $myinvocation.mycommand.Definition -Parent
$BASENAME = $SCRIPTNAME.split(".")[0]
$LOGNAME = $BASENAME + "_" + $CURRENTDATETIME + ".log"
 
try{
    # Dot source Script Modules
    . ..\..\ScriptModules\Constants.ps1
    . ..\..\ScriptModules\Admin.ps1
    SetConstants "$SCRIPTDIR"
    $NOW=GetCurrentDateTime
    . ..\..\ScriptModules\Logs.ps1

    # Make a log file 
    $LOGFILE= New-Item "$WASRELEASELOGSDIR\$LOGNAME" -Type File -Force

    # Write info to the log file and to the user screen.
    OutLogScreen "INIT" "$SCRIPTNAME $NOW" "$LOGFILE"
    OutLogScreen "INFO" "The log files are in $WASRELEASELOGSDIR" "$LOGFILE"

    #$username = "wasadmin"
    #$username = [Environment]::UserName
    #$pass = <PASSWORD> #Read-Host 'What is your LDAP password?' -AsSecureString
    #$pass =  Read-Host 'What is your LDAP password?' 
 
    #-username $username  -password  $pass
    C:\ibm\WebSphere\AppServer\profiles\Dmgr01\bin\wsadmin -username wasadmin -password <PASSWORD> -lang jython -f "C:\maxutil\WebSphere\Release\UpdateAppServerLogsAllServers.py"
   # OutLogScreen "INFO" "$WASOutput" "$LOGFILE"
}
Catch
 {
   throw
 }
