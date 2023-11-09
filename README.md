# **Check PDFmeta Age**
*A Windows Powershell script that check the metadata of PDF files and display a message to the user if at least one of them is too old*

---

# **License and Warranty**

This project is licensed under the terms of the GPL v3.0 license, and came without warranty; both for author choice and to be compliant with the GPL v3.0 license itself, since the third-party components use the same license agreements. Please refer to LICENSE file for the full terms.

# **Prerequisites**

This script require and work thanks to the *pdfinfo* tool provided by the *xpdf* project, visit the official website to learn more: [https://www.xpdfreader.com](https://www.xpdfreader.com/)
The current version of this script has been tested with the `4.04` version of that library/software.

A copy of the Xpdf command line tools for Windows and the source code has been copied inside this repository and is avaiable inside the `src` folder; along with the original authors GPG signature.

# **Installation**

See the [INSTALL.md](INSTALL.md) for more information about the installation and the configuration

# **Usage**

After script has been configured, simply run as standalone mode or with task scheduler.
If at least one PDF file Metadata age is expired, a message like this will be displayed to the user, otherwhise the script will run silently on the system.

![image](/assets/check_pdfmeta_age_expiredmessage.png)

If you had choose to also display the file list, the message will change and will be like this:

![image](/assets/check_pdfmeta_age_expiredmessage-list.png)

If there are corrupted PDF files, without metadata, or if the script iself encounters some kind of errors while running, an error message will be diplayed.
In such case, please enable the debug and check what is going wrong.

![image](/assets/check_pdfmeta_age_scripterror.png)

Message can be personalized.



