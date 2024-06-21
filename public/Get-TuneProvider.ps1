function Get-TuneProvider {
    <#
    .SYNOPSIS
        Retrieves the current OpenAI provider configuration for finetuna.

    .DESCRIPTION
        The Get-TuneProvider function retrieves the current OpenAI provider configuration for finetuna.
        It retrieves the configuration from the persisted configuration file if the -Persisted switch is used.

    .PARAMETER Persisted
        A switch parameter that determines whether to retrieve only the persisted configuration. By default, the function retrieves the session configuration.

    .PARAMETER PlainText
        A switch parameter that determines whether to return the API key in plain text. By default, the function masks the API key.

    .EXAMPLE
        Get-TuneProvider

        This example retrieves the current session's OpenAI provider configuration for finetuna.

    .EXAMPLE
        Get-TuneProvider -Persisted

        This example retrieves the persisted OpenAI provider configuration for finetuna.
    #>
    [CmdletBinding()]
    param(
        [switch]$Persisted,
        [switch]$PlainText
    )

    $configFile = Join-Path -Path $script:configdir -ChildPath config.json

    if ($Persisted) {
        if (Test-Path -Path $configFile) {
            Get-Content -Path $configFile -Raw | ConvertFrom-Json
        } else {
            Write-Warning "No persisted configuration found."
        }
    } else {
        $apiKey = $env:OpenAIKey
        if ($apiKey) {
            if (-not $PlainText) {
                $apiKey = $apiKey.Substring(0, 3) + "..." + $apiKey.Substring($apiKey.Length - 2)
            }
        }

        [pscustomobject]@{
            ApiKey       = $apiKey
            AuthType     = $PSDefaultParameterValues["*:AuthType"]
            ApiType      = if ($PSDefaultParameterValues["*:ApiBase"]) { "Azure" } else { "OpenAI" }
            Deployment   = $PSDefaultParameterValues["*:Deployment"]
            ApiBase      = $PSDefaultParameterValues["*:ApiBase"]
            ApiVersion   = $PSDefaultParameterValues["*:ApiVersion"]
            Organization = $null  # Add this if you implement organization support
            CurrentModel = $script:currentmodel
        }
    }
}