<# 
.SYNOPSIS
    Finds stale computer objects in ADMSU

.DESCRIPTION
    Gets time stamps for all computers in the domain that have not logged in since after specified date.

.EXAMPLE
    ./Get-StaleComputers.ps1 -SearchBase "OU=PC,OU=Workstations,DC=admsu,DC=montclair,DC=edu" -Date 04/20/11

.PARAMETER SearchBase
    The OU in which to search for stale computer objects

.PARAMETER Date
    The date to find computer objects older than, in MM/DD/YYY format, eg. 10/28/1981

.PARAMETER OutputFile
    (Optional) The path and filename of a CSV file to output the result set to, eg. C:\tools\Stale-Computers-042011.csv

.NOTES
    This script must be run as a user that has at least read permissions on the OU specified in SearchBase

.LINK
    https://security.montclair.edu
#>
 
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [string]$SearchBase,
    
   [Parameter(Mandatory=$True)]
   [string]$Date,

   [Parameter()]
   [string]$OutputFile
)

$Time = get-date ($Date)
 
# Get all AD computers with lastLogonTimestamp less than our time
 
if ($OutputFile){
    Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -SearchBase $searchbase -Properties LastLogonTimeStamp |
    select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} |
    Export-Csv -Path $OutputFile
}
else {
    # Output hostname and lastLogonTimestamp into objects
    Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -SearchBase $searchbase -Properties LastLogonTimeStamp |
    select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}
}