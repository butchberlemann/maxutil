#Funcation to Check for RMI server
Function global:CheckJMSResources()
{
   Try
   {
   
   $RESOURCESXML = "C:\IBM\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\resources.xml"
   [xml]$WASRESOURCESXML = Get-Content  $RESOURCESXML
  
   OutLogScreen "INFO" "Checking JMS Resources" "$LOGFILE"
   
   $JDBCDRIVERNAME =  $WASRESOURCESXML.XMI.JDBCProvider[1].name
   if ($JDBCDRIVERNAME -eq "Oracle JDBC Driver (XA)"){
     OutLogScreen "INFO" "Oracle JDBC Driver (XA) Checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" " Oracle JDBC Driver (XA) Check" "$LOGFILE"
   }
   
    
   $JDBCFACTORYNAME =  $WASRESOURCESXML.XMI.JDBCProvider[1].factories[0].name
   
   if ($JDBCFACTORYNAME -eq "Oracle JDBC Driver XA DataSource"){
     OutLogScreen "INFO" "Oracle JDBC Driver XA DataSource Checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" " Oracle JDBC Driver XA DataSource Check" "$LOGFILE"
   }

   $JDBCJNDINAME =  $WASRESOURCESXML.XMI.JDBCProvider[1].factories[0].jndiName
   
   if ($JDBCJNDINAME -eq "jdbc/oraclexadsui"){
     OutLogScreen "INFO" "jdbc/oraclexadsui Checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" " jdbc/oraclexadsui Check" "$LOGFILE"
   }

   $JDBCAUTHALIAS =  $WASRESOURCESXML.XMI.JDBCProvider[1].factories[0].authDataAlias
   
   if ($JDBCAUTHALIAS -eq "CellManager01/maxdsui"){
     OutLogScreen "INFO" "CellManager01/maxdsui Checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" " CellManager01/maxdsui Check" "$LOGFILE"
   }

   $JDBCURL = $WASRESOURCESXML.XMI.JDBCProvider[1].factories[0].propertyset.resourceproperties[14].value
   if ($JDBCURL -eq $DBURL){
     OutLogScreen "INFO" "$DBURL Checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" " $DBURL Check" "$LOGFILE"
   }

 $JDBCFACTORYNAME =  $WASRESOURCESXML.XMI.JDBCProvider[1].factories[1].name
   
   if ($JDBCFACTORYNAME -eq "Oracle JDBC Driver XA DataSource"){
     OutLogScreen "INFO" "Oracle JDBC Driver XA DataSource Checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" " Oracle JDBC Driver XA DataSource Check" "$LOGFILE"
   }

   $JDBCJNDINAME =  $WASRESOURCESXML.XMI.JDBCProvider[1].factories[1].jndiName
   
   if ($JDBCJNDINAME -eq "jdbc/oraclexadsif"){
     OutLogScreen "INFO" "jdbc/oraclexadsif Checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" " jdbc/oraclexadsif Check" "$LOGFILE"
   }

   $JDBCAUTHALIAS2 =  $WASRESOURCESXML.XMI.JDBCProvider[1].factories[1].authDataAlias
   
   if ($JDBCAUTHALIAS2 -eq "CellManager01/maxdsif"){
     OutLogScreen "INFO" "CellManager01/maxdsif Checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" " CellManager01/maxdsif Check" "$LOGFILE"
   }

   $JDBCURL = $WASRESOURCESXML.XMI.JDBCProvider[1].factories[1].propertyset.resourceproperties[14].value
   if ($JDBCURL -eq $DBURL){
     OutLogScreen "INFO" "$JDBCURL Checked" "$LOGFILE"
   }else{
     OutLogScreen "FAIL" "$DBURL Failed" "$LOGFILE"
   }
   
   
   $SECURITYSXML = "C:\IBM\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\security.xml"
   [xml]$WASSECURITYSXML = Get-Content  $SECURITYSXML
   
   
   for ($i=0; $i -lt 2; $i++){
   
    $IFUSERACCOUNT =  $WASSECURITYSXML.security.authDataEntries[$i].userid
    if ($IFUSERACCOUNT -eq "maxdsui"){
        OutLogScreen "INFO" "maxdsui Checked" "$LOGFILE"
    }elseif($IFUSERACCOUNT -eq "maxdsif"){
        OutLogScreen "INFO" "maxdsif Checked" "$LOGFILE"
    }else{ 
        OutLogScreen "FAIL" " $IFUSERACCOUNT Check" "$LOGFILE"
    }
   }
   
   
    $SIBUILOC = "C:\ibm\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\buses\ifjmsbus"
    if ((Test-Path $SIBUILOC)){   
        OutLogScreen "INFO" "ifjmsbus bus Found" "$LOGFILE"    
    }else{
        OutLogScreen "FAIL" "ifjmsbus bus Not Found" "$LOGFILE" 
    }  
    
    $SIBUILOC = "C:\ibm\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\buses\uijmsbus"
    if ((Test-Path $SIBUILOC)){   
        OutLogScreen "INFO" "uijmsbus bus Found" "$LOGFILE"    
    }else{
        OutLogScreen "FAIL" "uijmsbus bus Not Found" "$LOGFILE" 
    }  
   
   
   
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckJMSResources -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

#Funcation to Check for RMI server
Function global:CheckJMSQ()
{
   Try
   {
   
    $JMSDEST = @{"CQIN"="jms/maximo/int/queues/cqin";
                           "CQINERR"="jms/maximo/int/queues/cqinerr"; 
                           "SQIN"="jms/maximo/int/queues/sqin";
                           "WMCQ"="jms/maximo/int/queues/wmcq";
                           "WMERR"= "jms/maximo/int/queues/wmerr";
                           "ASSCQ"="jms/maximo/int/queues/asscq"; 
                           "ASSERR"="jms/maximo/int/queues/asserr";
                           "SQOUT"="jms/maximo/int/queues/sqout";};
                           
    $JMSACTSPEC = @{"intjmsact"="jms/maximo/int/queues/cqin";
                           "intjmsacterr"="jms/maximo/int/queues/cqinerr"; 
                           "intjmsassact"= "jms/maximo/int/queues/asscq";
                           "intjmswmact"="jms/maximo/int/queues/wmcq";};
       
   
   
   $RESOURCESXML = "C:\IBM\WebSphere\AppServer\profiles\Dmgr01\config\cells\Cell01\resources.xml"
   [xml]$WASRESOURCESXML = Get-Content  $RESOURCESXML
  
      
   OutLogScreen "INFO" "  SIB Destinations" "$LOGFILE"
   
   $JMSCOUNT = 0
   
   for ($i=0; $i -lt 8; $i++){
   
    $JMSQJNDINAME = $WASRESOURCESXML.XMI.J2CResourceAdapter[1].j2cAdminObjects[$i].jndiName
    $JMSNAME = $WASRESOURCESXML.XMI.J2CResourceAdapter[1].j2cAdminObjects[$i].name
    
    if ($JMSQJNDINAME -eq $JMSDEST.Get_Item($JMSNAME)){
        OutLogScreen "INFO" "$JMSNAME Checked" "$LOGFILE"
        $JMSCOUNT = $JMSCOUNT + 1
      }
    
   }
   
   if ( $JMSCOUNT -ne 8){
    OutLogScreen "FAIL" "All SIB Destinations were not found $JMSCOUNT of 8 found" "$LOGFILE"
   }
   
   
   OutLogScreen "INFO" "  Active Spec Destinations" "$LOGFILE"
   
   $JMSCOUNT = 0
   
   for ($i=0; $i -lt 4; $i++){
   
    $ACTSPECNAME = $WASRESOURCESXML.XMI.J2CResourceAdapter[1].j2cActivationSpec[$i].name
    $DESTJNDINAME = $WASRESOURCESXML.XMI.J2CResourceAdapter[1].j2cActivationSpec[$i].destinationJndiName
    
    if ($DESTJNDINAME -eq $JMSACTSPEC.Get_Item($ACTSPECNAME)){
        OutLogScreen "INFO" "$ACTSPECNAME Checked" "$LOGFILE"
        $JMSCOUNT = $JMSCOUNT + 1
      }
    
   }
   
   if ( $JMSCOUNT -ne 4){
    OutLogScreen "FAIL" "All Active Spec Destinations were not found $JMSCOUNT of 4 found" "$LOGFILE"
   }
   
  
   
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "CheckJMSQ -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}
