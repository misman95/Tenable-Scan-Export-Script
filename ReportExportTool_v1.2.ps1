# 대외비, 삼성, Hanwha

<# 
ScriptName: Tenable.io Report_Export_Tool.ps1
PSVersion:  5.1
Purpose:    Powershell script to generate Tenable scan report and email them to recipients.
Created:    Feb 2021
Author:     misman95
Email:      misman95@gmail.com
Github:          
#>

#------------------Input Variables-----------------------------------------------------------------
$Baseurl = "https://cloud.tenable.com"
$SessionUri = $Baseurl + "/session"
$ScansUri = $Baseurl + "/scans"
$Username = Read-Host "Enter Tenable.io login username (email address): "
$PasswordResponse = Read-Host "Enter Password: " -AsSecureString
$Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordResponse))
$ContentType = "application/json"
$FilePath = "C:\temp\"
$ExportList = "TargetSystems.csv"

#------------------Create Json Object for User Authentication--------------------------------------
$UserNameBody = convertto-json (New-Object PSObject -Property @{username = $username; password = $Password})

#------------------Log in to Tenable.io----------------------------------
$TokenResponse = (Invoke-RestMethod -Uri $SessionUri -Headers $Header -Method POST -ContentType $ContentType -Body $UserNameBody)
if ($TokenResponse) {
    $Header = @{
        "x-Cookie" = "token=" + $TokenResponse.token
        "Accept" = "*/*"
    }
    Write-Host "Log in to Tenable.io......................................OK"
} else { 
    Write-Host "Log in Error. Please check username and password."
    Start-Sleep -s 20
    exit
}

#------------------Set Report Format as PDF (Detailed)--------------------------------------------------------
$Format = @{
    format      = "pdf"
    chapters = "vuln_by_host;vuln_hosts_summary;remediations;"
}
$ExportBody = convertto-json (New-Object PSObject -Property $Format)

#------------------Generate and Export Scan Report----------------------------------------------------------------
$reportarray = Import-Csv "$($FilePath)$($ExportList)"

foreach ($fileItem in $reportarray)
{
    #---------------GET Scan ID and Scan Name-----------------------
    $Scanscompleted = (Invoke-RestMethod -Uri $ScansUri -ContentType $ContentType -Headers $Header -Method $GETMethod).scans | 
        ? {$_.name -eq $fileitem.ScanName} | Select-Object id, Name
    #---------------POST Export Request and Recieve File ID and Temp_Token----------------------
    $FileUri = "$ScansUri" + "/" + $Scanscompleted.id + "/export"
    $file = Invoke-RestMethod -Uri $FileUri -Headers $Header -Method $POSTMethod -ContentType $ContentType -Body $ExportBody   
    #---------------Create Status URI andn Download URI----------------------
    $DownloadUri = "$ScansUri" + "/" + $Scanscompleted.id + "/export/" + $file.file + "/download?" + $file.temp_token
    $StatusUri = "$ScansUri" + "/" + $Scanscompleted.id + "/export/" + $file.file + "/status"
    
    Do {
         #----------------Export Status Check-------------------------------------------
        $result = (Invoke-RestMethod -Uri $StatusUri -Headers $Header -Method $GETMethod).status
         #----------------Download Report-------------------------------------------
        if ($result -eq "ready")
        {
            Write-Host "Export for $($fileItem.ScanName) is............. $($result)"
            Invoke-RestMethod -Uri $DownloadUri -ContentType $ContentType -Headers $Header -Method $GETMethod -OutFile "$($FilePath)$($fileitem.ScanName).pdf"                 
            Write-Host "Scans have been exported to $($FilePath) as $($fileItem.ScanName).pdf"
            
        }else{
            Write-Host "Wait for another 15 seconds....."
            Start-Sleep -s 15
        }
    }
    While ($result -ne "ready")

    # Get the email credential
    $User = "you@example.com"
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $FilePath$SecureMailPassword | ConvertTo-SecureString)

    ## Define the Send-MailMessage parameters
    $mailParams = @{
        SmtpServer                 = 'smtp.example.com'
        Port                       = '587' # or '25' if not using TLS
        UseSSL                     = $true # or not if using non-TLS
        Credential                 = $credential
        From                       = 'you@example.com'
        To                         = "$($fileItem.Recipients)"
        Subject                    = "Scan Report: $($fileitem.ScanName) - $(Get-Date -Format g)"
        Body                       = "Please see the scan report for $($fileitem.ScanName)"
        DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
        Attachments                = "$($Filepath)$($fileitem.ScanName).pdf"
    }
    # Send the message
    Send-MailMessage @mailParams

    Write-Host "Completed exporting scan reports - $($fileitem.Scanname)."

}

#------- EOF ------------
