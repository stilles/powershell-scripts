<#
	Project:	Rename a remote computer through PowerShell.
	Date:		2017/7/25
	Author:		Jeff Reed
#>

$targetPC = Read-Host "Target Computer Name"
$newName = Read-Host "New Target Computer Name"
$userName = Read-Host "Domain\Username"

Rename-Computer -ComputerName $targetPC -NewName $newName -DomainCredential $userName -Force -PassThru -Confirm
