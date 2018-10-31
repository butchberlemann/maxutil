Function global:OutLogScreen($LABEL,$STRING,$LOGFILE)
{
  If (($LABEL -eq 'INFO') -or ($LABEL -eq 'INIT') -or ($LABEL -eq 'DONE'))
  {
    Write-Host "$STRING ..." -ForegroundColor green
    Write-Output "$LABEL - $STRING" >> $LOGFILE
  }  
  
  If ($LABEL -eq 'WARN')
  {
    Write-Host "$STRING ..." -ForegroundColor yellow
    Write-Output "$LABEL - $STRING" >> $LOGFILE    
  }
    
  If ($LABEL -eq 'FAIL')
  {
    Write-Host "$STRING ..." -ForegroundColor red
    Write-Output "$LABEL - $STRING" >> $LOGFILE
  }  
}
