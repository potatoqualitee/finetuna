function Wait-TuneJob {
    <#
    .SYNOPSIS
    Waits for a fine-tuning job to complete.

    .DESCRIPTION
    Wait-TuneJob polls the status of a fine-tuning job until it reaches a terminal state (succeeded, failed, or cancelled).

    .PARAMETER JobId
    The ID of the fine-tuning job to wait for. This parameter is mandatory and can be piped in from Start-TuneJob.

    .PARAMETER Interval
    The interval (in seconds) at which to poll the job status. Default is 5 seconds.

    .EXAMPLE
    Start-TuneJob -FileId file-abc123 -Model gpt-3.5-turbo-0125 | Wait-TuneJob

    Starts a new fine-tuning job and waits for it to complete.

    .EXAMPLE
    Wait-TuneJob -JobId ftjob-JAOwjiw2AwvxVXL0EtV5gdmu -Interval 10

    Waits for the specified fine-tuning job to complete, polling every 10 seconds.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias("Id")]
        [string]$JobId,
        [Parameter()]
        [int]$Interval = 5
    )
    process {
        $OpenAIParameter = Get-OpenAIAPIParameter -EndpointName FineTuning.Jobs

        $progressParams = @{
            Activity = "Waiting for fine-tuning job $JobId"
            Status = "Starting..."
        }
        Write-Progress @progressParams

        while ($true) {
            $params = @{
                Method       = 'GET'
                Uri          = "$($OpenAIParameter.Uri)/$JobId"
                ApiKey       = $OpenAIParameter.ApiKey
                AuthType     = $OpenAIParameter.AuthType
                Organization = $OpenAIParameter.Organization
            }
            $job = Invoke-OpenAIAPIRequest @params | ConvertFrom-Json

            $progressParams.Status = "Status: $($job.status)"
            Write-Progress @progressParams

            Write-Verbose "Job status: $($job.status)"

            if ($job.status -in @('succeeded', 'failed', 'cancelled')) {
                Write-Progress @progressParams -Completed
                return $job
            }

            Start-Sleep -Seconds $Interval
        }
    }
}