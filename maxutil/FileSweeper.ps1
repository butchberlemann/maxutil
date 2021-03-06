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

#Function to Backup the folder provided to the Constant var 
#$LOGSDIRBACKUP\FileSweeperBackup
Function BackUpFolder($FOLDERTOBACKUP, $FILETYPETOCOPY = ".log")
{
   Try
   {

      #Check for BackUp folder
      #MakeBackupCopy
      #look at admin MakeBackupCopy
      if (!(Test-Path "$LOGSDIRBACKUP\FileSweeperBackup")){
         #Create if Nessary
         New-Item $LOGSDIRBACKUP\FileSweeperBackup -type directory
      }
      
      $FILETYPETOCOPY = "*" + $FILETYPETOCOPY 
      OutLogScreen "INFO" "Backing Up $FILETYPETOCOPY file type from $FolderToBackUP to  $LOGSDIRBACKUP\FileSweeperBackup " "$LOGFILE"
      if ((Test-Path "$FOLDERTOBACKUP")){
         #Copy-Item -WhatIf $FolderToBackUP\*.* $LOGSDIRBACKUP\FileSweeperBackup -Include $FILETYPETOCOPY | Tee-Object -file "C:\MaxUtil\Logs\TEST"
         Copy-Item $FolderToBackUP\*.* $LOGSDIRBACKUP\FileSweeperBackup -Include $FILETYPETOCOPY   
      }else {
         OutLogScreen "FAIL" "Could Not Find $FOLDERTOBACKUP to back up Moving on..." "$LOGFILE" 
      }
      
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "BackUpFolder -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

#Funcation that first list the files in a dir and then purges the files
Function ListAndPurge($FOLDERTOLISTANDPURGE, $FILETYPETOPURGE = ".log", $AGETOPURGE = 180)
{
   Try
   {
      if ((Test-Path $FOLDERTOLISTANDPURGE)){   
         #Check for BackUp folder
         OutLogScreen "INFO" "Listing $FOLDERTOLISTANDPURGE Type $FILETYPETOPURGE Age $AGETOPURGE " "$LOGFILE"
         .\DeleteOld.ps1 -folderpath $FOLDERTOLISTANDPURGE -IncludeFileExtension $FILETYPETOPURGE -listonly -logfile "$LOGSDIR\$LOGNAME" -autolog -fileage $AgeToPurge
         #Purge
         Start-Sleep -s 1
         OutLogScreen "INFO" "Deleting $FOLDERTOLISTANDPURGE Type $FILETYPETOPURGE Age $AGETOPURGE " "$LOGFILE"
         .\DeleteOld.ps1 -folderpath $FOLDERTOLISTANDPURGE -IncludeFileExtension $FILETYPETOPURGE -logfile "$LOGSDIR\$LOGNAME" -autolog -fileage $AgeToPurge
      }else{
         OutLogScreen "FAIL" "Could Not Find $FolderToListAndPurge To List and Purge Moving on..." "$LOGFILE" 
      }
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "ListAndPurge -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

#Funcation that runs the purging process on web servers installs
Function WebServerLogClear($SERVERNAME)
{
   Try
   {
      OutLogScreen "INFO" "Cleaning the Web Server $SERVERNAME" "$LOGFILE"
      #Most of the Web Servers are remote so we check that the URL is correct 
      if (Test-Connection -ComputerName $SERVERNAME -Count 1){
         
         $WEBSERVERLOGDIR = "\\"  + $SERVERNAME + "\C$\ibm\HTTPServer\logs"      
         BackUpFolder $WEBSERVERLOGDIR
         ListAndPurge $WEBSERVERLOGDIR
      }else {
         OutLogScreen "FAIL" "Could Not Find $SERVERNAME Moving on..." "$LOGFILE" 
      }
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "WebServerLogClear -- $ErrorMessage $FailedItem" "$LOGFILE"
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

  
   
   #Clean the MaxUtil Logs first
   OutLogScreen "INFO" "Processing $LOGSDIR" "$LOGFILE"
   BackUpFolder $LOGSDIR  
   ListAndPurge $LOGSDIR
   
   #Clean the MIF Logs Next
   $XMLFILEEXT = ".xml"
   OutLogScreen "INFO" "Processing $MIFROOT" "$LOGFILE"
   BackUpFolder $MIFROOT $XMLFILEEXT
   ListAndPurge $MIFROOT $XMLFILEEXT

   OutLogScreen "INFO" "WebServer Env is $ADMINSERVERENV" "$LOGFILE"
   #Clean the WebServer Logs Next
 
   foreach ($WEBSERVER in $WEBSERVERS)
   {
    WebServerLogClear $WEBSERVER
   }
  
   #Finally clear the backup from this process
   $SWEEPERBACKUPFILES = "$LOGSDIRBACKUP\FileSweeperBackup"
   
   $DAYSTOKEEPBACKUPS = 210
   OutLogScreen "INFO" "Processing $SWEEPERBACKUPFILES" "$LOGFILE"
   ListAndPurge $SWEEPERBACKUPFILES "*" $DAYSTOKEEPBACKUPS
   
   OutLogScreen "DONE" "$NOW" "$LOGFILE"
}
Catch
{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   OutLogScreen "FAIL" "Main -- $ErrorMessage $FailedItem" "$LOGFILE"
}
