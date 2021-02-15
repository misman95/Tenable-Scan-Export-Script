<H1>Tenable.io Scan Report Export Tool</H1>

<H2>Background</H2>
I've created this tool because it is not possible to automate exporting scan reports and sending emails in Tenable.io Console.

<H2>How it works</H2>
<ol>
  <li>Log in to Tenable.io
  <li>Set report format as PDF (detailed)
  <li>Send scan export request to Tenable.io
  <li>Check the export status and download if the report is ready
  <li>Attached the report in the email message and send it to the recipients
</ol>

<H2>Requirements</H2>
  <ul>
    <li>Scan Names and Recipients List (CSV file)
    <li>Your email password (encrypted in the text file)*
  </ul>
 </br> 
 <B>How to encrypt your password</B>: 
 <code>(get-credential).password | ConvertFrom-SecureString | set-content " C:\temp\EmailPassword.txt" </code></br>
  
<H2>Notes</H2>
<ul>
  <li>Author: misman95
  <li>Created: Feb 2021
  <li>PS version: 5.1
</ul>

<H2>Kudos</H2>
<p>Got many helps from: https://github.com/Pwd9000-ML/NessusV7-Report-Export-PowerShell/blob/master/NessusPro_v7_Report_Exporter_Tool.ps1 </p>
