<#
	Title: 		Resolve Hostnames
	Version:	2017.04.03
	
	Summary:	Resolves a list of hostnames to IP addresses.
#>

Clear-Host

Get-Content "hostnames.txt" | Foreach-Object {
	[Net.DNS]::GetHostEntry($_)
} | Out-File "output2.txt"