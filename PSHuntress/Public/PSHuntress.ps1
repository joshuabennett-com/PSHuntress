
$HUNTRESS_DEFAULT_URI = 'https://api.huntress.io/v1/'
$HuntressFilName = 'Huntress_API_Settings.json'
$HuntressSettingsFile = "$env:APPDATA\$HuntressFilName"


# https://api.huntress.io/docs#introduction
# https://api.huntress.io/docs/preview#/
# Get-Date -Format "o" in Powershell to get the date format needed

Function Get-HuntressAccount {
    [CmdletBinding()]
    Param()    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        $Begin = Get-Date
        $RelativeURI = "account"

        WI -Prefix HUNTRESS -Message "Starting $($Myinvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"
        WI -Prefix HUNTRESS -Message "Relative Api Url: $($RelativeURI)"
    }
    PROCESS {
        $Params.URI = $HUNTRESS_BASE_URI + $RelativeURI

        Try {
            $Response = Invoke-RestMethod @Params
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Response.Account
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}

Function Get-HuntressOrganizations {
    [CmdletBinding()]
    Param(
        [Parameter(ParameterSetName = "HTTPQuery")]
        [int]$page,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [ValidateRange(1, 500)]
        [int]$limit,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$created_at_min,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$created_at_max,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$updated_at_min,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$updated_at_max
    )    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        [system.collections.arraylist]$Output = @()
        $Begin = Get-Date
        WI -Prefix HUNTRESS -Message "Starting $($MyInvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"

    }
    PROCESS {
        $ParamList = $Null
        $Data = $Null
        $CommandName = $MyInvocation.InvocationName
        $Parameters = (Get-Command -Name $CommandName).Parameters
        $Parameters.Values.Getenumerator() | Where-Object { 'HTTPQuery' -in $_.Attributes.Parametersetname } | Foreach-Object { $ParamList += @{$_.Name = $_.Attributes.Parametersetname } }
        $PSBoundParameters.GetEnumerator() | Where-Object { $_.Key -in $ParamList.Keys } | ForEach-Object { $Data += @{$_.Key = $_.Value } }
        $Params.URI = $HUNTRESS_BASE_URI + "organizations?"
        If ($Null -ne $Data) {
            $Params.URI = New-HttpQueryString -uri $Params.URI -QueryParameter $Data
        }
        
        Try {
            $Response = Invoke-RestMethod @Params
            $Output.AddRange($Response.Organizations)
            WV -Prefix HUNTRESS -Message "Retrieved $($Response.Organizations.Count) items"
            If ($Response.Pagination.Next_page) {
                do {
                    $Params.URI = $Response.Pagination.Next_page_url
                    $Response = Invoke-RestMethod @Params
                    $Output.AddRange($Response.organizations)
                    WV -Prefix HUNTRESS -Message "Retrieved $($Response.Organizations.Count) items"
                } While ($Response.Pagination.Next_page)
            }
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Output
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}

Function Get-HuntressOrganization {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$id
    )    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        $Begin = Get-Date
        WI -Prefix HUNTRESS -Message "Starting $($Myinvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"
    }
    PROCESS {
        $Params.URI = $HUNTRESS_BASE_URI + "organizations/$id"
        Try {
            $Response = Invoke-RestMethod @Params
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Response.Organization
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}
Function Get-HuntressAgents {
    [CmdletBinding()]
    Param(
        [Parameter(ParameterSetName = "HTTPQuery")]
        [int]$organization_id,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [int]$page,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [ValidateRange(1, 500)]
        [int]$limit,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$created_at_min,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$created_at_max,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$updated_at_min,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$updated_at_max
    )    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        [system.collections.arraylist]$Output = @()
        $Begin = Get-Date
        WI -Prefix HUNTRESS -Message "Starting $($Myinvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"
    }
    PROCESS {
        $ParamList = $Null
        $Data = $Null
        $CommandName = $MyInvocation.InvocationName
        $Parameters = (Get-Command -Name $CommandName).Parameters
        $Parameters.Values.Getenumerator() | Where-Object { 'HTTPQuery' -in $_.Attributes.Parametersetname } | Foreach-Object { $ParamList += @{$_.Name = $_.Attributes.Parametersetname } }
        $PSBoundParameters.GetEnumerator() | Where-Object { $_.Key -in $ParamList.Keys } | ForEach-Object { $Data += @{$_.Key = $_.Value } }
        $Params.URI = "$HUNTRESS_BASE_URI/agents?"
        If ($Null -ne $Data) {
            $Params.URI = New-HttpQueryString -uri $Params.URI -QueryParameter $Data
        }
        
        Try {
            $Response = Invoke-RestMethod @Params
            $Output.AddRange($Response.Agents)
            WV -Prefix HUNTRESS -Message "Retrieved $($Response.Agents.Count) items"
            If ($Response.Pagination.Next_page) {
                do {
                    $Params.URI = $Response.Pagination.Next_page_url
                    $Response = Invoke-RestMethod @Params
                    $Output.AddRange($Response.Agents)
                    WV -Prefix HUNTRESS -Message "Retrieved $($Response.Agents.Count) items"
                } While ($Response.Pagination.Next_page)
            }
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Output
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}

Function Get-HuntressAgent {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$id
    )    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        $Begin = Get-Date
        WI -Prefix HUNTRESS -Message "Starting $($Myinvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"
    }
    PROCESS {
        $Params.URI = $HUNTRESS_BASE_URI + "agents/$id"
        Try {
            $Response = Invoke-RestMethod @Params
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Response.agent
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}
Function Get-HuntressIncidentReports {
    [CmdletBinding()]
    Param(
        [Parameter(ParameterSetName = "HTTPQuery")]
        [int]$organization_id,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [int]$page,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [ValidateRange(1, 500)]
        [int]$limit,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$updated_at_max,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$updated_at_min,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [ValidateSet('footholds', 'monitored_files', 'ransomware_canaries', 'antivirus_detections', 'process_detections')]
        [string]$indicator_type,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [ValidateSet('dismissed', 'sent', 'closed')]
        [string]$status,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [ValidateSet('low', 'high', 'critical')]
        [string]$severity,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$agent_id
    )    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        [system.collections.arraylist]$Output = @()
        $Begin = Get-Date
        WI -Prefix HUNTRESS -Message "Starting $($MyInvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"
    }
    PROCESS {
        $ParamList = $Null
        $Data = $Null
        $CommandName = $MyInvocation.InvocationName
        $Parameters = (Get-Command -Name $CommandName).Parameters
        $Parameters.Values.Getenumerator() | Where-Object { 'HTTPQuery' -in $_.Attributes.Parametersetname } | Foreach-Object { $ParamList += @{$_.Name = $_.Attributes.Parametersetname } }
        $PSBoundParameters.GetEnumerator() | Where-Object { $_.Key -in $ParamList.Keys } | ForEach-Object { $Data += @{$_.Key = $_.Value } }
        $Params.URI = $HUNTRESS_BASE_URI + "incident_reports?"
        If ($Null -ne $Data) {
            $Params.URI = New-HttpQueryString -uri $Params.URI -QueryParameter $Data
        }
        Try {
            $Response = Invoke-RestMethod @Params
            $Output.AddRange($Response.Incident_Reports)
            WV -Prefix HUNTRESS -Message "Retrieved $($Response.Incident_Reports.Count) items"
            If ($Response.Pagination.Next_page) {
                do {
                    $Params.URI = $Response.Pagination.Next_page_url
                    $Response = Invoke-RestMethod @Params
                    $Output.AddRange($Response.Incident_Reports)
                    WV -Prefix HUNTRESS -Message "Retrieved $($Response.Incident_Reports.Count) items"
                } While ($Response.Pagination.Next_page)
            }
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Output
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}


Function Get-HuntressIncidentReport {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$id
    )    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        $Begin = Get-Date
        WI -Prefix HUNTRESS -Message "Starting $($Myinvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"
    }
    PROCESS {
        $Params.URI = $HUNTRESS_BASE_URI + "incident_reports/$id"
        Try {
            $Response = Invoke-RestMethod @Params
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Response.Incident_report
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}
Function Get-HuntressReports {
    [CmdletBinding()]
    Param( 
        [Parameter(ParameterSetName = "HTTPQuery")]
        [int]$organization_id,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [int]$page,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [ValidateRange(1, 500)]
        [int]$limit,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$updated_at_max,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$updated_at_min,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$created_at_min,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$created_at_max,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$period_min,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$period_max,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [ValidateSet('monthly_summary', 'quarterly_summary', 'yearly_summary')]
        [string]$type
    )    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        [system.collections.arraylist]$Output = @()
        $Begin = Get-Date
        WI -Prefix HUNTRESS -Message "Starting $($Myinvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"
    }
    PROCESS {
        $ParamList = $Null
        $Data = $Null
        $CommandName = $MyInvocation.InvocationName
        $Parameters = (Get-Command -Name $CommandName).Parameters
        $Parameters.Values.Getenumerator() | Where-Object { 'HTTPQuery' -in $_.Attributes.Parametersetname } | Foreach-Object { $ParamList += @{$_.Name = $_.Attributes.Parametersetname } }
        $PSBoundParameters.GetEnumerator() | Where-Object { $_.Key -in $ParamList.Keys } | ForEach-Object { $Data += @{$_.Key = $_.Value } }
        $Params.URI = $HUNTRESS_BASE_URI + "reports?"
        If ($Null -ne $Data) {
            $Params.URI = New-HttpQueryString -uri $Params.URI -QueryParameter $Data
        }

        Try { 
            $Response = Invoke-RestMethod @Params
            $Output.AddRange($Response.Reports)
            WV -Prefix HUNTRESS -Message "Retrieved $($Response.Reports.Count) items"
            If ($Response.Pagination.Next_page) {
                do {
                    $Params.URI = $Response.Pagination.Next_page_url
                    $Response = Invoke-RestMethod @Params
                    $Output.AddRange($Response.Reports)
                    WV -Prefix HUNTRESS -Message "Retrieved $($Response.Reports.Count) items"
                } While ($Response.Pagination.Next_page)
            }
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Output
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}

Function Get-HuntressReport {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$id
    )    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        $Begin = Get-Date
        WI -Prefix HUNTRESS -Message "Starting $($Myinvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"
    }
    PROCESS {
        $Params.URI = $HUNTRESS_BASE_URI + "reports/$id"
        Try {
            $Response = Invoke-RestMethod @Params
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Response.report
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}
Function Get-HuntressBillingReports {
    [CmdletBinding()]
    Param( 
        [int]$id,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [int]$page,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [ValidateRange(1, 500)]
        [int]$limit,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$updated_at_max,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$updated_at_min,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$created_at_min,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [string]$created_at_max,
        [Parameter(ParameterSetName = "HTTPQuery")]
        [ValidateSet('open', 'paid', 'failed', 'partial_refund', 'full_refund')]
        [string]$status
    )    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        [system.collections.arraylist]$Output = @()
        $Begin = Get-Date
        WI -Prefix HUNTRESS -Message "Starting $($Myinvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"
    }
    PROCESS {
        $ParamList = $Null
        $Data = $Null
        $CommandName = $MyInvocation.InvocationName
        $Parameters = (Get-Command -Name $CommandName).Parameters
        $Parameters.Values.Getenumerator() | Where-Object { 'HTTPQuery' -in $_.Attributes.Parametersetname } | Foreach-Object { $ParamList += @{$_.Name = $_.Attributes.Parametersetname } }
        $PSBoundParameters.GetEnumerator() | Where-Object { $_.Key -in $ParamList.Keys } | ForEach-Object { $Data += @{$_.Key = $_.Value } }
        $Params.URI = $HUNTRESS_BASE_URI + "billing_reports?"
        If ($Null -ne $Data) {
            $Params.URI = New-HttpQueryString -uri $Params.URI -QueryParameter $Data
        }

        Try {
            $Response = Invoke-RestMethod @Params
            $Output.AddRange($Response.Billing_reports)
            WV -Prefix HUNTRESS -Message "Retrieved $($Response.Billing_reports.Count) items"
            If ($Response.Pagination.Next_page) {
                do {
                    $Params.URI = $Response.Pagination.Next_page_url
                    $Response = Invoke-RestMethod @Params
                    $Output.AddRange($Response.Billing_reports)
                    WV -Prefix HUNTRESS -Message "Retrieved $($Response.Billing_reports.Count) items"
                } While ($Response.Pagination.Next_page)
            }
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Output
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}


Function Get-HuntressBillingReport {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$id
    )    
    BEGIN {
        $Params = @{
            URI         = $HUNTRESS_BASE_URI
            Headers     = $HUNTRESS_HEADER
            Method      = "GET"
            ContentType = $HUNTRESS_TYPE
            ErrorAction = "STOP"
        }
        $Begin = Get-Date
        WI -Prefix HUNTRESS -Message "Starting $($Myinvocation.MyCommand)"
        WI -Prefix HUNTRESS -Message "Base Api Url: $($Params.URI)"
    }
    PROCESS {
        $Params.URI = $HUNTRESS_BASE_URI + "billing_reports/$id"
        Try {
            $Response = Invoke-RestMethod @Params
            $OK = $True
        }
        Catch {
            $OK = $False
            $RespStream = $_.Exception.Response.GetResponseStream()
            $Reader = New-Object System.IO.StreamReader($RespStream)
            $RespBodyJson = $Reader.ReadToEnd()
            $RespBody = $RespBodyJson | ConvertFrom-Json
            Write-warning $($RespBody.Error | Out-String)
        }
        If ($OK) {
            Write-Output $Response.billing_report
        }
    }
    END {
        $Runtime = New-TimeSpan -Start $Begin -End (Get-Date)
        WI -Prefix HUNTRESS -Message "Retrieved data in $Runtime"
        WI -Prefix HUNTRESS -Message "Ending $($Myinvocation.Mycommand)"
    } 
}


Function Add-HuntressAPIKey {
    [cmdletbinding()]
    Param (
        [Parameter(ValueFromPipeline)]
        [string]$HUNTRESS_API_KEY
    )
    If ($PSBoundParameters.ContainsKey('HUNTRESS_API_KEY')) {
        $HUNTRESS_API_KEY_INTERNAL = $HUNTRESS_API_KEY
        Set-Variable -Name "HUNTRESS_API_KEY" -Value $HUNTRESS_API_KEY_INTERNAL -Option ReadOnly -Scope Script -Force
    }
    else {
        $HUNTRESS_API_KEY_INTERNAL = Read-Host "Enter Huntress API key"
        Set-Variable -Name "HUNTRESS_API_KEY" -Value $HUNTRESS_API_KEY_INTERNAL -Option ReadOnly -Scope Script -Force
    }
}

Function Add-HuntressAPISecret {
    Param (
        [Parameter(ValueFromPipeline)]
        [string]$HUNTRESS_API_SECRET
    )
    If ($PSBoundParameters.ContainsKey('HUNTRESS_API_SECRET')) {
        $HUNTRESS_API_SECRET_INTERNAL = ConvertTo-SecureString $HUNTRESS_API_SECRET -AsPlainText -Force
        Set-Variable -Name "HUNTRESS_API_SECRET" -Value $HUNTRESS_API_SECRET_INTERNAL -Option ReadOnly -Scope Script -Force
    }
    else {
        $HUNTRESS_API_SECRET_INTERNAL = Read-Host "Enter Huntress API Secret" -AsSecureString
        Set-Variable -Name "HUNTRESS_API_SECRET" -Value $HUNTRESS_API_SECRET_INTERNAL -Option ReadOnly -Scope Script -Force
    }
}

Function Add-HuntressBaseURI {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline)]
        [string]$HUNTRESS_BASE_URI
    )
    If ($PSBoundParameters.ContainsKey('HUNTRESS_BASE_URI')) {
        $HUNTRESS_BASE_URI_INTERNAL = $HUNTRESS_BASE_URI
        If ($HUNTRESS_BASE_URI_INTERNAL.endswith('/')) {} else { $HUNTRESS_BASE_URI_INTERNAL = $HUNTRESS_BASE_URI_INTERNAL + '/' }
        Set-Variable -Name "HUNTRESS_BASE_URI" -Value $HUNTRESS_BASE_URI_INTERNAL -Option ReadOnly -Scope Script -Force
    }
    else {
        $HUNTRESS_BASE_URI_INTERNAL = Read-Host "Enter Huntress API base URI or press D for default URI (https://api.huntress.io/v1/)"
        If ($HUNTRESS_BASE_URI_INTERNAL -eq 'D') {
            Set-Variable -Name "HUNTRESS_BASE_URI" -Value $HUNTRESS_DEFAULT_URI -Option ReadOnly -Scope Script -Force
        }
        else {
            If ($HUNTRESS_BASE_URI_INTERNAL.endswith('/')) {} else { $HUNTRESS_BASE_URI_INTERNAL = $HUNTRESS_BASE_URI_INTERNAL + '/' }
            Set-Variable -Name "HUNTRESS_BASE_URI" -Value $HUNTRESS_BASE_URI_INTERNAL -Option ReadOnly -Scope Script -Force
        }
            
    }
}

Function Import-HuntressAPISettings {
    [CmdletBinding()]
    Param()
    $PlainTextMethod = { [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(($this))) }
    Try {
        WV -Prefix HUNTRESS -Message "Importing Huntress API settings from  $($HuntressSettingsFile)"
        $HuntressSettings = Get-Content -Path $HuntressSettingsFile -ErrorAction STOP
        $OK = $True
    }
    Catch {
        Write-Warning "Unable to get Huntress API settings file at $($HuntressSettingsFile)"
        Write-Warning "Run Add-HuntressAPIKey, Add-HuntressAPISecret, Add-HuntressBaseURI, Export-HuntressAPISettings, and Import-HuntressAPISettings"
        $OK = $False
    }
    If ($OK) {
        WV -Prefix HUNTRESS -Message "Setting Huntress API variables"
        $HuntressSettingsObject = $HuntressSettings | ConvertFrom-Json
        Set-Variable -Name "HUNTRESS_BASE_URI" -Value $HuntressSettingsObject.HUNTRESS_BASE_URI -Option ReadOnly -Scope Script -Force
        Set-Variable -Name "HUNTRESS_API_KEY" -Value $HuntressSettingsObject.HUNTRESS_API_KEY -Option ReadOnly -Scope Script -Force
        Set-Variable -Name "HUNTRESS_API_SECRET" -Value $($HuntressSettingsObject.HUNTRESS_API_SECRET | ConvertTo-SecureString) -Option ReadOnly -Scope Script -Force
        $HUNTRESS_API_SECRET | Add-Member -MemberType ScriptMethod -Name ToText -Value $PlainTextMethod -Force
        
        If ($HUNTRESS_API_KEY -and $HUNTRESS_API_SECRET -and $HUNTRESS_BASE_URI) {
            $huntressCreds = "$($HUNTRESS_API_KEY):$($HUNTRESS_API_SECRET.ToText())"
            $encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($huntressCreds))
            $Script:HUNTRESS_TYPE = "application/json"
            WV -Prefix HUNTRESS -Message "Creating Huntress API header"
            $Script:HUNTRESS_HEADER = @{
                Authorization = "Basic $encodedCredentials"
            }
        }
    }
}
Function Export-HuntressAPISettings {
    [CmdletBinding()]
    Param()
    If ($HUNTRESS_API_KEY -and $HUNTRESS_API_SECRET -and $HUNTRESS_BASE_URI) {
        $HuntressSecretSecureString = $HUNTRESS_API_SECRET | ConvertFrom-SecureString
        $HuntressSettingsObject = [PSCustomObject]@{
            HUNTRESS_API_KEY    = $HUNTRESS_API_KEY
            HUNTRESS_API_SECRET = $HuntressSecretSecureString
            HUNTRESS_BASE_URI   = $HUNTRESS_BASE_URI
        }
        WV -Prefix HUNTRESS -Message "Exporting Huntress API settings to $($HuntressSettingsFile)h"
        $HuntressSettingsObject | ConvertTo-Json | Out-File $HuntressSettingsFile
    }
    else {
        Write-Warning "Missing some settings values"
        Write-Warning "Run Add-HuntressAPIKey, Add-HuntressAPISecret, Add-HuntressBaseURI, and Export-HuntressAPISettings"
    }
}

Function WV {
    Param($prefix, $message, $File)
    $time = Get-Date -f MM-dd-HH:mm:ss:ffff
    Write-Verbose "$time [$($prefix.padright(10,' '))] $message"
    If ($File) {
        [pscustomobject]@{
            Time    = $time
            Prefix  = $Prefix
            Message = $Message
        } | Export-Csv -Path $File -Append -NoTypeInformation
    }
}
Function WD {
    Param($prefix, $message, $File)
    $time = Get-Date -f MM-dd-HH:mm:ss:ffff
    Write-Debug "$time [$($prefix.padright(10,' '))] $message"
    If ($File) {
        [pscustomobject]@{
            Time    = $time
            Prefix  = $Prefix
            Message = $Message
        } | Export-Csv -Path $File -Append -NoTypeInformation
    }
}

Function WI {
    Param($prefix, $message)
    $time = Get-Date -f MM-dd-HH:mm:ss:ffff
    Write-Information "$time [$($prefix.padright(10,' '))] $message"
}


Function New-HttpQueryString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$Uri,
        [Parameter(Mandatory)]
        [Hashtable]$QueryParameter
    )
    Add-Type -AssemblyName System.Web
    
    # Create a http name value collection from an empty string
    $nvCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    
    foreach ($key in $QueryParameter.Keys) {
        $nvCollection.Add($key, $QueryParameter.$key)
    }
    
    # Build the uri
    $uriRequest = [System.UriBuilder]$uri
    $uriRequest.Query = $nvCollection.ToString()
    return $uriRequest.Uri.OriginalString
}

Import-HuntressAPISettings
