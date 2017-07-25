# Rename Target Computer

$targetPC = Read-Host "Target Computer Name"
$newName = Read-Host "New Target Computer Name"
$userName = Read-Host "Domain\Username"

Rename-Computer -ComputerName $targetPC -NewName $newName -DomainCredential $userName -Force -PassThru -Confirm
