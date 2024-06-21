function Get-TuneJobEvent {
    <#
    .SYNOPSIS
    Retrieves a specific fine-tuning event from the API.

    .DESCRIPTION
    Sends a GET request to the API to retrieve a specified fine-tuning event.

    .PARAMETER Id
    The fine-tuning job object to retrieve its event.

    .EXAMPLE
    Get-ModelFineTune -Id "job-1234" | Get-TuneJobEvent

    This command retrieves the fine-tuning event of the job with the ID job-1234 from the API.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$Id
    )
    process {
        foreach ($eventid in $Id) {
            $OpenAIParameter = Get-OpenAIAPIParameter -Parameter $script:bigparms -Endpoint FineTuning.JobEvents
            $Uri = $OpenAIParameter.Uri -replace "\{0\}", $eventid -replace "\{1\}", "?limit=1000"

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
                            Value      = 'PSOpenAI.FineTuningJobEvent'
                            PassThru   = $true
                        }
                        $PSItem | Add-Member @splat
                    }
                } else {
                    # splat Add-Member with a hashtable
                    $splat = @{
                        MemberType = 'NoteProperty'
                        Name       = 'PSTypeName'
                        Value      = 'PSOpenAI.FineTuningJobEvent'
                        PassThru   = $true
                    }
                    $Response | Add-Member @splat
                }
            }

            Write-Output $Response
        }
    }
}