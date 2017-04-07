<#
	Project:	Dynamic Distribution List Output
	Date:		2016/10/12
	Author:		Jeff Reed
	
	Purpose:	Gets all members of a Dynamic Distribution list and returns as a text file.
#>

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Support

# Get input from user.
$DLname = Read-Host 'What is the name of the Distribution List? (ex DL-Support Team) : '

# Return the list to a text file.
$DLmembers = Get-DynamicDistributionGroup $DLname
Get-Recipient -RecipientPreviewFilter $DLmembers.RecipientFilter | Sort-Object name | Out-File ".\output.txt"

# Open newly created file.
Invoke-Expression ".\output.txt"