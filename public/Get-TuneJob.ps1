function Get-TuneJob {
    <#
    .SYNOPSIS
    Gets a list of fine-tuning jobs from the OpenAI API.

    .DESCRIPTION
    The Get-TuneJob cmdlet sends a GET request to the OpenAI API to retrieve a list of fine-tuning jobs.

    .PARAMETER Id
    Optional ID of the fine-tuning job.

    .PARAMETER Status
    Optional status of the fine-tuning job.

    .EXAMPLE
    Get-TuneJob

    This command gets a list of fine-tuning jobs from the OpenAI API.

    .EXAMPLE
    Get-TuneJob -Id job-1234

    Get a specific job

    .EXAMPLE
    Get-TuneJob -Status succeeded

    Get all jobs with a specific status
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("training_file", "JobId")]
        [string]$Id,
        [ValidateSet('succeeded', 'failed', 'running', 'cancelled')]
        [string]$Status
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
                if ($Status) {
                    Write-Verbose "Filtering by status $Status"
                    Invoke-RestMethod2 @params | Where-Object status -eq $Status
                } else {
                    Invoke-RestMethod2 @params
                }
            }
        } else {
            $url = "https://api.openai.com/v1/fine_tuning/jobs"
            Write-Verbose "Getting $url"
            $params = @{
                Uri    = $url
                Method = "GET"
            }
            if ($Status) {
                Write-Verbose "Filtering by status $Status"
                Invoke-RestMethod2 @params | Where-Object status -eq $Status
            } else {
                Invoke-RestMethod2 @params
            }
        }
    }
}