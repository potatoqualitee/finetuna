function Get-TuneJob {
    <#
    .SYNOPSIS
    Gets a list or a specific fine-tuning job from the OpenAI API.

    .DESCRIPTION
    The Get-TuneJob cmdlet sends a GET request to the OpenAI API to retrieve a list of fine-tuning jobs or a specific job.

    .PARAMETER Id
    Optional ID of the fine-tuning job to retrieve.

    .PARAMETER Raw
    Optional switch to return the raw response from the API.

    .EXAMPLE
    Get-TuneJob

    This command gets a list of fine-tuning jobs from the OpenAI API.

    .EXAMPLE
    Get-TuneJob -Id "job-1234"

    This command retrieves the fine-tuning job with the ID "job-1234" from the OpenAI API.
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("JobId")]
        [string]$Id,
        [switch]$Raw
    )
    process {
        $OpenAIParameter = Get-OpenAIAPIParameter -Parameter $script:bigparms -Endpoint FineTuning.Jobs

        if ($Id) {
            $Uri = "{0}/{1}" -f $OpenAIParameter.Uri, $Id
        } else {
            $Uri = $OpenAIParameter.Uri
        }

        $params = @{
            Method       = 'Get'
            Uri          = $Uri
            ContentType  = $OpenAIParameter.ContentType
            ApiKey       = $OpenAIParameter.ApiKey
            AuthType     = $OpenAIParameter.AuthType
            Organization = $OpenAIParameter.Organization
        }

        if ($Raw) {
            $params['ReturnRawResponse'] = $true
        }

        $Response = Invoke-OpenAIAPIRequest @params

        if (-not $Raw) {
            $Response = $Response | ConvertFrom-Json
            if ($Response.data) {
                $Response.data | ForEach-Object {
                    #splat add-member
                    $splat = @{
                        MemberType = 'NoteProperty'
                        Name       = 'PSTypeName'
                        Value      = 'PSOpenAI.FineTuningJob'
                        PassThru   = $true
                    }
                    $PSItem | Add-Member @splat
                }
            } else {
                # splat Add-Member with a hashtable
                $splat = @{
                    MemberType = 'NoteProperty'
                    Name       = 'PSTypeName'
                    Value      = 'PSOpenAI.FineTuningJob'
                    PassThru   = $true
                }
                $Response | Add-Member @splat
            }
        }

        Write-Output $Response
    }
}