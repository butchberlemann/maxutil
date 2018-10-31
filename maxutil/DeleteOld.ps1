<#   
.SYNOPSIS   
Script to delete or list old files in a folder
    
.DESCRIPTION 
Script to delete files older than x-days. The script is built to be used as a scheduled task, it automatically generates a logfile name based on the copy location and the current date/time. There are various levels of logging available and the script can also run in -listonly mode in which it only lists the files it would otherwise delete. There are two main routines, one to delete the files and a second routine that checks if there are any empty folders left that could be deleted.
	
.PARAMETER FolderPath 
The path that will be recusively scanned for old files.

.PARAMETER Fileage
Filter for age of file, entered in days. Use -1 for all files to be removed.
	
.PARAMETER LogFile
Specifies the full path and filename of the logfile. When the LogFile parameter is used in combination with -autolog only the path is required.

.PARAMETER AutoLog
Automatically generates filename at path specified in -logfile. If a filename is specified in the LogFile parameter and the AutoLog parameter is used only the path specified in LogFile is used. The file name is created with the following naming convention:
"Autolog_<FolderPath><dd-MM-yyyy_HHmm.ss>.log"

.PARAMETER ExcludePath
Specifies a path or multiple paths in quotes separated by commas. The Exclude parameter only accepts full paths, relative paths should not be used.

.PARAMETER IncludePath
Specifies a path or multiple paths in quotes separated by commas. The Exclude parameter only accepts full paths, relative paths should not be used. IncludePath is processed before Exclude path, using both parameter

.PARAMETER ExcludeFileExtension
Specifies an extension or multiple extensions in quotes, separated by commas. The extensions will be excluded from deletion. Asterisk can be used as a wildcard.

.PARAMETER IncludeFileExtension
Specifies an extension or multiple extensions in quotes, separated by commas. The extensions will be included in the deletion, all other extensions will implicitly be excluded. Asterisk can be used as a wildcard.

.PARAMETER ExcludeDate
If the ExcludeDate parameter is specified the query is converted by the ConvertFrom-Query function. The output of that table is a hashtable that is splatted to the ConvertTo-DateObject function which returns an array of dates. All files that match a date in the returned array will be excluded from deletion.
Query examples:
Week:
'Week,sat,-1'
Will list all saturday until the LimitYear maximum is reached
'Week,wed,5'
Will list the last 5 wednesdays

Month:
'Month,first,4'
Will list the first day of the last four months
'Month,last,-1'
Will list the last day of until the LimitYear maximum is reached. If the current date is the last day of the month the current day is also listed.
'Month,30,3'
Will list the 30th of the last three months, if february is in the results it will be ignored because it does not have 30 days.
'Month,31,-1'
Will only list the 31st of the month, all months that have less than 31 days are excluded. Will list untli the LimitYear maximum has been reached.

Quarter:
'Quarter,first,-1'
Will list the first day of a quarter until the LimitYear maximum is reached
'Quarter,last,6'
Will list the last day of the past six quarters. If the current date is the last day of the quarter the current day is also listed.
'Quarter,91,5'
Will only list the 91st day of each quarter, in non-leap years this will be the last three quarters. In leap years the first quarter also has 91 days and will therefore be included in the results
'Quarter,92,-1'
Will only list the 92nd day of each quarter, so only display the 30th of september and 31st of december. The first two quarters of a year have less days and will not be listed. Will run until limityear maximum is reached

Year:
'Year,last,4'
Will list the 31st of december for the last 4 years
'Year,first,-1'
Will list the 1st of january until the Limityear maximum has been reached
'Year,15,-1'
Will list the 15 of january until the LimitYear maximum has been reached
'Year,366,5'
Will list only the 366st day, only the last day of the last 5 leap years

Specific Date:
'Date,2010-05-15'
Will list 15th of may 2010
'Date,2012/12/12
Will list 12th of december 2012

'LimitYear,2008'
Will place the limit of LimitYear to 2008, the default is 2010.

Any combination or queries is allowed by comma-separating the queries for example. Query elements Week/Month/Quarter/Year can not be used twice when combining queries. The Date value can be used multiple times:
'Week,Fri,10','Year,last,-1','LimitYear,1950'
Will list the last 10 fridays and the 31st of december for all years until the LimitYear is reached
'Week,Thu,4','Month,last,-1','Quarter,first,6','Year,last,10','LimitYear,2012','Date,1990-12-31','Date,1995-5-31'
Will list the last four Thursdays, the last day of the month until LimitYear maximum has been reached, the first day of the first 6 quarters and the 31st of december for the last 10 years and the two specific dates 1990-12-31 & 1995-5-31.

.PARAMETER ListOnly
Only lists, does not remove or modify files. This parameter can be used to establish which files would be deleted if the script is executed.

.PARAMETER VerboseLog
Logs all delete operations to log, default behaviour of the script is to log failed only.

.PARAMETER CreateTime
Deletes files based on CreationTime, the default behaviour of the script is to delete based on lastwritetime.

.PARAMETER CleanFolders
If this switch is specified any empty folder will be removed. Default behaviour of this script is to only delete folders that contained old files.

.PARAMETER NoFolders
If this switch is specified only files will be deleted and the existing folder will be retained.

.EXAMPLE   
.\deleteold.ps1 -FolderPath H:\scripts -FileAge 100 -ListOnly -LogFile H:\log.log

Description:
Searches through the H:\scripts folder and writes a logfile containing files that were last modified 100 days ago and older.

.EXAMPLE
.\deleteold.ps1 -FolderPath H:\scripts -FileAge 30 -LogFile H:\log.log -VerboseLog

Description:
Searches through the H:\scripts folder and deletes files that were modified 30 days ago or before, writes all operations, success and failed, to a logfile on the H: drive.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\docs -FileAge 30 -LogFile H:\log.log -ExcludePath "C:\docs\finance\","C:\docs\hr\"

Description:
Searches through the C:\docs folder and deletes files, exluding the finance and hr folders in C:\docs.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\Folder -FileAge 30 -LogFile H:\log.log -IncludePath "C:\Folder\Docs\","C:\Folder\Users\" -ExcludePath "C:\docs\finance\","C:\docs\hr\"

Description:
Only check files in the C:\Folder\Docs\ and C:\Folder\Users\ Folders not any other folders in C:\Folders and explicitly exclude the Finance an HR folders in C:\Folder\Docs.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\Folder -FileAge 30 -LogFile H:\log.log -IncludePath "C:\Folder\Docs\","C:\Folder\Users\" -ExcludePath "C:\docs\finance\","C:\docs\hr\" -ExcludeDate 'Week,Fri,10','Year,last,-1','LimitYear,1950'

Description:
Only check files in the C:\Folder\Docs\ and C:\Folder\Users\ Folders not any other folders in C:\Folders and explicitly exclude the Finance an HR folders in C:\Folder\Docs. Also excludes files based on Date, excluding the last 10 fridays and the 31st of December for all years back until 1950

.EXAMPLE
PowerShell.exe deleteold.ps1 -FolderPath 'H:\admin_jaap' -FileAge 10 -LogFile C:\log -AutoLog

Description:
Launches the script from batchfile or command prompt a filename is automatically generated since the -AutoLog parameter is used. Note the quotes '' that are used for the FolderPath parameter.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\docs -FileAge 30 -logfile h:\log.log -CreationDate -NoFolder

Description:
Deletes all files that were created 30 days ago or before in the C:\docs folder. No folders are deleted.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\docs -FileAge 30 -logfile h:\log.log -CreationDate -CleanFolders

Description:
Deletes all files that were created 30 days ago or before in the C:\docs folder. Only folders that contained old files and are empty after the deletion of those files will be deleted.

.EXAMPLE
.\deleteold.ps1 -folderpath c:\users\jaapbrasser\desktop -fileage 10 -log c:\log.txt -autolog -verboselog -IncludeFileExtension '.xls*','.doc*'

Description:
Deletes files older than 10 days, only deletes files matching the .xls* and .doc* patterns eg: .doc and .docx files. Log file is stored in the root of the C-drive with an automatically generated name.

.EXAMPLE
.\deleteold.ps1 -folderpath c:\users\jaapbrasser\desktop -fileage 10 -log c:\log.txt -autolog -verboselog -ExcludeFileExtension .xls

Description:
Deletes files older than 10 days, excluding xls files. Log file is stored in the root of the C-drive with an automatically generated name.

.EXAMPLE
.\deleteold.ps1 -FolderPath C:\docs -FileAge 30 -LogFile h:\log.log -ExcludeDate 'Week,Thu,4','Month,last,-1','Quarter,first,6','Year,last,10','LimitYear,2012','Date,1990-12-31','Date,1995-5-31'

Description:
Deletes all files that were created 30 days ago or before in the C:\docs folder. With the exclusion of files last modified/created specified in the -ExcludeDate query.
#>
param(
    [string]$FolderPath,
	[string]$FileAge,
	[string]$LogFile,
    [string[]]$ExcludePath,
    [string[]]$IncludePath,
	[string[]]$ExcludeFileExtension,
    [string[]]$IncludeFileExtension,
    [string[]]$ExcludeDate,
    [switch]$ListOnly,
	[switch]$VerboseLog,
	[switch]$AutoLog,
	[switch]$CreateTime,
    [switch]$CleanFolders,
    [switch]$NoFolder
)

# Function to convert the query provided in -ExcludeDate to a format that can be parsed by the ConvertTo-DateObject function
function ConvertFrom-DateQuery {
param (
    $Query
)
    try {
        $CsvQuery = Convertfrom-Csv -InputObject $Query -Delimiter ',' -Header "Type","Day","Repeat"
        $ConvertCsvSuccess = $true
    } catch {
        Write-Warning "Query is in incorrect format, please supply query in proper format"
        $ConvertCsvSuccess = $false
    }
    if ($ConvertCsvSuccess) {
        $Check=$HashOutput = @{}
        foreach ($Entry in $CsvQuery) {
            switch ($Entry.Type) {
                'week' {
                    # Convert named dates to correct format
                    switch ($Entry.Day)
                    {
                        # DayOfWeek starts count at 0, referring to the [datetime] property DayOfWeek
                        'sun' {
                            $HashOutput.DayOfWeek = 0
                            $HashOutput.WeekRepeat = $Entry.Repeat
                        }
                        'mon' {
                            $HashOutput.DayOfWeek = 1
                            $HashOutput.WeekRepeat = $Entry.Repeat
                        }
                        'tue' {
                            $HashOutput.DayOfWeek = 2
                            $HashOutput.WeekRepeat = $Entry.Repeat
                        }
                        'wed' {
                            $HashOutput.DayOfWeek = 3
                            $HashOutput.WeekRepeat = $Entry.Repeat
                        }
                        'thu' {
                            $HashOutput.DayOfWeek = 4
                            $HashOutput.WeekRepeat = $Entry.Repeat
                        }
                        'fri' {
                            $HashOutput.DayOfWeek = 5
                            $HashOutput.WeekRepeat = $Entry.Repeat
                        }
                        'sat' {
                            $HashOutput.DayOfWeek = 6
                            $HashOutput.WeekRepeat = $Entry.Repeat
                        }
                        Default {$Check.WeekSuccess = $false}
                    }
                }
                'month' {
                    # Convert named dates to correct format
                    switch ($Entry.Day)
                    {
                        # DayOfMonth starts count at 0, referring to the last day of the month with zero
                        'first' {
                            $HashOutput.DayOfMonth = 1
                            $HashOutput.MonthRepeat = $Entry.Repeat
                        }
                        'last' {
                            $HashOutput.DayOfMonth = 0
                            $HashOutput.MonthRepeat = $Entry.Repeat
                        }
                        {(1..31) -contains $_} {
                            $HashOutput.DayOfMonth = $Entry.Day
                            $HashOutput.MonthRepeat = $Entry.Repeat
                        }
                        Default {$Check.MonthSuccess = $false}
                    }
                }
                'quarter' {
                    # Count the number of times the quarter argument is used, used in final check of values
                    $QuarterCount++

                    # Convert named dates to correct format
                    switch ($Entry.Day)
                    {
                        # DayOfMonth starts count at 0, referring to the last day of the month with zero
                        'first' {
                            $HashOutput.DayOfQuarter = 1
                            $HashOutput.QuarterRepeat = $Entry.Repeat
                        }
                        'last' {
                            $HashOutput.DayOfQuarter = 0
                            $HashOutput.QuarterRepeat = $Entry.Repeat
                        }
                        {(1..92) -contains $_} {
                            $HashOutput.DayOfQuarter = $Entry.Day
                            $HashOutput.QuarterRepeat = $Entry.Repeat
                        }
                        Default {$Check.QuarterSuccess = $false}
                    }
                }
                'year' {
                    # Convert named dates to correct format
                    switch ($Entry.Day)
                    {
                        # DayOfMonth starts count at 0, referring to the last day of the month with zero
                        'first' {
                            $HashOutput.DayOfYear = 1
                            $HashOutput.DayOfYearRepeat = $Entry.Repeat
                        }
                        'last' {
                            $HashOutput.DayOfYear = 0
                            $HashOutput.DayOfYearRepeat = $Entry.Repeat
                        }
                        {(1..366) -contains $_} {
                            $HashOutput.DayOfYear = $Entry.Day
                            $HashOutput.DayOfYearRepeat = $Entry.Repeat
                        }
                        Default {$Check.YearSuccess = $false}
                    }
                }
                'date' {
                    # Verify if the date is in the correct format
                    switch ($Entry.Day)
                    {
                        {try {[DateTime]"$($Entry.Day)"} catch{}} {
                            [array]$HashOutput.DateDay += $Entry.Day
                        }
                        Default {$Check.DateSuccess = $false}
                    }

                }
                'limityear' {
                    switch ($Entry.Day)
                    {
                        {(1000..2100) -contains $_} {
                            $HashOutput.LimitYear = $Entry.Day
                        }
                        Default {$Check.LimitYearSuccess = $false}
                    }
                }
                Default {
                    $QueryContentCorrect = $false
                }
            }
        }
        $HashOutput
    }
}

# Function that outputs an array of date objects that can be used to exclude certain files from deletion
function ConvertTo-DateObject {
param(
    [validaterange(0,6)]
    $DayOfWeek,
    [int]$WeekRepeat=1,
    [validaterange(0,31)]
    $DayOfMonth,
    [int]$MonthRepeat=1,
    [validaterange(0,92)]
    $DayOfQuarter,
    [int]$QuarterRepeat=1,
    [validaterange(0,366)]
    $DayOfYear,
    [int]$DayOfYearRepeat=1,
    $DateDay,
    [validaterange(1000,2100)]
    [int]$LimitYear = 2010
)
    # Define variable
    $CurrentDate = Get-Date

    if ($DayOfWeek -ne $null) {
        $CurrentWeekDayInt = $CurrentDate.DayOfWeek.value__

            # Loop runs for number of times specified in the WeekRepeat parameter
            for ($j = 0; $j -lt $WeekRepeat; $j++)
                { 
                    $CheckDate = $CurrentDate.Date.AddDays(-((7*$j)+$CurrentWeekDayInt-$DayOfWeek))

                    # Only display date if date is larger than current date, this is to exclude dates in the current week
                    if ($CheckDate -le $CurrentDate) {
                        $CheckDate
                    } else {
                        # Increase weekrepeat, to ensure the correct amount of repeats are executed when date returned is
                        # higher than current date
                        $WeekRepeat++
                    }
                }
            
            # Loop runs until $LimitYear parameter is exceeded
			if ($WeekRepeat -eq -1) {
                $j=0
                do {
                    $CheckDate = $CurrentDate.AddDays(-((7*$j)+$CurrentWeekDayInt-$DayOfWeek))
                    $j++

                    # Only display date if date is larger than current date, this is to exclude dates in the current week
                    if ($CheckDate -le $CurrentDate) {
                        $CheckDate
                    }
                } while ($LimitYear -le $CheckDate.Adddays(-7).Year)
            }
        }

    if ($DayOfMonth -ne $null) {
        # Loop runs for number of times specified in the MonthRepeat parameter
        for ($j = 0; $j -lt $MonthRepeat; $j++)
            { 
                $CheckDate = $CurrentDate.Date.AddMonths(-$j).AddDays($DayOfMonth-$CurrentDate.Day)

                # Only display date if date is larger than current date, this is to exclude dates ahead of the current date and
                # to list only output the possible dates. If a value of 29 or higher is specified as a DayOfMonth value
                # only possible dates are listed.
                if ($CheckDate -le $CurrentDate -and $(if ($DayOfMonth -ne 0) {$CheckDate.Day -eq $DayOfMonth} else {$true})) {
                    $CheckDate
                } else {
                    # Increase MonthRepeat integer, to ensure the correct amount of repeats are executed when date returned is
                    # higher than current date
                    $MonthRepeat++
                }
            }
            
        # Loop runs until $LimitYear parameter is exceeded
		if ($MonthRepeat -eq -1) {
            $j=0
            do {
                $CheckDate = $CurrentDate.Date.AddMonths(-$j).AddDays($DayOfMonth-$CurrentDate.Day)
                $j++

                # Only display date if date is larger than current date, this is to exclude dates ahead of the current date and
                # to list only output the possible dates. For example if a value of 29 or higher is specified as a DayOfMonth value
                # only possible dates are listed.
                if ($CheckDate -le $CurrentDate -and $(if ($DayOfMonth -ne 0) {$CheckDate.Day -eq $DayOfMonth} else {$true})) {
                    $CheckDate
                }
            } while ($LimitYear -le $CheckDate.Adddays(-31).Year)
        }
    }

    if ($DayOfQuarter -ne $null) {
        # Set quarter int to current quarter value $QuarterInt
        $QuarterInt = [int](($CurrentDate.Month+1)/3)
        $QuarterYearInt = $CurrentDate.Year
        $QuarterLoopCount = $QuarterRepeat
        $j = 0
        
        do {
            switch ($QuarterInt) {
                1 {
                    $CheckDate = ([DateTime]::ParseExact("$($QuarterYearInt)0101",'yyyyMMdd',$null)).AddDays($DayOfQuarter-1)
                    
                    # Check for number of days in the 1st quarter, this depends on leap years
                    $DaysInFeb = ([DateTime]::ParseExact("$($QuarterYearInt)0301",'yyyyMMdd',$null)).AddDays(-1).Day
                    $DaysInCurrentQuarter = 31+$DaysInFeb+31
                        
                    # If the number of days is larger that the total number of days in this quarter the quarter will be excluded
                    if ($DayOfQuarter -gt $DaysInCurrentQuarter) {
                        $CheckDate = $null
                    }

                    # This check is built-in to return the date last date of the current quarter, to ensure consistent results
                    # in case the command is executed on the last day of a quarter
                    if ($DayOfQuarter -eq 0) {
                        $CheckDate = [DateTime]::ParseExact("$($QuarterYearInt)0331",'yyyyMMdd',$null)
                    }

                    $QuarterInt = 4
                    $QuarterYearInt--
                }
                2 {
                    $CheckDate = ([DateTime]::ParseExact("$($QuarterYearInt)0401",'yyyyMMdd',$null)).AddDays($DayOfQuarter-1)
                        
                    # Check for number of days in the 2nd quarter
                    $DaysInCurrentQuarter = 30+31+30
                        
                    # If the number of days is larger that the total number of days in this quarter the quarter will be excluded
                    if ($DayOfQuarter -gt $DaysInCurrentQuarter) {
                        $CheckDate = $null
                    }

                    # This check is built-in to return the date last date of the current quarter, to ensure consistent results
                    # in case the command is executed on the last day of a quarter                       
                    if ($DayOfQuarter -eq 0) {
                        $CheckDate = [DateTime]::ParseExact("$($QuarterYearInt)0630",'yyyyMMdd',$null)
                    }
                        
                    $QuarterInt = 1
                }
                3 {
                    $CheckDate = ([DateTime]::ParseExact("$($QuarterYearInt)0701",'yyyyMMdd',$null)).AddDays($DayOfQuarter-1)
                        
                    # Check for number of days in the 3rd quarter
                    $DaysInCurrentQuarter = 31+31+30
                        
                    # If the number of days is larger that the total number of days in this quarter the quarter will be excluded
                    if ($DayOfQuarter -gt $DaysInCurrentQuarter) {
                        $CheckDate = $null
                    }
                        
                    # This check is built-in to return the date last date of the current quarter, to ensure consistent results
                    # in case the command is executed on the last day of a quarter                       
                    if ($DayOfQuarter -eq 0) {
                        $CheckDate = [DateTime]::ParseExact("$($QuarterYearInt)0930",'yyyyMMdd',$null)
                    }

                    $QuarterInt = 2
                }
                4 {
                    $CheckDate = ([DateTime]::ParseExact("$($QuarterYearInt)1001",'yyyyMMdd',$null)).AddDays($DayOfQuarter-1)
                        
                    # Check for number of days in the 4th quarter
                    $DaysInCurrentQuarter = 31+30+31
                        
                    # If the number of days is larger that the total number of days in this quarter the quarter will be excluded
                    if ($DayOfQuarter -gt $DaysInCurrentQuarter) {
                        $CheckDate = $null
                    }

                    # This check is built-in to return the date last date of the current quarter, to ensure consistent results
                    # in case the command is executed on the last day of a quarter                       
                    if ($DayOfQuarter -eq 0) {
                        $CheckDate = [DateTime]::ParseExact("$($QuarterYearInt)1231",'yyyyMMdd',$null)
                    }                        
                    $QuarterInt = 3
                }
            }

            # Only display date if date is larger than current date, and only execute check if $CheckDate is not equal to $null
            if ($CheckDate -le $CurrentDate -and $CheckDate -ne $null) {
                    
                # Only display the date if it is not further in the past than the limit year
                if ($CheckDate.Year -ge $LimitYear -and $QuarterRepeat -eq -1) {
                    $CheckDate
                }

                # If the repeat parameter is not set to -1 display results regardless of limit year                    
                if ($QuarterRepeat -ne -1) {
                    $CheckDate
                    $j++
                } else {
                    $QuarterLoopCount++
                }
            }
            # Added if statement to catch errors regarding 
        } while ($(if ($QuarterRepeat -eq -1) {$LimitYear -le $(if ($CheckDate) {$CheckDate.Year} else {9999})} 
                else {$j -lt $QuarterLoopCount}))
    }

    if ($DayOfYear -ne $null) {
        $YearLoopCount = $DayOfYearRepeat
        $YearInt = $CurrentDate.Year
        $j = 0

        # Mainloop containing the loop for selecting a day of a year
        do {
            $CheckDate = ([DateTime]::ParseExact("$($YearInt)0101",'yyyyMMdd',$null)).AddDays($DayOfYear-1)
            
            # If the last day of the year is specified, a year is added to get consistent results when the query is executed on last day of the year 
            if ($DayOfYear -eq 0) {
                $CheckDate = $CheckDate.AddYears(1)
            }
            
            # Set checkdate to null to allow for selection of last day of leap year
            if (($DayOfYear -eq 366) -and !([DateTime]::IsLeapYear($YearInt))) {
                $CheckDate = $null
            }

            # Only display date if date is larger than current date, and only execute check if $CheckDate is not equal to $null
            if ($CheckDate -le $CurrentDate -and $CheckDate -ne $null) {
                # Only display the date if it is not further in the past than the limit year
                if ($CheckDate.Year -ge $LimitYear -and $DayOfYearRepeat -eq -1) {
                    $CheckDate
                }

                # If the repeat parameter is not set to -1 display results regardless of limit year
                if ($DayOfYearRepeat -ne -1) {
                    $CheckDate
                    $j++
                } else {
                    $YearLoopCount++
                }
            }
            $YearInt--
        } while ($(if ($DayOfYearRepeat -eq -1) {$LimitYear -le $(if ($CheckDate) {$CheckDate.Year} else {9999})} 
                else {$j -lt $YearLoopCount}))
    }

    if ($DateDay -ne $null) {
        foreach ($Date in $DateDay) {
            try {
                $CheckDate = [DateTime]::ParseExact($Date,'yyyy-MM-dd',$null)
            } catch {
                try {
                    $CheckDate = [DateTime]::ParseExact($Date,'yyyy\/MM\/dd',$null)
                } catch {}
            }
            
            if ($CheckDate -le $CurrentDate) {
                $CheckDate
            }
            $CheckDate=$null
        }
    }
}

# Function that is triggered when the -autolog switch is active
function F_Autolog {
	# Gets date and reformats to be used in log filename
	$TempDate = (get-date).tostring("dd-MM-yyyy_HHmm.ss")
	# Reformats $FolderPath so it can be used in the log filename
	$TempFolderPath = $FolderPath -replace '\\','_'
	$TempFolderPath = $TempFolderPath -replace ':',''
	$TempFolderPath = $TempFolderPath -replace ' ',''
	# Checks if the logfile is either pointing at a folder or a logfile and removes
	# Any trailing backslashes
	$TestLogPath = Test-Path $LogFile -PathType Container
	if (-not $TestLogPath) {$LogFile = Split-Path $LogFile -Erroraction SilentlyContinue}
	if ($LogFile.SubString($LogFile.Length-1,1) -eq "\") {$LogFile = $LogFile.SubString(0,$LogFile.Length-1)}
	# Combines the date and the path scanned into the log filename
	$script:LogFile = "$LogFile\Autolog_$TempFolderPath$TempDate.log"
}

# Function which contains the loop in which files are deleted. If a file fails to be deleted
# an error is logged and the error message is written to the log
# $count is used to speed up the delete fileloop and will also be used for other large loops in the script
function F_Deleteoldfiles {
	$Count = $FileList.Count
	for ($j=0;$j -lt $Count;$j++) {
		$TempFile = $FileList[$j].FullName
		$TempSize = $FileList[$j].Length
		if(-not $ListOnly) {Remove-Item -LiteralPath $Tempfile -Force -ErrorAction SilentlyContinue}
		if (-not $?) {
			$TempErrorVar = "$($Error[0].tostring()) ::: $($Error[0].targetobject)"
			"`tFAILED FILE`t`t$TempErrorVar" >> $LogFile
			$script:FilesFailed++
			$script:FailedSize+=$TempSize
		}
			else {
				if (-not $ListOnly) {$script:FilesNumber++;$script:FilesSize+=$TempSize
                if ($VerboseLog) {"`tDELETED FILE`t$tempfile" >> $LogFile}}
			}
		if($ListOnly) {"`tLISTONLY`t`t$TempFile" >> $LogFile
			$script:FilesNumber++
			$script:FilesSize+=$TempSize
		}
	}
}

# Checks whether folder is empty and uses temporary variables
# Main loop goes through list of folders, only deleting the empty folders
# The if(-not $tempfolder) is the verification whether the folder is empty
function F_Checkforemptyfolder {
	$FolderList = @($FolderList | sort-object @{Expression={$_.FullName.Length}; Ascending=$false})
	$Count = $FolderList.Count
	for ($j=0;$j -lt $Count;$j++) {
		$TempFolder = get-childitem $FolderList[$j].FullName -ErrorAction SilentlyContinue
		if (-not $TempFolder) {
		$TempName = $FolderList[$j].FullName
		Remove-Item -LiteralPath $TempName -Force -Recurse -ErrorAction SilentlyContinue
			if(-not $?) {
				$TempErrorVar = "$($Error[0].tostring()) ::: $($Error[0].targetobject)"
				"`tFAILED FOLDER`t$TempErrorVar" >> $LogFile
				$script:FoldersFailed++
			} else {
				if ($VerboseLog) {"`tDELETED FOLDER`t$TempName" >> $LogFile}
				$script:FoldersNumber++
			}
		}
	}
}

# Check if correct parameters are used
if (-not $FolderPath) {Write-Warning 'Please specify the -FolderPath variable, this parameter is required. Use Get-Help .\deleteold.ps1 to display help.';exit}
if (-not $FileAge) {Write-Warning 'Please specify the -FileAge variable, this parameter is required. Use Get-Help .\deleteold.ps1 to display help.';exit}
if (-not $LogFile) {Write-Warning 'Please specify the -LogFile variable, this parameter is required. Use Get-Help .\deleteold.ps1 to display help.';exit}
if ($Autolog) {F_Autolog}

# Sets up the variables
$Startdate = Get-Date
$LastWrite = $Startdate.AddDays(-$FileAge)
$StartTime = $Startdate.toshortdatestring()+", "+$Startdate.tolongtimestring()
$Switches = "-FolderPath`r`n`t`t`t$FolderPath`r`n`t`t-FileAge $FileAge`r`n`t`t-LogFile`r`n`t`t`t$LogFile"
    # Populate the switches string with the switches and parameters that are set
    if ($IncludePath) {
	    $Switches += "`r`n`t`t-IncludePath"
	    for ($j=0;$j -lt $IncludePath.Count;$j++) {$Switches+= "`r`n`t`t`t";$Switches+= $IncludePath[$j]}
    }
    if ($ExcludePath) {
	    $Switches += "`r`n`t`t-ExcludePath"
	    for ($j=0;$j -lt $ExcludePath.Count;$j++) {$Switches+= "`r`n`t`t`t";$Switches+= $ExcludePath[$j]}
    }
    if ($IncludeFileExtension) {
	    $Switches += "`r`n`t`t-IncludeFileExtension"
	    for ($j=0;$j -lt $IncludeFileExtension.Count;$j++) {$Switches+= "`r`n`t`t`t";$Switches+= $IncludeFileExtension[$j]}
    }
    if ($ExcludeFileExtension) {
	    $Switches += "`r`n`t`t-ExcludeFileExtension"
	    for ($j=0;$j -lt $ExcludeFileExtension.Count;$j++) {$Switches+= "`r`n`t`t`t";$Switches+= $ExcludeFileExtension[$j]}
    }
    if ($ExcludeDate) {
	    $Switches+= "`r`n`t`t-ExcludeDate"
        $ExcludeDate | ConvertFrom-Csv -Header:'Item1','Item2','Item3' -ErrorAction SilentlyContinue | ForEach-Object {
            $Switches += "`r`n`t`t`t"
            $Switches += ($_.Item1,$_.Item2,$_.Item3 -join ',').Trim(',')
        }	    
    }
    if ($ListOnly) {$Switches+="`r`n`t`t-ListOnly"}
    if ($VerboseLog) {$Switches+="`r`n`t`t-VerboseLog"}
    if ($autolog) {$Switches+="`r`n`t`t-AutoLog"}
    if ($CreateTime) {$Switches+="`r`n`t`t-CreateTime"}
    if ($cleanfolders) {$Switches+="`r`n`t`t-CleanFolders"}
    if ($nofolder) {$Switches+="`r`n`t`t-NoFolder"}
[long]$FilesSize = 0
[long]$FailedSize = 0
[int]$FilesNumber = 0
[int]$FilesFailed = 0
[int]$FoldersNumber = 0
[int]$FoldersFailed = 0

# Output text to console and write log header
Write-Host ("-"*79)
Write-Host "  Deleteold`t::`tScript to delete old files from folders"
Write-Host ("-"*79)
Write-Host "`n   Started  :   $StartTime`n   Folder   :`t$FolderPath`n   Switches :`t$Switches`n"
if ($ListOnly){Write-Host "`t*** Running in Listonly mode, no files will be modified ***`n"}
Write-Host ("-"*79)
("-"*79) > $LogFile
"  Deleteold`t::`tScript to delete old files from folders" >> $LogFile
("-"*79) >> $LogFile
" " >> $LogFile
"   Started  :   $StartTime" >> $LogFile
" " >> $LogFile
"   Folder   :   $FolderPath" >> $LogFile
" " >> $LogFile
"   Switches :   $Switches" >> $LogFile
" " >> $LogFile
("-"*79) >> $LogFile
" " >> $LogFile

# Define the properties to be selected for the array, if createtime switch is specified 
# CreationTime is added to the list of properties, this is to conserve memory space
$SelectProperty = @{'Property'='Fullname','Length','PSIsContainer'}
if ($CreateTime) {
	$SelectProperty.Property += 'CreationTime'
}
else {
	$SelectProperty.Property += 'LastWriteTime'
}
if ($ExcludeFileExtension -or $IncludeFileExtension) {
    $SelectProperty.Property += 'Extension'
}

# Get the complete list of files and save to array
Write-Host "`n   Retrieving list of files and folders from: $FolderPath"
$CheckError = $Error.Count
$FullArray = @(Get-ChildItem $FolderPath -Recurse -ErrorAction SilentlyContinue -Force | select-object @SelectProperty)

# Catches errors during read stage and writes to log, mostly catches permissions errors
$CheckError = $Error.Count - $CheckError
if ($CheckError -gt 0) {
	for ($j=0;$j -lt $CheckError;$j++) {
		$TempErrorVar = "$($Error[0].tostring()) ::: $($Error[0].targetobject)"
		"`tFAILED ACCESS`t$TempErrorVar" >> $LogFile
	}
}

# Split the complete list of items into a separate list containing only the files
$FileList = @($FullArray | Where-Object {$_.PSIsContainer -eq $False})

# If the exclusion parameter is included then this loop will run. This will clear out any path not specified in the
# include parameter. If the ExcludePath parameter is also specified
if ($IncludePath) {
	# Checks if all values in $ExcludePath end with \, if not present it will add it
    # Reformats the $ExcludePath so the -notmatch command works, all slashes are repeat twice
    # eg: c:\temp\ becomes c:\\temp\\
    for ($j=0;$j -lt $IncludePath.Count;$j++) {
	    if ($IncludePath[$j].substring($IncludePath[$j].Length-1,1) -ne "\") {$IncludePath[$j] = $IncludePath[$j] + "\"}
    }
    $IncludePath = $IncludePath -replace '\\','\\'
    $IncludePath = $IncludePath -replace '\$','\$'

    for ($j=0;$j -lt $IncludePath.Count;$j++) {
		[array]$NewFileList += @($FileList | Where-Object {$_.FullName -match $IncludePath[$j]})
    }
    $FileList = $NewFileList
    $NewFileList=$null
}

# If the exclusion parameter is included then this loop will run. This will clear out the 
# excluded paths for both the filelist.
if ($ExcludePath) {
	# Checks if all values in $ExcludePath end with \, if not present it will add it
    # Reformats the $ExcludePath so the -notmatch command works, all slashes are repeat twice
    # eg: c:\temp\ becomes c:\\temp\\
    for ($j=0;$j -lt $ExcludePath.Count;$j++) {
	    if ($ExcludePath[$j].substring($ExcludePath[$j].Length-1,1) -ne "\") {$ExcludePath[$j] = $ExcludePath[$j] + "\"}
    }
    $ExcludePath = $ExcludePath -replace '\\','\\'
    $ExcludePath = $ExcludePath -replace '\$','\$'

    for ($j=0;$j -lt $ExcludePath.Count;$j++) {
		$FileList = @($FileList | Where-Object {$_.FullName -notmatch $ExcludePath[$j]})
	}
}

# If the -IncludeFileExtension is specified all filenames matching the criteria specified
if ($IncludeFileExtension) {
    for ($j=0;$j -lt $IncludeFileExtension.Count;$j++) {
        # If no dot is present the dot will be added to the front of the string
        if ($IncludeFileExtension[$j].Substring(0,1) -ne '.') {$IncludeFileExtension[$j] = ".$($IncludeFileExtension[$j])"}
        [array]$NewFileList += @($FileList | Where-Object {$_.Extension -like $IncludeFileExtension[$j]})
    }
    $FileList = $NewFileList
    $NewFileList=$null
}

# If the -ExcludeFileExtension is specified all filenames matching the criteria specified
if ($ExcludeFileExtension) {
    for ($j=0;$j -lt $ExcludeFileExtension.Count;$j++) {
        # If no dot is present the dot will be added to the front of the string
        if ($ExcludeFileExtension[$j].Substring(0,1) -ne '.') {$ExcludeFileExtension[$j] = ".$($ExcludeFileExtension[$j])"}
        $FileList = @($FileList | Where-Object {$_.Extension -notlike $ExcludeFileExtension[$j]})
    }
}

# Counter for prompt output
$AllFileCount = $FileList.Count

# If the -CreateTime switch has been used the script looks for file creation time rather than
# file modified/lastwrite time
if ($CreateTime) {
	$FileList = @($FileList | Where-Object {$_.CreationTime -le $LastWrite})
} else {
    $FileList = @($FileList | Where-Object {$_.LastWriteTime -le $LastWrite})
}

# If the ExcludeDate parameter is specified the query is converted by the ConvertFrom-Query function. The
# output of that table is a hashtable that is splatted to the ConvertTo-DateObject function which returns
# an array of dates. All files that match a date in the returned array will be excluded from deletion which
# allows for more specific exclusions.
if ($ExcludeDate) {
    $SplatDate = ConvertFrom-DateQuery $ExcludeDate
    $ExcludedDates = ConvertTo-DateObject @SplatDate | Select-Object -Unique | Sort-Object -Descending
    if ($CreateTime) {
        for ($j=0;$j -lt $ExcludedDates.Count;$j++) {
            $FileList = @($FileList | Where-Object {$_.CreationTime.Date -ne $ExcludedDates[$j]})
        }
    } else {
        for ($j=0;$j -lt $ExcludedDates.Count;$j++) {
            $FileList = @($FileList | Where-Object {$_.LastWriteTime.Date -ne $ExcludedDates[$j]})
        }        
    }
    [string]$DisplayExcludedDates = for ($j=0;$j -lt $ExcludedDates.Count;$j++) {
        if ($j -eq 0) {
            "`n   ExcludedDates: $($ExcludedDates[$j].tostring('yyyy-MM-dd'))"
        } else {
            $ExcludedDates[$j].tostring('yyyy-MM-dd')
        }
        # After every fifth date start on the next line
        if ((($j+1) % 6) -eq 0) {"`n`t`t "}
    }
    $DisplayExcludedDates
}

# Defines the list of folders, either a complete list of all folders if -EmptyFolder
# was specified or just the folders containing old files. The -NoFolder switch will ensure
# the folder structure is not modified and only files are deleted.
if ($CleanFolders) {
    $FolderList = @($FullArray | Where-Object {$_.PSIsContainer -eq $True})
} elseif ($NoFolder) {
    $FolderList = @()
} else {
    $FolderList = @($FileList | ForEach-Object {
        Split-Path -Path $_.FullName} |
        Select-Object -Unique | ForEach-Object {
            Get-Item -LiteralPath $_ -ErrorAction SilentlyContinue | Select-Object @SelectProperty})
}

# Clear original array containing files and folders and create array with list of older files
$FullArray = ""

# Write totals to console
Write-Host 	"`n   Files`t: $AllFileCount`n   Folders`t:"$FolderList.Count"`n   Old files`t:"$FileList.Count

# Execute main functions of script
if (-not $ListOnly) {
    Write-Host "`n   Starting with removal of old files..."
} else {
    Write-Host "`n   Listing files..."
}
F_Deleteoldfiles
if (-not $ListOnly) {
    Write-Host "   Finished deleting files`n"
} else {
    Write-Host "   Finished listing files`n"
}
if (-not $ListOnly) {
	Write-Host "   Check/remove empty folders started..."
	F_Checkforemptyfolder
	Write-Host "   Empty folders deleted`n"
}

# Pre-format values for footer
$EndDate = Get-Date
$TimeTaken = $Enddate - $StartDate
$TimeTaken = $TimeTaken.ToString().SubString(0,8)
$FilesSize = $FilesSize/1MB
[string]$FilesSize = $FilesSize.ToString()
$FailedSize = $FailedSize/1MB
[string]$FailedSize = $FailedSize.ToString()
$EndDate = "$($EndDate.toshortdatestring()), $($EndDate.tolongtimestring())"

# Output results to console
Write-Host ("-"*79)
Write-Host " "
Write-Host "   Files               : $FilesNumber"
Write-Host "   Filesize(MB)        : $FilesSize"
Write-Host "   Files Failed        : $FilesFailed"
Write-Host "   Failedfile Size(MB) : $FailedSize"
Write-Host "   Folders             : $FoldersNumber"
Write-Host "   Folders Failed      : $FoldersFailed`n"
Write-Host "   Finished Time       : $EndDate"
Write-Host "   Total Time          : $TimeTaken`n"
Write-Host ("-"*79)

# Write footer to logfile
" " >> $LogFile
("-"*79) >> $LogFile
" " >> $LogFile
"   Files               : $FilesNumber" >> $LogFile
"   Filesize(MB)        : $FilesSize" >> $LogFile
"   Files Failed        : $FilesFailed" >> $LogFile
"   Failedfile Size(MB) : $FailedSize" >> $LogFile
"   Folders             : $FoldersNumber" >> $LogFile
"   Folders Failed      : $FoldersFailed" >> $LogFile
" " >> $LogFile
"   Finished Time       : $EndDate" >> $LogFile
"   Time Taken          : $TimeTaken" >> $LogFile
" " >> $LogFile
("-"*79) >> $LogFile

# Clean up variables at end of script
$FileList=$FolderList = $null
