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
        [switch]$PreserveAuthorizationOnRedirect
    )

    if (-not $script:WebSession) {
        Write-Verbose "Establishing Connection"
        $null = Connect-TuneService
    }

    $results = Invoke-RestMethod @PSBoundParameters

    if ($results.choices.message.content) {
        $results.choices.message.content
    } elseif ($results.data) {
        $results.data
    } else {
        $results
    }
}