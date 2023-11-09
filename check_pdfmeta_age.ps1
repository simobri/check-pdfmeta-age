#

# -----------------------------------------------------------------------------
# ScriptName    ::      check_pdfmeta_age.ps1
# Version       ::      2311.00 Release
# Author        :: 	    Brivio Simone
#               ::      https://github.com/simobri
#               ::      https://github.com/simobri/check-pdfmeta-age
# License       ::      GNU General Public License v3.0
# Notes         ::      -
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Usage
# -----------------------------------------------------------------------------

# Please read the README.md and INSTALL.md documentation provided to this script to
# learn more about requirements
# For variables and settings, see the description above each of them.

# -----------------------------------------------------------------------------
# Include required libs
# -----------------------------------------------------------------------------

# Libraries for dialog
Add-Type -AssemblyName PresentationCore,PresentationFramework
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# -----------------------------------------------------------------------------
# Script Settings
# -----------------------------------------------------------------------------

# $DEBUG: Enable or disable the debug on the console and or log file
# Accepted values: 0=OFF, 1=CONSOLE ONLY, 2=CONSOLE AND LOG FILE (if enabled)
$DEBUG=2

# $LOGFILE: Enable or disable the logging on a log file (plaintext). Accepted values: 0=OFF, 1=ON
# If disabled, DEBUG messages will not be logged.
# $LOGFILEPATH: Path of the log file on which script should write. (Append mode)
$LOGFILE=1
$LOGFILEPATH="C:\Program Files (Portable)\check_pdfmeta_age\check_pdfmeta_age.log"

# $DISPLAYFILELIST: Choose to display or not the list of expired file in the message dialog.
# If set to 1, the full list of the file will be displayed. If set to 0, only the count of the file will be displayed.
# Be careful: if the list of the file is very long, the dialog message will overflow the monitor size without scrolling feature!
$DISPLAYFILELIST=0

# $MAX_PDFAGE_SECONDS: How many second old the PDF Creation Date metadata should be considered expired
# Example: 3600 file older than 1 hour will be marked as expired
$MAX_PDFAGE_SECONDS=3600

# $FILEDIR: Directory to search the PDF files. Please use ABSOLUTE path
$FILEDIR="C:\Users\Public\Documents"

# $PDFINFO_EXE_PATH: Full absolute path of the 'pdfinfo.exe' file
# Example: "C:\Program Files (Portable)\xpdf-tools-win-4.04\bin64\pdfinfo.exe"
$PDFINFO_EXE_PATH="C:\Program Files (Portable)\xpdf-tools-win-4.04\bin64\pdfinfo.exe"

# -----------------------------------------------------------------------------
# Dialog Message Settings
# -----------------------------------------------------------------------------

# $MSG2USER_RUNDATE: Format of the date displayed on the message, default is dd/MM/yyy HH:MM
$MSG2USER_RUNDATE= (Get-Date).toString("dd/MM/yyy HH:mm")

# $MSG2USER_SCRIPTNAME: Name of this script, will be displayed on the title prefix of the message dialog
$MSG2USER_SCRIPTNAME="Check PDFmeta Age"

# $MSG2USER_SCRIPTERROR
# These variables will be used in case the script fail to execute some checks or 0 file has been checked
# The $MSG2USER_SCRIPTERROR_TITLE will be used ad dialog message title, while the $MSG2USER_SCRIPTERROR_MESSAGE as message body
$MSG2USER_SCRIPTERROR_TITLE="$MSG2USER_SCRIPTNAME : File check failure"
$MSG2USER_SCRIPTERROR_MESSAGE="The $MSG2USER_SCRIPTNAME script has encountered at least one error while checking PDF file age, or no PDF has been found in the specified directory ($FILEDIR).`nCheck the log file $LOGFILEPATH and/or enable debug to learn more`n$MSG2USER_RUNDATE"

# $MSG2USER_FILEEXPIRED
# These variables will be used in case the script has found at least one file expired.
# The message dialog will display the _PREFIX vars content then the defined message inside the code (see later on) and at the end the _SUFFIX 
# This can be useful to add static PREFIX and SUFFIX strings or data useful for the user
$MSG2USER_FILEEXPIRED_TITLE="$MSG2USER_SCRIPTNAME : File age expired"
$MSG2USER_FILEEXPIRED_PREFIX="CAUTION!"
$MSG2USER_FILEEXPIRED_SUFFIX="Please make sure to have the the updated version of the files"

# -----------------------------------------------------------------------------
# Script internal variables *** PLEASE DON'T TOUCH ***
# -----------------------------------------------------------------------------

# Initlializing Counters
$SCRIPT_ERRORS=0
$PDFFILE_EXPIRED=0
$PDFFILE_PROCESSED=0

# Initializing message string
$MSG_FILEOLD=""

# Make a new temporary file
$TEMPFILE = New-TemporaryFile

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

# Source code modified from this example: https://woshub.com/write-output-log-files-powershell/
function WriteLog
{
    Param ([string]$LogString)
    if ($LOGFILE -eq 1)
    {
        $Stamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
        $LogMessage = "$Stamp $LogString"
        Add-content $LOGFILEPATH -value $LogMessage
    }
}

function WriteDebug
{
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
    $LogMessage = "$Stamp [Debug] $LogString"
    Write-Host $LogMessage
    if ($DEBUG -eq 2) { WriteLog "[Debug] $LogString" }
}

# -----------------------------------------------------------------------------
# Main begins Here
# -----------------------------------------------------------------------------

WriteLog "-----------------------------------"
WriteLog "Staring new script run"
WriteLog "-----------------------------------"

if ($DEBUG -ge 1) { WriteDebug "-----------------------------------" }
if ($DEBUG -ge 1) { WriteDebug "Staring new script run"  }
if ($DEBUG -ge 1) { WriteDebug "-----------------------------------" }

# Foreach PDF file inside the folder, check for PDF Metadata date
Get-ChildItem $FILEDIR -Filter *.pdf | 
Foreach-Object {
    # Debug Strings
    if ($DEBUG -ge 1) { WriteDebug "-----------------------------------" }
    if ($DEBUG -ge 1) { WriteDebug "Beginning processing the next file"  }
    if ($DEBUG -ge 1) { WriteDebug "-----------------------------------" }

	# Make the output file of the pdfinfo clean
	Clear-Content $TEMPFILE.FullName
	
    # Take the current file name and store it
    $CURRPDFFILE=$_.FullName
    if ($DEBUG -ge 1) { WriteDebug "Now processing file: $CURRPDFFILE" }
    
    # Generate the pdfinfo command-line parameters and args
    $CMD_PDFINFO=$PDFINFO_EXE_PATH + " -meta `"" + $CURRPDFFILE + "`""
    if ($DEBUG -ge 1) { WriteDebug "Pdfinfo.exe CMD is: $CMD_PDFINFO" }

    # Lauch the pdfinfo.exe process and store result
    # Process Exit Code will be inside $PDFINFO_PROC.ExitCode variable
    # Standard Output wil be saved inside the $TEMPFILE.FullName file
    $PDFINFO_PROC=$(Start-Process $PDFINFO_EXE_PATH -ArgumentList "-meta `"$CURRPDFFILE`"" -Wait -NoNewWindow -PassThru -RedirectStandardOutput $TEMPFILE.FullName)
    # Convert exit code to string
    $PDFINFOEXITCODE=$PDFINFO_PROC.ExitCode.ToString()
    if ($DEBUG -ge 1) { WriteDebug "pdfinfo.exe exit code is: $PDFINFOEXITCODE " }
    if ($DEBUG -ge 1) { WriteDebug "pdfinfo.exe standard output has been saved here: $TEMPFILE.FullName" }

    # Check if pdfinfo.exe error orrourred
    if ($PDFINFO_PROC.ExitCode -ne 0) 
    { 
        $SCRIPT_ERRORS++
        WriteLog "pdfinfo.exe error has occurred while processing file: $CURRPDFFILE"
        if ($DEBUG -ge 1) { WriteDebug "pdfinfo.exe error has occurred while processing $CURRPDFFILE" }
    }
    else
    {
        # Compute the PDF age
        $PDF_CREATIONDATE_RAW=(Get-Content $TEMPFILE.FullName |  Select-String -pattern 'CreationDate:').ToString()
        $PDF_CREATIONDATE_RAWSTRING=$PDF_CREATIONDATE_RAW.replace("CreationDate:   ","")
        
        # Check if string contais double spaces between items, since the day of the month can be single digit and application
        # insert another extra whitepace for output alignment:
        # Thu Apr  6 03:33:23 2023
        # Fri Nov 17 12:39:55 2017
        $PDF_CREATIONDATE_RAWSTRING=$PDF_CREATIONDATE_RAWSTRING.replace("  "," ")

        # Check if the format is compliant before extract fields, with regex
        if ($PDF_CREATIONDATE_RAWSTRING -match "[A-Za-z]{3} [A-Za-z]{3} [0-9]{0,2} {1}[0-9]{2}:[0-9]{2}:[0-9]{2} [0-9]{4}")
        {
            # Now split the resulting date to sort item around to be compatible with Windows Format
            # Input: "Fri Nov 17 12:39:55 2017"
            # Output: (Array) "Fri <NewLine|Item> Now <NewLine|Item> 17 <NewLine|Item> 12:39:55 <NewLine|Item> 2017 <NewLine|Item>"
            # So...
            # Element 0 = Weekday name
            # Element 1 = Month name
            # Element 2 = Day
            # Element 3 = Time HH:MM:SS
            # Element 4 = Year
            $PDF_CREATIONDATESPLIT=$PDF_CREATIONDATE_RAWSTRING -split " "
            $PDF_CREATIONDATE=$PDF_CREATIONDATESPLIT[0] + " " + $PDF_CREATIONDATESPLIT[2] + " " +  $PDF_CREATIONDATESPLIT[1] + " " +  $PDF_CREATIONDATESPLIT[4] + " " +  $PDF_CREATIONDATESPLIT[3]

            # Debug
            if ($DEBUG -ge 1) { WriteDebug "Variable PDF_CREATIONDATE_RAW content is: $PDF_CREATIONDATE_RAW"}
            if ($DEBUG -ge 1) { WriteDebug "Variable PDF_CREATIONDATE_RAWSTRING content is: $PDF_CREATIONDATE_RAWSTRING" }
            if ($DEBUG -ge 1) { WriteDebug "Variable PDF_CREATIONDATESPLIT content is: $PDF_CREATIONDATESPLIT" }
            if ($DEBUG -ge 1) { WriteDebug "Variable PDF_CREATIONDATE content is: $PDF_CREATIONDATE" }

            # Compute how many seconds ago the PDF file has been created
            $PDFCREATIONDATE_SECONDSAGO=$((Get-Date).ToUniversalTime().Subtract((Get-Date "$PDF_CREATIONDATE")).Totalseconds)

            if ($DEBUG -ge 1) { WriteDebug "Variable PDFAGE_SECONDSAGO content is: $PDFCREATIONDATE_SECONDSAGO" }

            # Check if the file is older than expected
            if ( $PDFCREATIONDATE_SECONDSAGO -gt $MAX_PDFAGE_SECONDS)
            {
                # Increment counter
                $PDFFILE_EXPIRED++
                #Generate the final message string
                $PDFCREATIONDATE_DATE=(Get-Date).AddSeconds(-$PDFCREATIONDATE_SECONDSAGO)
                $MSG_FILEOLD="$MSG_FILEOLD $CURRPDFFILE is $PDFCREATIONDATE_SECONDSAGO seconds old ($PDFCREATIONDATE_DATE)`n`n"
            }    
        }
        else
        {
            # Extracted date from metadata has invalid format.
            $SCRIPT_ERRORS++
            WriteLog "Invalid extracted date from PDF metadata for $CURRPDFFILE file. Please enable debug to learn more"
            if ($DEBUG -ge 1) { WriteDebug "Invalid retrieved date from PDF metadata of the $CURRPDFFILE file. Please check it manually" }
            if ($DEBUG -ge 1) { WriteDebug "PDF_CREATIONDATE_RAW content is: $PDF_CREATIONDATE_RAW" }
            if ($DEBUG -ge 1) { WriteDebug "PDF_CREATIONDATE_RAWSTRING content is: $PDF_CREATIONDATE_RAWSTRING" }
        }

    }

    $PDFFILE_PROCESSED++

    # Current file processing has been completed
    if ($DEBUG -ge 1) { WriteDebug " -----------------------------------"  }
    if ($DEBUG -ge 1) { WriteDebug "Done processing the current file"      }
    if ($DEBUG -ge 1) { WriteDebug " -----------------------------------"  }
}

# All the *.pdf files inside the specified folder has been parsed.
if ($DEBUG -ge 1) { WriteDebug "Done processing all the file inside the directory" }
if ($DEBUG -ge 1) { WriteDebug "Number of processed PDF files are: $PDFFILE_PROCESSED" }
if ($DEBUG -ge 1) { WriteDebug "Number of PDF files with expired age: $PDFFILE_EXPIRED" }

# Check if at least one file has been processed, otherwhise increment the number of script errors.
if ($PDFFILE_PROCESSED -le 0)
{
    $SCRIPT_ERRORS++
    WriteLog "No file has been processed, there is at least one PDF file inside the $FILEDIR folder?"
    WriteDebug "No file has been processed, there is at least one PDF file  inside the $FILEDIR folder?"
}

# Removing temporary file
Remove-Item $TEMPFILE.FullName -Force

# Now check for errors and display the result to the user

# If script had some runtime error, display a message and exit.
if ($SCRIPT_ERRORS -ne 0)
{
    WriteDebug "Script error count is $SCRIPT_ERRORS. Display script failure message"
    $msgBody = "$MSG2USER_SCRIPTERROR_MESSAGE"
    $msgTitle = "$MSG2USER_SCRIPTERROR_TITLE"
    $msgButton = 'OK'
    $msgImage = 'Warning'
    $msgdialog = new-Object System.Windows.Forms.Form -property @{Topmost=$true}
    $Result = [System.Windows.Forms.MessageBox]::Show($msgdialog, $msgBody,$msgTitle,$msgButton,$msgImage)
    WriteLog "$Env:UserName clicked $Result on the SCRIPTERROR message dialog"
    WriteDebug "$Env:UserName clicked $Result on the SCRIPTERROR message dialog"
    exit 2
}
else
{
    # If script has run properly, but at least one of the PDF is expired, show a message to alert the user
    if ($PDFFILE_EXPIRED -ne 0 )
    {
        # Computing the messages
        $MSG2USER_FILEEXPIRED_MESSAGE="$MSG2USER_FILEEXPIRED_PREFIX`nThere are $PDFFILE_EXPIRED/$PDFFILE_PROCESSED file(s) with EXPIRED age!`n$MSG2USER_FILEEXPIRED_SUFFIX`n$MSG2USER_RUNDATE"
        $MSG2USER_FILEEXPIRED_MESSAGELIST="$MSG2USER_FILEEXPIRED_PREFIX`nThe following file(s) are expired:`n$MSG_FILEOLD`n$MSG2USER_FILEEXPIRED_SUFFIX`n$MSG2USER_RUNDATE"

        if ($DISPLAYFILELIST -eq 1)
        {
            $msgBody = "$MSG2USER_FILEEXPIRED_MESSAGELIST"
            $msgTitle = "$MSG2USER_FILEEXPIRED_TITLE"
            $msgButton = 'OK'
            $msgImage = 'Error'
            $msgdialog = new-Object System.Windows.Forms.Form -property @{Topmost=$true}
            $Result = [System.Windows.Forms.MessageBox]::Show($msgdialog, $msgBody,$msgTitle,$msgButton,$msgImage)
            WriteLog "$Env:UserName clicked $Result on the FILEEXPIRED message dialog"
            WriteDebug "$Env:UserName clicked $Result on the FILEEXPIRED message dialog"
        }
        else
        {
            $msgBody = "$MSG2USER_FILEEXPIRED_MESSAGE"
            $msgTitle = "$MSG2USER_FILEEXPIRED_TITLE"
            $msgButton = 'OK'
            $msgImage = 'Error'
            $top = new-Object System.Windows.Forms.Form -property @{Topmost=$True}
            $Result = [System.Windows.Forms.MessageBox]::Show($top, $msgBody,$msgTitle,$msgButton,$msgImage)
            WriteLog "$Env:UserName clicked $Result on the FILEEXPIRED message dialog"
            WriteDebug "$Env:UserName clicked $Result on the FILEEXPIRED message dialog"
        }
        exit 1
    }
}

# If script has run properly and all PDF age is healty, exit without any message(s): It's all good.
WriteLog "All files age is below the threshold"
WriteDebug "All files age is below the threshold"

exit 0