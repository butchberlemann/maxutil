#Funcation that runs the purging process on web servers installs
Function global:PROPCHECK($XMLVALUE, $CONSTANTVALUE, $CHECKING)
{
   Try
   {
      
      if ($XMLVALUE -ne $CONSTANTVALUE)
      {
        OutLogScreen "FAIL" "DataSplice $CHECKING needs checking  " "$LOGFILE"
      }else {
        OutLogScreen "INFO" "DataSplice $CHECKING Checked " "$LOGFILE"
      }
   
   }
   Catch
   {
      $ErrorMessage = $_.Exception.Message
      $FailedItem = $_.Exception.ItemName
      OutLogScreen "FAIL" "PROPCHECK -- $ErrorMessage $FailedItem" "$LOGFILE"
   }
}

Function global:CheckDataSplice($XMLVALUE, $CONSTANTVALUE)
{
    Try
    {
        #Get the plugin xml from DataSplice plugin xml
        [xml]$DSMAXIMOPLUGIN = Get-Content $DSPROPS.Get_Item("maximopluginxml")
   
        #Get the mx server listed in the DatsSplice plugin xml
        $MAXIMOSERVER = $DSMAXIMOPLUGIN.DataSpliceOptionsDocument.StorageObject.OptionCollection.Options.List.ListEntry[$DSPROPS.Get_Item("maximoserverxmlnode")].ConfigurationOption.Value     
        PROPCHECK $MAXIMOSERVER.InnerXml $DSPROPS.Get_Item("maximoserver") "maximoserver"
   
        #Get the service account listed in the DatsSplice plugin xml
        $MAXIMOSA = $DSMAXIMOPLUGIN.DataSpliceOptionsDocument.StorageObject.OptionCollection.Options.List.ListEntry[$DSPROPS.Get_Item("maximosaxmlnode")].ConfigurationOption.Value
        PROPCHECK $MAXIMOSA.InnerXml     $DSPROPS.Get_Item("maximosa") "maximosa"
   
        #Get the path to the token listed in the DatsSplice plugin xml
        $MAXIMOTOKEN = $DSMAXIMOPLUGIN.DataSpliceOptionsDocument.StorageObject.OptionCollection.Options.List.ListEntry[$DSPROPS.Get_Item("maximotokenxmlnode")].ConfigurationOption.Value
        PROPCHECK $MAXIMOTOKEN.InnerXml  $DSPROPS.Get_Item("maximotoken") "maximotoken"
   
        #Get the path to the java class listed in the DatsSplice plugin xml
        $MAXIMOJAVACLASS = $DSMAXIMOPLUGIN.DataSpliceOptionsDocument.StorageObject.OptionCollection.Options.List.ListEntry[$DSPROPS.Get_Item("maximojavaclassxmlnode")].ConfigurationOption.Value
        PROPCHECK $MAXIMOJAVACLASS.InnerXml $DSPROPS.Get_Item("maximojavaclass") "maximojavaclass"
   
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        OutLogScreen "FAIL" "Main -- $ErrorMessage $FailedItem" "$LOGFILE"
    }
}
