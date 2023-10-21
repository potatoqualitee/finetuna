function Set-TuneConfig {
    <#
        .SYNOPSIS
            Sets the configuration for interacting with AI services.

        .DESCRIPTION
            This function allows the user to specify which AI service to use and provide the necessary API key for authentication.

        .PARAMETER Service
            The AI service to use. Default is 'OpenAI'.

        .PARAMETER ApiKey
            The API key for the selected service. If not provided, it will use the environment variable corresponding to the service.

        .EXAMPLE
            Set-TuneConfig -Service 'OpenAI' -ApiKey 'your-api-key-here'

        .EXAMPLE
            Set-TuneConfig -Service 'GoogleBard' -ApiKey 'your-api-key-here'
    #>

    [CmdletBinding()]
    param (
        [string]$Service = 'OpenAI',
        [string]$ApiKey  = $env:OpenAIKey
    )
    process {
        $script:CurrentService = $Service

        switch ($Service) {
            'OpenAI' { $script:CurrentApiKey = $ApiKey -or $env:OpenAIKey }
            'GoogleBard' { $script:CurrentApiKey = $ApiKey -or $env:GoogleBardKey }
            'AnthropicClaude' { $script:CurrentApiKey = $ApiKey -or $env:AnthropicClaudeKey }
            'Perplexity' { $script:CurrentApiKey = $ApiKey -or $env:PerplexityKey }
            default { throw "Service $Service is not supported." }
        }
    }
}
