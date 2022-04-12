$days = (Get-Date).AddDays(-180)
$query = Get-AdUser -Filter * -Properties Name, PasswordLastSet, PasswordNeverExpires, SamAccountName, LastLogon | Where-Object {$_.PasswordLastSet -lt $days -and $_.Enabled -eq "True"}
$queryCount = $query.Count

If ($queryCount > 0) {
    Write-Host -ForegroundColor Green "Number of accounts found with passwords older than $days - " $queryCount
    $query | Sort-Object -Property PasswordLastSet | Format-Table Name, SamAccountName, DistinguishedName, @{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}}, PasswordLastSet
    } Else {
    Write-Host -ForegroundColor Green "None found."
    }
