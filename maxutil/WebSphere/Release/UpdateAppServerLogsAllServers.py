# 
#***************************************************************************************
#  Description:  Script used to update all Application Servers to a log setting of 
#								 30 days of back ups and log files that span a day 
#
#  Inputs:       None 
#                      
#  Syntax:       None
#  Outputs:      The app server pre and post values for maxNumberOfBackupFiles
#								 rolloverType and rolloverPeriod. 
#
#  Author:       Butch Berlemann
#**********************************************************************************
import java.lang.System as sys
import sys
import time
import os.path
execfile('C:/maxutil/WebSphere/util/CSUJythonUtil.py')
#import java.util.Date
from time import localtime, strftime
#from datetime import datetime

#Function created to reuse the configs on the log file objects  
def SetLogs(logFileObject) :
	print '\t Pre \t' + AdminConfig.show(logFileObject , 'maxNumberOfBackupFiles' )		
	AdminControl.trace('com.ibm.websphere.management.configservice.*=all')
	#AdminControl.trace('*=all')
	AdminConfig.modify(logFileObject, [['maxNumberOfBackupFiles', 30]])
	AdminControl.trace('*=info')
	print '\t Post \t' + AdminConfig.show(logFileObject , 'maxNumberOfBackupFiles' )
	print '\n'

	print '\t Pre \t' + AdminConfig.show(logFileObject , 'rolloverType' )		
	AdminConfig.modify(logFileObject, [['rolloverType', 'TIME']])
	print '\t Post \t' + AdminConfig.show(logFileObject , 'rolloverType' )
	print '\n'
	
	print '\t Pre \t' + AdminConfig.show(logFileObject , 'rolloverPeriod' )		
	AdminConfig.modify(logFileObject, [['rolloverPeriod', 24]])
	print '\t Post \t' + AdminConfig.show(logFileObject , 'rolloverPeriod' )	
	print '\n'


try:	
	#AdminControl.trace('com.ibm.ws.management.*=all')
	#Get all of the servers			
	osuserid = os.path.getuser()
	#print "Welcome " + osuserid
	sys.stdout, "Welcome " + osuserid
	servs = AdminConfig.list('Server').split(lineSeparator)
	#Loop each server
	for server in servs:
		serverType = AdminConfig.showAttribute(server,'serverType')
		serverName = AdminConfig.showAttribute(server,'name')
		# We are only updating Application Servers
		if serverType == "APPLICATION_SERVER":
			
			print '---------------------------------------------'
			print '\n'
			print serverName + ' --- ' + serverType + ' \t ' + strftime("%H:%M:%S", localtime()) 

			outputLog = AdminConfig.showAttribute(server, 'outputStreamRedirect')
			errorLog = AdminConfig.showAttribute(server, 'errorStreamRedirect')
		
			#print 'Output log ************************************'
			#SetLogs(outputLog)
			#print  AdminConfig.show(logOutput)
			#print 'Error log ************************************'
			#SetLogs(errorLog)
			#print '---------------------------------------------'
			break
		
	print 'Saving Config...\t ' +  strftime("%H:%M:%S", localtime()) 	
	#AdminConfig.save()		
	print 'Saved !'
	SyncAllNodes()
	print 'All Nodes synced !' 	
	print 'Script Completed without errors on ' + strftime("%a, %d %b %Y %H:%M:%S ", localtime())	
except: 
		print "Exception : ( "
		exceptionDesc = sys.exc_info()
		print exceptionDesc[0] 
		print exceptionDesc[1] 
		

		
