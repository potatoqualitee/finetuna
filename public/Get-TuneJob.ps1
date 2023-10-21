function Get-TuneJob {
    <#
    .SYNOPSIS
    Gets a list of fine-tuning jobs from the OpenAI API.

    .DESCRIPTION
    The Get-TuneJob cmdlet sends a GET request to the OpenAI API to retrieve a list of fine-tuning jobs.

    .EXAMPLE
    Get-TuneJob

    This command gets a list of fine-tuning jobs from the OpenAI API.
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("training_file")]
        [string]$Id
    )
    process {
        if ($Id) {
            foreach ($jobid in $Id) {
                $url = "https://api.openai.com/v1/fine_tuning/jobs/$jobid"
                Write-Verbose "Getting $url"
                $params = @{
                    Uri    = $url
                    Method = "GET"
                }
                Invoke-RestMethod2 @params
            }
        } else {
            $url = "https://api.openai.com/v1/fine_tuning/jobs"
            Write-Verbose "Getting $url"
            $params = @{
                Uri    = $url
                Method = "GET"
            }
            Invoke-RestMethod2 @params
        }
    }
}