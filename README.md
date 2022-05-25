# PSHuntress
Implements all the current Huntress API commands in Powershell.

To use - 

Install-Module -name PSHuntress
Add-HuntressAPIKey -HUNTRESS_API_KEY '1234'
Add-HuntressAPISecret -HUNTRESS_API_SECRET 'mylittlesecret'
Add-HuntressBaseURI -HUNTRESS_BASE_URI 'https://api.huntress.io/v1/'
Export-HuntressAPISettings
Import-HuntressAPISettings

get-help Get-HuntressOrganizations
get-help Get-HuntressOrganizations -Examples

