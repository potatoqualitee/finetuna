function Set-TuneProvider {
    <#
    .SYNOPSIS
    Sets the configuration for a tune provider, either OpenAI or Azure OpenAI.

    .DESCRIPTION
    The Set-TuneProvider function configures the PowerShell session to use either OpenAI or Azure"s OpenAI services by setting various parameters such as the API Uri, API Key, API Version, and Deployment Name for Azure OpenAI.

    .PARAMETER Provider
    The provider for AI services. Can be "OpenAI" or "AzureOpenAI". The default is "OpenAI".

    .PARAMETER ApiUri
    The API Uri for Azure OpenAI services. This parameter is required when using "AzureOpenAI" as the provider.

    .PARAMETER ApiKey
    The API Key for accessing the chosen provider"s services. This parameter is required for AzureOpenAI.

    .PARAMETER ApiVersion
    The version of the API for Azure OpenAI services. This parameter is required when using "AzureOpenAI" as the provider.

    .PARAMETER DeploymentName
    The name of the deployment for Azure OpenAI services. This parameter is required when using "AzureOpenAI" as the provider.

    .EXAMPLE
    Set-TuneProvider -Provider OpenAI

    This example configures the session to use OpenAI"s services.

    .EXAMPLE
    $azureParams = @{
        Provider = "AzureOpenAI"
        ApiUri = "https://your-azure-api-uri"
        ApiKey = "your-api-key"
        ApiVersion = "2022-01-01"
        DeploymentName = "your-deployment-name"
    }
    Set-TuneProvider @azureParams

    This example demonstrates how to configure the session to use Azure OpenAI services by using splatting to pass parameters to the Set-TuneProvider function. Splatting allows for a cleaner and more readable way to pass a set of parameters.

    https://learn.microsoft.com/en-us/azure/ai-services/openai/reference#rest-api-versioning

    .NOTES
    When setting Azure as the provider, all parameters (ApiUri, ApiKey, ApiVersion, DeploymentName) are required.

    #>
    [CmdletBinding()]
    param(
        [ValidateSet("AzureOpenAI", "OpenAI")]
        [string]$Provider = "OpenAI",
        [string]$ApiUri,
        [string]$ApiKey,
        [string]$ApiVersion = "2024-02-15-preview",
        [string]$DeploymentName
    )


    if ($Provider -eq "OpenAI") {
        $script:baseUrl = "https://api.openai.com/v1"
        Write-Verbose "BaseURL set to $baseUrl"
        $null = Set-OAIProvider $Provider
    } else {
        # It"s Azure
        if ($null -in $ApiUri, $ApiKey, $ApiVersion, $DeploymentName) {
            throw "When setting Azure as the provider, the following are required: ApiURI, ApiKey, ApiVersion, DeploymentName"
        }

        if (-not $script:AzOAISecrets) {
            $script:AzOAISecrets = @{}
        }

        $script:AzOAISecrets["apiURI"] = $ApiUri
        $script:AzOAISecrets["apiKEY"] = $ApiKey
        $script:AzOAISecrets["apiVersion"] = $ApiVersion
        $script:AzOAISecrets["deploymentName"] = $DeploymentName

        $script:baseUrl = $AzOAISecrets.apiURI
        Write-Verbose "BaseURL set to $baseUrl"

        $secrets = @{
            apiURI         = $ApiUri
            apiVersion     = $ApiVersion
            apiKey         = $ApiKey
            deploymentName = $DeploymentName
        }

        $null = Set-OAIProvider AzureOpenAI
        $null = Set-AzOAISecrets @secrets
    }

    Write-Verbose "Setting provider to $Provider"
    $script:OAIProvider = $Provider
}