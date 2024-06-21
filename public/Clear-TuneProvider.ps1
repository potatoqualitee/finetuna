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

    $script:currentmodel = "gpt-4o"

    $configFile = Join-Path -Path $script:configdir -ChildPath config.json

    if (Test-Path -Path $configFile) {
        Remove-Item -Path $configFile -Force
    }

    $null = Clear-OpenAIContext
    $env:OPENAI_API_KEY = $null
    $env:OPENAI_API_BASE = $null

    if ($global:OPENAI_API_BASE) {
        Write-Verbose "Removing OPENAI_API_KEY from global scope."
        $null = Remove-Variable -Name OPENAI_API_BASE -Scope Global -Force
    }
    if ($global:OPENAI_API_KEY) {
        Write-Verbose "Removing OPENAI_API_KEY from global scope."
        $null = Remove-Variable -Name OPENAI_API_KEY -Scope Global -Force
    }
    if ($env:OPENAI_API_KEY) {
        Write-Verbose "Removing OPENAI_API_KEY from environment."
        $null = Remove-Variable -Name OPENAI_API_KEY -Scope Environment -Force
    }
    if ($env:OPENAI_API_BASE) {
        Write-Verbose "Removing OPENAI_API_BASE from environment."
        $null = Remove-Variable -Name OPENAI_API_BASE -Scope Environment -Force
    }
    $defaults = Get-Variable -Name PSDefaultParameterValues -Scope Global -ValueOnly
    if ($defaults["*:ApiKey"]) {
        Write-Verbose "Removing default ApiKey from PSDefaultParameterValues."
        $null = $defaults.Remove("*:ApiKey")
    }

    Write-Verbose "OpenAI provider configuration reset to default."
    Get-OpenAIProvider
}