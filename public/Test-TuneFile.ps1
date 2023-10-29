function Test-TuneFile {
    <#
        .SYNOPSIS
            Validates tune files before sending to model for training.

        .DESCRIPTION
            This function checks the file for validity. It verifies if the content is in the correct JSONL format and checks for mandatory fields.

        .PARAMETER FilePath
            Path to the file(s) to be validated.

        .PARAMETER First
            Tests only the first N lines from the file.

        .PARAMETER Last
            Tests only the last N lines from the file.

        .PARAMETER Skip
            Skips the first N lines from the file.

        .EXAMPLE
            Get-ChildItem *.jsonl | Test-TuneFile

        .EXAMPLE
            Test-TuneFile -FilePath C:\path\to\file.jsonl

        .EXAMPLE
            Test-TuneFile -FilePath C:\path\to\file.jsonl -First 10

            Tests the validity of the first 10 lines in the specified file.

        .EXAMPLE
            Get-ChildItem *.jsonl | Test-TuneFile -First 10

            Tests the validity of the first 10 lines in each .jsonl file in the current directory.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ return (Test-Path $_) })]
        [System.IO.FileInfo[]]$FilePath,
        [int]$First,
        [int]$Last,
        [int]$Skip
    )
    process {
        foreach ($file in $FilePath) {
            Write-Verbose ("Validating file: $file")
            $basename = (Get-ChildItem $file).BaseName
            $file = (Get-ChildItem $file).FullName
            $bigCounter = 0
            $lineCounter = 0
            $msgCounter = 0
            $isValid = $true

            try {
                $lines = Get-Content -Path $file | ConvertFrom-Json -ErrorAction Stop | Select-Object -First 10
            } catch {
                Write-Verbose "Invalid JSON in $basename"
                [PSCustomObject]@{
                    FileName = $basename
                    IsValid  = $false
                    Comment  = "Invalid JSON file: $PSItem"
                }
                continue
            }

            if ($lines.Count -lt 10) {
                Write-Verbose "$basename doesn't contain at least 10 lines."
                $isValid = $false
                [PSCustomObject]@{
                    FileName = $basename
                    IsValid  = $false
                    Comment  = "Training file has $(@($lines).count) example(s), but must have at least 10 examples"
                }
            }

            if ($PSBoundParameters.First) {
                $PSDefaultParameterValues['Select-Object:First'] = $First
            }
            if ($PSBoundParameters.Last) {
                $PSDefaultParameterValues['Select-Object:Last'] = $Last
            }
            if ($PSBoundParameters.Skip) {
                $PSDefaultParameterValues['Select-Object:Skip'] = $Skip
            }

            # stream it
            foreach ($line in (Get-Content -Path $file | ConvertFrom-Json | Select-Object)) {
                $bigCounter++
                Write-Verbose "Processing line $bigCounter"

                if (-not $line.messages) {
                    $isValid = $false
                    [PSCustomObject]@{
                        FileName = $basename
                        IsValid  = $false
                        Comment  = "Missing 'messages' key at line $bigCounter"
                    }
                }

                foreach ($msg in $line) {
                    $lineCounter++
                    $msgCounter = 0
                    if (-not ($msg.messages.role -contains "assistant")) {
                        $isValid = $false
                        [PSCustomObject]@{
                            FileName = $basename
                            IsValid  = $false
                            Comment  = "Missing 'assistant' role at $lineCounter"
                        }
                    }

                    foreach ($message in $msg.messages) {
                        $msgCounter++
                        Write-Verbose "Processing line $lineCounter.$msgCounter"

                        if (-not $message.role) {
                            $isValid = $false
                            [PSCustomObject]@{
                                FileName = $basename
                                IsValid  = $false
                                Comment  = "Missing 'role' key in 'messages' at line $lineCounter.$msgCounter"
                            }
                        }

                        if ($message.role -is [array]) {
                            $isValid = $false
                            [PSCustomObject]@{
                                FileName = $basename
                                IsValid  = $false
                                Comment  = "'role' key in 'messages' at line $lineCounter.$msgCounter is an array, but must be a string"
                            }
                        }

                        if (-not $message.content) {
                            $isValid = $false
                            [PSCustomObject]@{
                                FileName = $basename
                                IsValid  = $false
                                Comment  = "Missing 'content' key in 'messages' at line $lineCounter.$msgCounter"
                            }
                        }

                        if ($message.content -is [array]) {
                            $isValid = $false
                            [PSCustomObject]@{
                                FileName = $basename
                                IsValid  = $false
                                Comment  = "'content' key in 'messages' at line $lineCounter.$msgCounter is an array, but must be a string"
                            }
                        }
                    }
                }
            }

            if ($isValid) {
                [PSCustomObject]@{
                    FileName = $basename
                    IsValid  = $true
                    Comment  = "OK"
                }
            }
        }
    }
}
