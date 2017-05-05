<#
	Title: 		Move and Disable Computers
	Version:	2017.04.24
	Author:		Jeff Reed
	
	Summary:	Gets inactive computers based on days, then moves and deactivates computer account.
#>

import-module activedirectory 

<# ***	GLOBAL VARIABLES	*** #>
$searchDirectory = "OU=CHILDOU,OU=PARENTOU,DC=DOMAIN,DC=COM"
$moveToOU = 'OU=CHILDOU,OU=PARENTOU,DC=DOMAIN,DC=COM'
$daysInactive = 90
$time = (Get-Date).Adddays(-($daysInactive))

function getInactiveComputers ($show = "False") {
	$inactiveComputers = Get-ADComputer -SearchBase $searchDirectory -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp
	if($show -eq "True") {
		$inactiveComputers | select-object Name,@{Name="Timestamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | export-csv ".\computersRetiredByScript.csv" -notypeinformation
		Invoke-Expression ".\computersRetiredByScript.csv"
	}
	if($show -eq "False") {
		return $inactiveComputers
	}
}
function moveAndDisable($option = "Normal") {
	# Normal = run from $daysInactive variable.
	# Single = run against a single hostname.
	# File   = run against an input CSV.

	if($option -eq "Normal") {
		# 1. Get all inactive computers based on $daysInactive.
		# 2. Disable computer account and move to $moveToOU.
		$inactiveComputers = getInactiveComputers
				
		[Environment]::NewLine
		foreach($hostname in $inactiveComputers) {
			Get-ADComputer $hostname | Disable-ADAccount
			Get-ADComputer $hostname | Move-ADObject -TargetPath $moveToOU
			Write-Host -ForegroundColor Yellow "Moved and disabled" $hostname
		}
		[Environment]::NewLine
	}
	if($option -eq "Single") {
		Write-Host "Enter hostname to run script on "
		$hostname = Read-Host
		Get-ADComputer $hostname | Move-ADObject -TargetPath $moveToOU -Confirm
		Get-ADComputer $hostname | Disable-ADAccount -Confirm
		[Environment]::NewLine
		Write-Host -ForegroundColor Yellow "Moved and disabled" $hostname
		[Environment]::NewLine
	}
	if($option = "File") {
		Write-Host -ForegroundColor Yellow "Please confirm that 'ComputersToDelete.txt' is in the same folder. Press Enter to continue."
		Read-Host
		$inactiveComputers = Get-Content ".\ComputersToDelete.txt"
		
		[Environment]::NewLine
		foreach($hostname in $inactiveComputers) {
			Get-ADComputer $hostname | Disable-ADAccount -Confirm
			Get-ADComputer $hostname | Move-ADObject -TargetPath $moveToOU -Confirm
			Write-Host -ForegroundColor Yellow "Moved and disabled" $hostname
		}
	}
}
function mainMenu() {
	while($mainInput -ne "q"){
		Write-Host -ForegroundColor magenta "Move and Disable Computers Script."
		[Environment]::NewLine
		Write-Host " 1 - Run Script"
		Write-Host " 2 - Export Potential Targets"
		Write-Host " 3 - Enter Single Hostname to Run On"
		Write-Host " 4 - Run on 'ComputersToDelete.txt'"
		[Environment]::NewLine
		$mainInput = Read-Host "Choice (q)uit"
		
		switch -wildcard ($mainInput){
			"1" { moveAndDisable }
			"2" { getInactiveComputers("True") }
			"3" { moveAndDisable("True") }
			"4" { moveAndDisable("File") }
			"q*" { $mainInput = "q" }
			default { 
				Clear-Host
				Write-Host -ForegroundColor Red "Invalid Response Entered.."
				[Environment]::NewLine
			}
		}
	}
}

mainMenu