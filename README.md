# PSHuntress

# ![HuntressIcon] ![PowerShellIcon] Huntress PowerShell

This repository contains PowerShell cmdlets for interacting with the [Huntress](https://huntress.com) REST API.


# Installation 

### PowerShell Gallery

Run the following command in an elevated PowerShell session to install the rollup module for Huntress PowerShell cmdlets:

```powershell
Install-Module -Name PSHuntress
```

If you have an earlier version of the Huntress PowerShell modules installed from the PowerShell Gallery and would like to update to the latest version, run the following commands in an elevated PowerShell session:

```powershell
Update-Module -Name PSHuntress
```

## Authentication

Generate your API Key and API Secret from the [Huntress Dashboard](https://huntress.io/account/api_credentials). Store these values in a secure manner (e.g. a secure password manager), as they will not be shown again.

### Set credentials and base URI
```powershell
Add-HuntressAPIKey -HUNTRESS_API_KEY "YOUR_PUBLIC_KEY"
Add-HuntressAPISecret -HUNTRESS_API_SECRET "YOUR_PRIVATE_KEY"
Add-HuntressBaseURI -HUNTRESS_BASE_URI 'https://api.huntress.io/v1/'
```

### Import authentication credentials
```powershell
Export-HuntressAPISettings
Import-HuntressAPISettings
```

## Usage

All Huntress API documentation is available [here](https://api.huntress.io/docs). The current available cmdlets are listed below. Use the `get-help` cmdlet for more information.

### Huntress API Cmdlets
```powershell
Get-HuntressAccount
Get-HuntressOrganizations
Get-HuntressOrganization
Get-HuntressAgents
Get-HuntressAgent
Get-HuntressIncidentReports
Get-HuntressIncidentReport
Get-HuntressReports
Get-HuntressReport
Get-HuntressBillingReports
Get-HuntressBillingReport
```

### Examples & Help
```powershell
get-help Get-HuntressOrganizations
get-help Get-HuntressOrganizations -Examples
```



<!-- References -->
<!-- Local -->
[GitHubIssues]: https://github.com/joshuabennett-com/PSHuntress/issues

[HuntressIcon]: documentation/images/Huntress-32px.png
[PowershellIcon]: documentation/images/MicrosoftPowerShellCore-32px.png
[AzurePowerShelModules]: documentation/azure-powershell-modules.md
[DeveloperGuide]: documentation/development-docs/azure-powershell-developer-guide.md
