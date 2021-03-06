<#
	Project:	Ping Computers
	Date:		12/11/2015
	Author:		Jeff Reed
	
	Purpose:	Scans a list of hostnames/IPs from a CSV and 
				outputs the status in an easy to read HTML format.
#>

#Import file
$hostsFile = Import-Csv computers.csv

#Assign variables to keep the user informed
$hostsFileIndex = 1
$hostsFileCount = $hostsFile.count

Write-Host "Beginning network scan.."
$hostsFile | ForEach-Object {
	$hostname = $_.hostname
	
	if (Test-Connection -ComputerName $hostName -Count 1 -Quiet) {
		$_.status = "<font color='green'>ok</font>"
	} else {
		#$_.status = "<font color='red'>error</font>"
	}
	Write-Host "Scanned $hostsFileIndex of $hostsFileCount"
	$hostsFileIndex++
}

$html = "<head><title>Hostname Scanner</title></head>"
$html = "<style>"
$html = $html + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$html = $html + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;}"
$html = $html + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;}"
$html = $html + "</style>"
$html = $html +  "<table>"
$html = $html +  "<th>Location</th><th>Hostname</th><th>Status</th>"

$hostsFile | ForEach-Object {
	$html = $html + "<tr>"
		$html = $html + "<td align='center'>" + $_.location + "</td>" + "<td align='center'>" + $_.hostname + "</td>" + "<td align='center'>" + $_.status + "</td>"
	$html = $html + "</tr>"	
}
$html = $html +  "</table>"

#Save the formatted file as HTML.
$html | Out-File ".\output.html"
Invoke-Expression ".\output.html"