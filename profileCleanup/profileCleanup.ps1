<#
	Title: 		Jeff's PowerShell Cleanup Script
	Version:	2017.02.28
	
	Summary:	Clean up old profiles that have not been logged in to for some time.
		Tip:		Use ".\filename.ps1 silent" to run without needing user interaction.
#>

param(
	[string]$silent = $null
)

<####################################>
<#		GLOBAL VARIABLES SET HERE	#>
<####################################>
$numDaysOld = (Get-Date).Date.AddDays(-60)		#Number of days (integer) to ignore.
$IgnoreList = "" 								#Account SIDs to ignore.

$logFile = "\\path\to\log\file.log"


<#		Functions		#>
function checkResponse($response){	
	switch -wildcard ($response){
		"y*" { $oldProfile.Delete()
			  Write-Host -ForegroundColor Green "Deleted!"
		}
		"n*" { Write-Host "Skipped." }
		"q*" { exit }
		default {Write-Host -ForegroundColor Red "Invalid reponse"}
	}
}
function getProfiles(){
	$oldProfiles = Get-WMIObject -class Win32_UserProfile | Where {(!$_.Special) -and ($_.ConvertToDateTime($_.LastUseTime) -lt $numDaysOld)}
	
	if(!$oldProfiles){
		Write-Host -ForegroundColor Green "No profiles found that should be deleted."
		exit
	}
	
	return $oldProfiles
}
function showProfiles(){
	Clear-Host
	$oldProfiles = getProfiles
	$oldProfiles | select localpath, @{LABEL="last used";EXPRESSION={$_.ConvertToDateTime($_.lastusetime)}} | Format-Table
	Read-Host ":: press ENTER to continue :"
	Clear-Host
}
function loopThroughProfiles($skip = "False") {
	Clear-Host
	
	$oldProfiles = getProfiles
	
	[Environment]::NewLine
	Write-Host -ForegroundColor Magenta "Searching for profiles older than $numDaysOld."
	Write-Host -ForegroundColor Green $oldProfiles.Count "found that could be removed. (counting exclusions)"
	
	#	Loop variables
	$removedCount = 0
	$removedSize = 0

	#	Main Script Loop
	$currentIndex = 1
	
	:OutsideLoop
	foreach($oldProfile in $oldProfiles) {
		foreach($SID in $IgnoreList) {
			if($oldProfile.SID -eq $sid) {
				Write-Host "Profile will be skipped by script:" $oldProfile.LocalPath
				continue OuterLoop
			}
		}
		if($skip -eq "False"){
			Write-Host
			Write-Host -ForegroundColor Yellow "Do you wish to delete" $oldProfile.LocalPath "? (y)es, (n)o, (q)uit" 
			$userInput = Read-Host
			checkResponse($userInput)
		}
		elseif($skip -eq "True"){
			Write-Host
				#	Delete the profile.
				Write-Host -ForegroundColor Yellow "Currently deleting" $oldProfile.LocalPath "("$currentIndex "of" $oldProfiles.Count ")"
				$oldProfile.Delete()
				Write-Host -ForegroundColor Green "Done!"
					$removedCount++
				$currentIndex++
			Write-Host
		}
	}
	Add-Content $logFile "$Env:COMPUTERNAME, $removedCount"
}
function showProfilesSize {
	Clear-Host
	$oldProfiles = getProfiles
	
	#	Main Script Loop
	$currentIndex = 1
	
	:OutsideLoop
	foreach($oldProfile in $oldProfiles) {
		foreach($SID in $IgnoreList) {
			if($oldProfile.SID -eq $sid) {
				Write-Host "Profile will be skipped by script:" $oldProfile.LocalPath (Get-ChildItem $oldProfile.LocalPath -recurse | Measure-Object -property length -sum)
				continue OuterLoop
			}
		}
		if($skip -eq "False"){
			Write-Host
			Write-Host -ForegroundColor Yellow "Do you wish to delete" $oldProfile.LocalPath "? (y)es, (n)o, (q)uit" 
			$userInput = Read-Host
			checkResponse($userInput)
		}
		elseif($skip -eq "True"){
			Write-Host
				#	Delete the profile.
				Write-Host -ForegroundColor Yellow "Currently deleting" $oldProfile.LocalPath "("$currentIndex "of" $oldProfiles.Count ")"
				$oldProfile.Delete()
				Write-Host -ForegroundColor Green "Done!"
					$removedCount++
				$currentIndex++
			Write-Host
		}
	}
}
function mainMenu(){
	while($mainInput -ne "q"){
		Write-Host -ForegroundColor magenta "Jeff's Powershell Cleanup Script!"
		[Environment]::NewLine
		Write-Host " 1 - Run Script"
		Write-Host " 2 - Show Profiles"
		Write-Host " 3 - Automatic Mode (no prompts)"
		[Environment]::NewLine
		$mainInput = Read-Host "Choice (q)uit"
		
		switch -wildcard ($mainInput){
			"1" { loopThroughProfiles }
			"2" { showProfilesSize }
			"3" { loopThroughProfiles("True") }
			"q*" { $mainInput = "q" }
			default { 
				Clear-Host
				Write-Host -ForegroundColor Red "Invalid Response Entered.."
				[Environment]::NewLine
			}
		}
	}
}

<#		START OF SCRIPT		#>

Clear-Host

#	Check for SILENT mode.
if($silent -eq "silent"){
	Write-Host -ForegroundColor Magenta "Running in silent mode."
	loopThroughProfiles("True")
	exit
}

#	Start normally.
mainMenu

<#		END OF SCRIPT	#>