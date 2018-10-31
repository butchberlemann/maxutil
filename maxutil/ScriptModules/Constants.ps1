Function global:GetCurrentDateTime
{
  Get-Date -uformat %Y%m%d_%H:%M:%S
}

Function global:GetFileCurrentDateTime
{
  Get-Date -uformat %Y%m%d_%H%M%S
}

Function global:SetConstants
{
  $global:CURRENTDATETIME = GetFileCurrentDateTime
  $global:LOGSDIR = "c:\MaxUtil\Logs"
  
  
  # Root directories
  $global:MAXROOT="c:\ibm\SMP\maximo"
  $global:CLUSTERCONFIG="Y"
  $global:MIFROOT="C:\Mif\txndata"
  $global:ADMINSERVERENV="NA"
  $global:DMGRSERVER = 'N'

  # Backup directories
  $global:MAXIMODIR="maximo"
  $global:TRMDIR="RulesManager"
  $global:MAXIMOBKPDIR="c:\maxutil\ConfigBackup"
  $global:LOGSDIRBACKUP = "c:\MaxUtil\LogsBackup"
  
  #WAS 
  $global:WASPROFILEBACKUPLOC = "c:\MaxUtil\WebSphereProfileBackUps\"
  

  #MAXIMO property directories
  $global:MAXPROPDIR = $MAXROOT + "\applications\" + $MAXIMODIR + "\properties\"
  $global:MAXIMOUIWEBPROPDIR = $MAXROOT + "\applications\" + $MAXIMODIR + "\maximouiweb\webmodule\WEB-INF\"
  $global:MAXRESTWEBPROPDIR = $MAXROOT + "\applications\" + $MAXIMODIR + "\maxrestweb\webmodule\WEB-INF\"
  $global:MBOWEBPROPDIR = $MAXROOT + "\applications\" + $MAXIMODIR + "\mboweb\webmodule\WEB-INF\"
  $global:MEAWEBPROPDIR = $MAXROOT + "\applications\" + $MAXIMODIR + "\meaweb\webmodule\WEB-INF\"
  $global:MBOEJBPROPDIR = $MAXROOT + "\applications\" + $MAXIMODIR + "\mboejb\ejbmodule\META-INF\"

  #TRM property directories
  $global:TRMPROPDIR = $MAXROOT + "\applications\trm\" + $TRMDIR + "\"

  #Maximo backup of property directories
  $global:MAXPROPBKPDIR = $MAXIMOBKPDIR + "\properties\"
  $global:MAXIMOUIWEBPROPBKPDIR = $MAXIMOBKPDIR + "\maximouiweb\webmodule\WEB-INF\"
  $global:MAXRESTWEBPROPBKPDIR = $MAXIMOBKPDIR + "\maxrestweb\webmodule\WEB-INF\"
  $global:MBOWEBPROPBKPDIR = $MAXIMOBKPDIR + "\mboweb\webmodule\WEB-INF\"
  $global:MEAWEBPROPBKPDIR = $MAXIMOBKPDIR + "\meaweb\webmodule\WEB-INF\"
  $global:MBOEJBPROPBKPDIR = $MAXIMOBKPDIR + "\mboejb\ejbmodule\META-INF\"

  #TRM backup of property directories
  $global:TRMPROPBKPDIR = $MAXIMOBKPDIR + "\trm\RulesManager\"

  #Maximo property files
  $global:MAXOUIWEBPROPFILES = "web.xml"
  $global:MAXRESTWEBPROPFILES = "web.xml"
  $global:MBOWEBPROPFILES = "web.xml"
  $global:MEAWEBPROPFILES = "web.xml"

  #TRM property files
  $global:TRMLOG4JPROPFILES = "log4j.properties"
  $global:TRMRULESMANAGERPROPFILES = "RulesManager.properties"  

  If ($CLUSTERCONFIG.ToUpper() -eq "Y")
  {
    $global:MBOEJBPROPFILES = "ejb-jar.xml","ibm-ejb-jar-bnd.xmi","weblogic-ejb-jar.xml",
		"ibm-ejb-jar-bnd-mif.xmi", "ejb-jar-mif.xml", "ejb-jar-ds.xml",
		"ejb-jar-ui.xml", "ibm-ejb-jar-bnd-ds.xmi", "ibm-ejb-jar-bnd-ui.xmi"
    $global:MAXPROPFILES = "maximo-DS.properties", "webclient-DS.properties", "maximo-IF.properties", "webclient-IF.properties", "maximo-UI.properties", "webclient-UI.properties", "control-registry.xml"
    $global:BUILDEARFILE = "rm-build.bat"
  }
  ElseIf ($CLUSTERCONFIG.ToUpper() -eq "N")
  {
    $global:MBOEJBPROPFILES = "ejb-jar.xml","ibm-ejb-jar-bnd.xmi","weblogic-ejb-jar.xml"
    $global:MAXPROPFILES = "maximo.properties", "webclient.properties", "control-registry.xml"
    $global:BUILDEARFILE = "rm-buildmaximoear.cmd"
  }
  
  $HOSTBOX = $env:COMPUTERNAME  

  If ($ADMINSERVERENV.ToUpper() -eq "DEV")
  {
    If ($HOSTBOX -eq "lmsmax02")
    {
       $global:DRADMIN = '\\lmsmaxadm1.til.csu.org\c$\ibm\SMP\maximo\applications\trm\'
       $global:JVMMINHEAPSIZE = '4096'
       $global:JVMMAXHEAPSIZE = '4096'
       $global:DMGRSERVER = 'Y'
       $global:TRMRULESERVER = "maximo-adm-dev.til.csu.org"
       $global:WEBSERVERS = ("LMSMAX02.TIL.CSU.ORG","LMSMAXDEV01.TIL.CSU.ORG","LMSMAXPTCH02.TIL.CSU.ORG")
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_dev"
       $global:DBURL = "jdbc:oracle:thin:@luxdb3.til.csu.org:1521:maxdev"
       
        $global:DSPROPS = @{"maximoserver"="maximo-mxserverdsp-dev.til.csu.org:13400/MXServerDSP";
                           "maximosa"="datasplicesvcs_dev"; 
                           "maximotoken"="http://maximo-mxserverdsp-dev.til.csu.org:9085/maximo/webclient/utility/token_mx7.jsp";
                           "maximojavaclass"="C:\DataSplice4.0\Maximo7Classes;C:\DataSplice4.0\Maximo7Classes\mail.jar;C:\DataSplice4.0\Maximo7Classes\log4j-1.2.13.jar;C:\DataSplice4.0\Maximo7Classes\pleiades.jar;C:\DataSplice4.0\Maximo7Classes\trmbridge.jar";
                           "maximoserverxmlnode"= "8";
                           "maximosaxmlnode"="9"; 
                           "maximotokenxmlnode"="11";
                           "maximojavaclassxmlnode"="5";
                           "maximopluginxml"="\\datasplice-NA.til.csu.org\C$\DataSplice4.0\Server\Storage\Options\MaximoPlugin\PluginOptions.xml";};
       
    }elseIf ($HOSTBOX -eq "lmsmaxdev01"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_dev"
    }elseIf ($HOSTBOX -eq "lmsmaxptch02"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_ptch"
    }else{
     
     Throw "Not On DEV "
    }
  }
  ElseIf ($ADMINSERVERENV.ToUpper() -eq "TST")
  {
    If ($HOSTBOX -eq "LMSMAX06")
    {
       
       $global:WEBSERVERS = ("LMSMAX06.TIL.CSU.ORG")
       
    }else
    {
     
     Throw "Not On TST "
    }
    
  }
  ElseIf ($ADMINSERVERENV.ToUpper() -eq "QA")
  {
    If ($HOSTBOX -eq "LMSMAX07")
    {
       $global:JVMMINHEAPSIZE = '3072'
       $global:JVMMAXHEAPSIZE = '3072'
       $global:DMGRSERVER = 'Y'
       $global:TRMRULESERVER = "maximo-adm-qa.til.csu.org"
       $global:WEBSERVERS = ("LMSMAXQA1.CSU.ORG","LMSMAXQA2.CSU.ORG","MSPMAXDR01.CSU.ORG","MSPMAXDR02.CSU.ORG")
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_qa"
       $global:DBURL = "jdbc:oracle:thin:@uxtdb1.csu.org:1521:maxqa"
       
        $global:DSPROPS = @{"maximoserver"="maximo-mxserverdsp-qa.til.csu.org:13400/MXServerDSP";
                           "maximosa"="datasplicesvcs_qa"; 
                           "maximotoken"="http://maximo-mxserverdsp-qa.til.csu.org:9085/maximo/webclient/utility/token_mx7.jsp";
                           "maximojavaclass"="C:\DataSplice4.0\Maximo7Classes;C:\DataSplice4.0\Maximo7Classes\mail.jar;C:\DataSplice4.0\Maximo7Classes\log4j-1.2.13.jar;C:\DataSplice4.0\Maximo7Classes\pleiades.jar;C:\DataSplice4.0\Maximo7Classes\trmbridge.jar";
                           "maximoserverxmlnode"= "8";
                           "maximosaxmlnode"="9"; 
                           "maximotokenxmlnode"="11";
                           "maximojavaclassxmlnode"="5";
                           "maximopluginxml"="\\datasplice-qa.csu.org\C$\DataSplice4.0\Server\Storage\Options\MaximoPlugin\PluginOptions.xml";};
       
    }elseIf ($HOSTBOX -eq "LMSMAX02"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_ptch"
    }elseIf ($HOSTBOX -eq "LMSMAX01"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_ptch"
    }elseIf ($HOSTBOX -eq "MSPMAXDR01"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_ptch"
    }elseIf ($HOSTBOX -eq "MSPMAXDR02"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_ptch"
    }else{
     
     Throw "Not On QA "
    }
    
  }
  ElseIf ($ADMINSERVERENV.ToUpper() -eq "PRD")
  {
    If ($HOSTBOX -eq "MSPMAXADM2")
    {
       

       

       $global:JVMMINHEAPSIZE = '4096'
       $global:JVMMAXHEAPSIZE = '4096'
       $global:DMGRSERVER = 'Y'
       $global:TRMRULESERVER = "maximo-adm-prd.csu.org"
       $global:WEBSERVERS = ("MSPMAX02.CSU.ORG","MSPMAX04.CSU.ORG","MSPMAX06.CSU.ORG","MSPMAX03.CSU.ORG","MSPMAX07.CSU.ORG")
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_prd"
       $global:DBURL = "jdbc:oracle:thin:@uxtdb1.csu.org:1521:maxprd"
       
        $global:DSPROPS = @{"maximoserver"="maximo-mxserverdsp-prd.csu.org:13400/MXServerDSP";
                           "maximosa"="datasplicesvcs_prd"; 
                           "maximotoken"="http://maximo-mxserverdsp-prd.csu.org:9085/maximo/webclient/utility/token_mx7.jsp";
                           "maximojavaclass"="C:\DataSplice4.0\Maximo7Classes;C:\DataSplice4.0\Maximo7Classes\mail.jar;C:\DataSplice4.0\Maximo7Classes\log4j-1.2.13.jar;C:\DataSplice4.0\Maximo7Classes\pleiades.jar;C:\DataSplice4.0\Maximo7Classes\trmbridge.jar";
                           "maximoserverxmlnode"= "8";
                           "maximosaxmlnode"="9"; 
                           "maximotokenxmlnode"="11";
                           "maximojavaclassxmlnode"="5";
                           "maximopluginxml"="\\datasplice-prd.csu.org\C$\DataSplice4.0\Server\Storage\Options\MaximoPlugin\PluginOptions.xml";};
       
    }elseIf ($HOSTBOX -eq "MSPMAX02"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_prd"
    }elseIf ($HOSTBOX -eq "MSPMAX04"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_prd"
    }elseIf ($HOSTBOX -eq "MSPMAX06"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_prd"
    }elseIf ($HOSTBOX -eq "MSPMAX03"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_prd"
    }elseIf ($HOSTBOX -eq "MSPMAX07"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_prd"
       
    }else
    {
     
     Throw "Not On PRD "
    }
    
  }
  ElseIf ($ADMINSERVERENV.ToUpper() -eq "PTCH")
  {
    If ($HOSTBOX -eq "LMSMAX03")
    {
     
       $global:JVMMINHEAPSIZE = '3072'
       $global:JVMMAXHEAPSIZE = '3072'
       $global:DMGRSERVER = 'Y'
       $global:TRMRULESERVER = "maximo-adm-ptch.til.csu.org"
       $global:WEBSERVERS = ("LMSMAX03.TIL.CSU.ORG","LMSMAXPTCH01.TIL.CSU.ORG","LMSMAXPTCH02.TIL.CSU.ORG")
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_ptch"
       $global:DBURL = "jdbc:oracle:thin:@//luxdb3.til.csu.org:1521/maxptch.world"
       
        $global:DSPROPS = @{"maximoserver"="maximo-mxserverdsp-ptch.til.csu.org:13400/MXServerDSP";
                           "maximosa"="datasplicesvcs_dev"; 
                           "maximotoken"="http://maximo-mxserverdsp-ptch.til.csu.org:9085/maximo/webclient/utility/token_mx7.jsp";
                           "maximojavaclass"="C:\DataSplice4.0\Maximo7Classes;C:\DataSplice4.0\Maximo7Classes\mail.jar;C:\DataSplice4.0\Maximo7Classes\log4j-1.2.13.jar;C:\DataSplice4.0\Maximo7Classes\pleiades.jar;C:\DataSplice4.0\Maximo7Classes\trmbridge.jar";
                           "maximoserverxmlnode"= "8";
                           "maximosaxmlnode"="9"; 
                           "maximotokenxmlnode"="11";
                           "maximojavaclassxmlnode"="5";
                           "maximopluginxml"="\\datasplice-ptch.til.csu.org\C$\DataSplice4.0\Server\Storage\Options\MaximoPlugin\PluginOptions.xml";};
       
    }elseIf ($HOSTBOX -eq "lmsmaxptch01"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_ptch"
    }elseIf ($HOSTBOX -eq "lmsmaxptch02"){
       $global:WASSERVICEACCOUNT = "csu\maximowebsphere_ptch"
    }else{
     
     Throw "Not On PTCH "
    }
    
  }
  ElseIf ($ADMINSERVERENV.ToUpper() -eq "LOC")
  {
    
    If ($HOSTBOX -eq $HOSTBOX)
    {
       $global:WEBSERVERS = ("$HOSTBOX")
       
    }else
    {
     
     Throw "Not On LOC "
    }
    
  }
}
