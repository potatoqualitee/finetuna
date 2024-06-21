function Clear-TuneProvider {
    <#
    .SYNOPSIS
        Clears the OpenAI provider configuration for finetuna.

    .DESCRIPTION
        The Clear-TuneProvider function clears the OpenAI provider configuration by removing the persisted configuration file and resetting the module-scoped configuration object.

    .EXAMPLE
        PS C:\> Clear-TuneProvider

        This example clears the OpenAI provider configuration for finetuna.
    #>
    [CmdletBinding()]
    param ()

    $configFile = Join-Path -Path $script:configdir -ChildPath config.json

    if (Test-Path -Path $configFile) {
        Remove-Item -Path $configFile -Force
    }

    $script:currentmodel = "gpt-4o"
    $env:OpenAIKey = $null
    $PSDefaultParameterValues["*:ApiKey"] = $null

    # Clear any other module-specific variables or settings here

    Write-Verbose "OpenAI provider configuration for finetuna reset to default."
    Get-TuneProvider
}