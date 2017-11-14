

Import-Module ActiveDirectory

$DisabledAccountList = 'C:\Program Files\LogRhythm\LogRhythm Job Manager\config\list_import\Disabled_Accounts.txt'
$InactiveAccountList = 'C:\Program Files\LogRhythm\LogRhythm Job Manager\config\list_import\Inactive_Accounts.txt'
$LazyAccountList = 'C:\Program Files\LogRhythm\LogRhythm Job Manager\config\list_import\Lazy_Accounts.txt'

$AccountLogPath = 'C:\AD User Logs\Account.log'

if (Get-Item -Path $AccountLogPath)
{
    Remove-Item -Path $AccountLogPath
}

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
        (Get-Date -Format g) + "|" + $user.SamAccountName + "|" + $lastlogon + "|" + $user.Enabled + "|" + $user.PasswordLastSet + "|" + $user.PasswordNeverExpires | Out-File -FilePath $AccountLogPath -Append
    }
    elseif ($user.PasswordLastSet -lt $Date)
    {
        $user.SamAccountName.ToLower() | Out-File -FilePath $LazyAccountList -Append
        (Get-Date -Format g) + "|" + $user.SamAccountName + "|" + $lastlogon + "|" + $user.Enabled + "|" + $user.PasswordLastSet + "|" + $user.PasswordNeverExpires | Out-File -FilePath $AccountLogPath -Append
    }
    elseif ($lastlogon -lt $Date)
    {
        $user.SamAccountName.ToLower() | Out-File -FilePath $InactiveAccountList -Append
        (Get-Date -Format g) + "|" + $user.SamAccountName + "|" + $lastlogon + "|" + $user.Enabled + "|" + $user.PasswordLastSet + "|" + $user.PasswordNeverExpires | Out-File -FilePath $AccountLogPath -Append
    }
}
