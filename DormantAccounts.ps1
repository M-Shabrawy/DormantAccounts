## PowerShell Script to check for Dormant Accounts in MS AD Domain
### Created by Mohamed Al-Shabrawy
###
#### It requires PowerShell AD Tools module to be installed 
###
#### Use below command line to install under Administrator privilege
####
#### "dism /online /enable-feature /all /featurename:ActiveDirectory-PowerShell"
####
#### Port TCP/9389 required to access ADWS on DCs
####
#### Script will generate 4 files:
####   - List of disabled accounts
####   - List of inactive accounts
####   - List of old password accounts
####   - Log file
#### All files will be overwritten everytime script is executed.
### Calculations is based on 45 Days period.
Import-Module ActiveDirectory

trap [Exception] 
{
	write-error $("Exception: " + $_)
	exit 1
}

$DisabledAccountList = 'C:\Program Files\LogRhythm\LogRhythm Job Manager\config\list_import\Disabled_Accounts.txt'
$InactiveAccountList = 'C:\Program Files\LogRhythm\LogRhythm Job Manager\config\list_import\Inactive_Accounts.txt'
$LazyAccountList = 'C:\Program Files\LogRhythm\LogRhythm Job Manager\config\list_import\Lazy_Accounts.txt'

$AccountLogPath = 'C:\AD Account Log\Account.log'

if (Test-Path -Path $AccountLogPath)
{
    Remove-Item -Path $AccountLogPath
}
else
{

}

#$ADWSServer = Get-ADDomainController -Discover -Service ADWS
#$ServerName =  $ADWSServer.HostName.ToString()
$time = 0
$Date = (Get-Date).AddDays(-45)

$users = Get-ADUser -Filter * -Properties SamAccountName,lastlogon,passwordlastset,passwordneverexpires

$lastlogon = 0

foreach ($user in $users)
{
    if ($user.lastlogon -eq '')
    {
       $lastlogon = $null
    }
    elseif ($user.lastlogon -eq $null)
    {
       $lastlogon = $null
    }
    else
    {
        $lastlogon = ([DateTime]::FromFileTime($user.lastlogon))
    }

    if ($user.enabled -eq $false)
    {
        $user.SamAccountName.ToLower() | Out-File -FilePath $DisabledAccountList -Append
        (Get-Date -Format g) + "|" + $user.SamAccountName + "|Disabled|" + $lastlogon + "|" + $user.Enabled + "|" + $user.PasswordLastSet + "|" + $user.PasswordNeverExpires | Out-File -FilePath $AccountLogPath -Append
		Write-Host "Added entry $user.SamAccountName to Disabled Accounts"
    }
    elseif ($user.PasswordLastSet -lt $Date)
    {
        $user.SamAccountName.ToLower() | Out-File -FilePath $LazyAccountList -Append
        (Get-Date -Format g) + "|" + $user.SamAccountName + "|OldPassword|" + $lastlogon + "|" + $user.Enabled + "|" + $user.PasswordLastSet + "|" + $user.PasswordNeverExpires | Out-File -FilePath $AccountLogPath -Append
		Write-Host "Add entry $user.SamAccountName to Lazy Accounts"
    }
    elseif (($lastlogon -lt $Date) -or ($lastlogon -eq $null))
    {
        $user.SamAccountName.ToLower() | Out-File -FilePath $InactiveAccountList -Append
        (Get-Date -Format g) + "|" + $user.SamAccountName + "|Inactive|" + $lastlogon + "|" + $user.Enabled + "|" + $user.PasswordLastSet + "|" + $user.PasswordNeverExpires | Out-File -FilePath $AccountLogPath -Append
		Write-Host "Add entry $user.SamAccountName to Inactive Accounts"
    }
}