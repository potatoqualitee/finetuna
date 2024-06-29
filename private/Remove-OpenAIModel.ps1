function Remove-OpenAIModel {
    [CmdletBinding(DefaultParameterSetName = 'Id')]
    [OutputType([pscustomobject])]
    param (
        [Parameter(ParameterSetName = 'Models', Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [psobject[]]$Model,

        [Parameter(ParameterSetName = 'Id', Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('model_id')]
        [Alias('Id')]   # for backward compatibility
        [string[]][UrlEncodeTransformation()]$ModelId,

        [Parameter()]
        [int]$TimeoutSec = 0,

        [Parameter()]
        [ValidateRange(0, 100)]
        [int]$MaxRetryCount = 0,

        [Parameter()]
        [OpenAIApiType]$ApiType = [OpenAIApiType]::OpenAI,

        [Parameter()]
        [System.Uri]$ApiBase,

        [Parameter(DontShow)]
        [string]$ApiVersion,

        [Parameter()]
        [ValidateSet('openai', 'azure', 'azure_ad')]
        [string]$AuthType = 'openai',

        [Parameter()]
        [securestring][SecureStringTransformation()]$ApiKey,

        [Parameter()]
        [Alias('OrgId')]
        [string]$Organization,

        [Parameter()]
        [System.Collections.IDictionary]$AdditionalQuery,

        [Parameter()]
        [System.Collections.IDictionary]$AdditionalHeaders,

        [Parameter()]
        [object]$AdditionalBody
    )
    process {
        # Get API context
        $OpenAIParameter = Get-OpenAIAPIParameter -EndpointName 'Models' -Parameters $PSBoundParameters -ErrorAction Stop

        # Get Models id
        if ($PSCmdlet.ParameterSetName -eq 'Models') {
            $ModelId = $Model.id
        }
        if (-not $ModelId) {
            Write-Error -Exception ([System.ArgumentException]::new('Could not retrieve Models id.'))
            return
        }

        foreach ($id in $ModelId) {
            #region Construct Query URI
            $UriBuilder = [System.UriBuilder]::new($OpenAIParameter.Uri)
            $UriBuilder.Path += "/$id"
            $QueryUri = $UriBuilder.Uri
            #endregion

            #region Send API Request
            $params = @{
                Method            = 'Delete'
                Uri               = $QueryUri
                ContentType       = $OpenAIParameter.ContentType
                TimeoutSec        = $OpenAIParameter.TimeoutSec
                MaxRetryCount     = $OpenAIParameter.MaxRetryCount
                ApiKey            = $OpenAIParameter.ApiKey
                AuthType          = $OpenAIParameter.AuthType
                Organization      = $OpenAIParameter.Organization
                AdditionalQuery   = $AdditionalQuery
                AdditionalHeaders = $AdditionalHeaders
                AdditionalBody    = $AdditionalBody
            }
            try {
                $Response = Invoke-OpenAIAPIRequest @params | ConvertFrom-Json
                Write-Verbose ('The Models with id "{0}" has been deleted.' -f $Response.id)
            } catch {
                Write-Error -Exception $_
                continue
            }
        }
    }
}