# **Installation**

## Introduction

Since this script and its dependencies are standalone, the entire package can be considered as a portable application, so will be installed, for example, on Windows system drive under the `C:\Program Files (Portable)` folder
You can choose any other folder, adapt the path accordingly.

## Installation of the *xpdf-tools*

Extract the `xpdf-tools-win-4.04.zip` from this repo, or download it from the official website, inside the `C:\Program Files (Portable)` folder, then use the file explorer to locate and take note of the `pdfinfo.exe` executables paths, based on your CPU architecture: x86 or x64. By default this script use the x64 version. For the example defaults, that should be the values:

- `C:\Program Files (Portable)\xpdf-tools-win-4.04\bin64\pdfinfo.exe`
- `C:\Program Files (Portable)\xpdf-tools-win-4.04\bin32\pdfinfo.exe`

Make sure the two executable work, from a Windows PowerShell or Windows Commmand Prompt, launch the program that match your CPU architecture with the `-h` option

![image](/assets/check_pdfmeta_age_pdfinfocheck.png)

## Installation of the *check_pdmeta_age.ps1* script

Now it's time to install and configure the script itself

Download it from the repository and copy into a subfolder of the previously specified base directory: `C:\Program Files (Portable)\check_pdfmeta_age`

By default the script have *debug enabled* with logging on both console and disk to `C:\Program Files (Portable)\check_pdfmeta_age\check_pdfmeta_age.log` plain-text file, and checks for all PDF files with creation-date metadata older than 1 hour  inside the `C:\Users\Public\Documents` folder. Subfolders are **NOT** checked.

# Script Configuration

You can personalize many things, changing the values of variables inside the script, and also you can make many copy of the script with different settings if you needs.

*Each of them are properly documented as powershell comments, to avoid redundant informations between the script and this readme file.*

- Enable and disable the debug, and choose to have it displayed on the console only or also written on log file
- Choose where store the log file: script has been tought to be run with task scheduler so error messages must be logged since the console will be hidden
- Modify the path of the folder on wich the PDF files are located
- Modify the installation path of the pdfinfo.exe program, if you want to install elsewhere
- Modify the Date/Time format of the script runtime displayed on the message to the user
- Choose to display to the user only the count of the expired files or a list with their full path on disk (1)
- Customize the name of the script displayed in the message window title
- Customize the message displayed to the user when script fails to run
- Customize the message prefix and suffix displayed to the user when script detect aged files

(1) If the list of files is too long, the message can be larger than the monitor size and at the moment, this script doesn't support scrolling.
