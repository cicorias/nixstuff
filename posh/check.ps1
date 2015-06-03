
$credList = Import-Csv -Path "credentials.csv"
$smtpPassword = $credList[0].'Smtp Password'
$smtpUser = $credList[0].'Smtp Username'

$smtpInfo = Import-Csv -Path "smtpInfo.csv"
$smtpFrom = $smtpInfo.from
$smtpTo = $smtpInfo.to
$smtpServer = $smtpInfo.server

$URLListFile = "URLList.txt"  
$URLList = Get-Content $URLListFile -ErrorAction SilentlyContinue 
$logfile = (Get-Date -Format yyy-MM-dd_HH-MM-mm-ss) + ".log" 

start-transcript -Force -path $logfile

write-output "starting dns lookup....`n`n"
try 
{ 
    $URLList | ForEach-Object { Write-Host "lookup on $_"; nslookup $_ PRD1.AZUREDNS-CLOUD.NET } -ErrorAction Stop
}  
catch [System.Exception]
{
    Write-Error -Message "1Some other exception that's nothing like the above examples"
    $_.Exception.GetType()
    $_.Exception.Message
}
catch
{
    Write-Error -Message "2Some other exception that's nothing like the above examples"
}
write-output "`n`n ending lookup"
stop-transcript

$logfileContent = Get-Content -Path $logfile

if ( $logfileContent | Select-String -Pattern "Server failed")
{
    Write-Warning "Failed now emailing"
    $PWord = ConvertTo-SecureString –String $smtpPassword –AsPlainText -Force
    $Credential = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $smtpUser, $PWord
    $EmailFrom = $smtpFrom
    $EmailTo = $smtpTo
    $EmailSubject = "URL Report"
    $emailbody = " DNS lookup faild "
    $SMTPServer = $smtpServer
    Send-MailMessage -Port 587 -SmtpServer $SMTPServer -Credential $Credential -UseSsl  `
        -From $EmailFrom -To $EmailTo -Attachments $logfile -Subject $EmailSubject -Body $emailbody -Bodyashtml;

}

