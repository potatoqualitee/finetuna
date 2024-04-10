function Invoke-RestMethod2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Uri,
        [ValidateSet("GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS", "MERGE", "TRACE")]
        [string]$Method = "GET",
        [string]$Body,
        [HashTable]$Headers,
        [string]$UserAgent,
        [string]$ContentType,
        [psobject]$Form,
        [Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
        [string]$SessionVariable,
        [PSCredential]$Credential,
        [switch]$UseBasicParsing,
        [switch]$DisableKeepAlive,
        [int]$TimeoutSec,
        [int]$MaximumRedirection,
        [Uri]$Proxy,
        [PSCredential]$ProxyCredential,
        [switch]$ProxyUseDefaultCredentials,
        [switch]$PassThru,
        [switch]$NoProxy,
        [switch]$PreserveAuthorizationOnRedirect,
        [bool]$Raw
    )

    $vbpref = $VerbosePreference
    $VerbosePreference = 'SilentlyContinue'

    $israw = [bool]$Raw
    $null = $PSBoundParameters.Remove("Raw")

    if (-not $script:WebSession) {
        Write-Verbose "Establishing Connection"
        $null = Connect-TuneService
    }

    $results = Invoke-RestMethod @PSBoundParameters
    $VerbosePreference = $vbpref

    Write-Verbose "Prompt tokens: $($results.usage.prompt_tokens)"
    Write-Verbose "Completion tokens: $($results.usage.completion_tokens)"
    Write-Verbose "Total tokens: $($results.usage.total_tokens)"

    if ($israw) {
        return $results
    } elseif ($results.choices.message.content) {
        $null = $script:jsonmsg.Add($results.choices.message)
        $results.choices.message.content
    } elseif ($results.data) {
        $results.data
    } else {
        $results
    }
}