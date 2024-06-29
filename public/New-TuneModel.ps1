function New-TuneModel {
    <#
    .SYNOPSIS
    Creates a new fine-tuned model.

    .DESCRIPTION
    New-TuneModel initiates the process of creating a new fine-tuned model based on a specified base model and training data.

    .PARAMETER FilePath
    The path to the training file (.jsonl) used for fine-tuning.

    .PARAMETER Model
    The base model to use for fine-tuning. Can be one of the predefined models or a fine-tuned model (starting with "ft:").
    Default is "gpt-3.5-turbo-0125".

    .PARAMETER Append
    If specified, appends all files to the same model. If not used, a new model will be created for each file.

    .EXAMPLE
    New-TuneModel -FilePath .\sample\data.jsonl -Model gpt-3.5-turbo-0125

    Creates a new fine-tuned model using the data.jsonl file and the gpt-3.5-turbo-0125 base model.

    .EXAMPLE
    Get-ChildItem *.jsonl | New-TuneModel -Model ft:gpt-3.5-turbo-0613:my-org:custom_model:7p4lURx -Append

    Creates a new fine-tuned model by appending all .jsonl files in the current directory to an existing fine-tuned model.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ Test-Path $PSItem })]
        [System.IO.FileInfo]$FilePath,
        [Parameter(Position = 0)]
        [ArgumentCompleter({
                param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                $script:ValidModels | Where-Object { $_ -like "$WordToComplete*" }
            })]
        [string]$Model = "gpt-3.5-turbo-0125",
        [switch]$Append
    )
    process {
        if ($PSCmdlet.ShouldProcess("Fine-tuning model $Model using training file $FilePath")) {
            # Upload the file and get the file ID
            $basename = Get-ChildItem $FilePath | Select-Object -ExpandProperty BaseName
            $fileId = Send-TuneFile -FilePath $FilePath | Select-Object -ExpandProperty Id
            Write-Verbose "Uploaded $FilePath with ID $fileId"

            # Start the tune job
            Write-Verbose "Starting fine-tuning job for model $Model with FileId $fileId"
            $tuneJobId = Start-TuneJob -Id $fileId -Model $Model | Select-Object -ExpandProperty Id
            Write-Verbose "Started fine-tuning job $tuneJobId"

            # Initialize the progress bar
            $progress = @{
                Status          = "Waiting for fine-tuning for $basename to complete"
                Activity        = "Fine-tuning $Model"
                PercentComplete = 0
            }
            Write-Progress @progress

            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            # Check the status every 5 seconds
            do {
                $jobStatus = Get-TuneJob -Id $tuneJobId
                Write-Verbose "Got info for tune job $tuneJobId"

                # Update progress bar
                if ($true) {
                    $progress.PercentComplete = ($progress.PercentComplete) + 1
                }
                Write-Progress @progress

                if ($jobStatus.status -in "failed", "cancelled") {
                    <# statuses: running, succeeded, failed, cancelled #>
                    $tunejob = Get-TuneJob -Id $tuneJobId

                    throw "Fine-tuning job $tuneJobId for file $basename failed: $($tunejob.error.message)"
                    # not sure if it needs a throw and a break?
                    break
                }

                if ($jobStatus.status -eq "succeeded") {
                    $script:currentmodel = $Model = $jobStatus.fine_tuned_model
                    Write-Verbose "Your new model is named $script:currentmodel and will now be used by default when executing Invoke-TuneChat"
                    break
                } else {
                    Write-Verbose "Fine-tuning job $tuneJobId is still running"
                }

                # Restart progress if it gets to 100 without a fine_tuned_model value
                if ($progress.PercentComplete -ge 100) {
                    $progress.PercentComplete = 0
                }
                Start-Sleep -Seconds 15
            } while ($true)
            $null = $stopwatch.Stop()

            Write-Verbose "Tuning took $($stopwatch.Elapsed)"


            # Initialize the progress bar
            $progressparm = @{
                Status          = "Fine tuning complete! Now waiting for the new model, $script:currentmodel, to be ready.."
                Activity        = "Fine-tuning $Model"
                PercentComplete = ($progress.PercentComplete) + 1
            }
            Write-Progress @progressparm

            # Use ChatGPT to inform the user about the new model
            Start-Sleep 25
            $params = @{
                Message       = "Respond only saying: 'Say hello to your new model, $script:currentmodel'"
                Model         = $script:currentmodel
                ErrorAction   = "SilentlyContinue"
                ErrorVariable = "weberror"
            }
            Invoke-TuneChat @params
            if ($weberror) {
                Write-Warning "This happens sometimes :/ Seems like the new model needs a nap, trying again in 10 seconds"
                Start-Sleep 10

                $params = @{
                    Message     = "Respond only saying: 'Say hello to your new model, $script:currentmodel'"
                    Model         = $script:currentmodel
                    ErrorAction   = "SilentlyContinue"
                    ErrorVariable = "weberror2"
                }
                Invoke-TuneChat @params

                if ($weberror2) {
                    Write-Output "Fine, since ChatGPT won't tell you, your new model is $script:currentmodel"
                }
            }
        }
    }
}