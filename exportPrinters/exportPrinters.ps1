<#
	Project:	Export Shared Printers from Print Servers
	Date:		2016/10/5
	Author:		Jeff Reed
	
	Purpose:	Exports the shared printers on specified servers to a CSV.
#>

#	Delete CSV if already exists.
Remove-Item -Path 'printersExported.csv'

#	Loop through all print servers from file and append to CSV.
$printservers = get-content "PrintServers.txt"
foreach($server in $printservers) {
	Get-WMIObject -class Win32_Printer -computer $server | Select Name,Comment,PortName | Export-CSV -Append -path 'printersExported.csv'
	}
	
# Open newly created file.
Invoke-Expression ".\printersExported.csv"