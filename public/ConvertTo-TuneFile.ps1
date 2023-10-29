function ConvertTo-TuneFile {
    <#
        .SYNOPSIS
            Converts files to JSONL format for chatbot training.

        .DESCRIPTION
            This function takes various input types and converts them to JSONL format. Each line or row becomes an "assistant" message in the JSONL.

            This command is under development and made me realize that they really mean it when they say that you gotta have good data for your training model. This probably will make bad data.

        .PARAMETER InputObject
            The input to be converted. Can be a file path, FileInfo object, or a PSCustomObject.

        .PARAMETER SystemContent
            The system message for the JSONL file.

        .PARAMETER Include
            When converting a module, include examples in the JSONL file.

            Values include: Synopsis, Description, Parameters, Parameters

        .EXAMPLE
            Import-Module dbatools
            Get-Module dbatools | ConvertTo-TuneFile -SystemContent "You are a friendly dbatools support chatbot and PowerShell expert who helps people find the commands they need"

            This example demonstrates how to convert a dbatools module into a Tune file, defining the chatbot's persona as a friendly dbatools support expert.

        .EXAMPLE
            ConvertTo-TuneFile -InputObject C:\path\to\file.txt -SystemContent 'You are a friendly dbatools and PowerShell expert who offers tech support to DBAs and Systems Engineers'

            This example shows how to convert a text file into a Tune file, defining the chatbot's persona as a friendly tech support expert for dbatools and PowerShell.

        .EXAMPLE
            ConvertTo-TuneFile -InputObject C:\path\to\file.csv -SystemContent 'You are a chatbot'

            This example demonstrates converting a CSV file into a Tune file, with a simple system content defining the chatbot's persona.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject[]]$InputObject,
        [Parameter(Mandatory)]
        [string]$SystemContent,
        [ValidateSet('Synopsis', 'Description', 'Parameters', 'Examples')]
        [string[]]$Include = @( 'Synopsis', 'Description' )
    )
    process {
        $null = $PSDefaultParameterValues['*:Compress'] = $true
        foreach ($object in $InputObject) {
            $type = $null
            # Determine the type of InputObject
            if ($object -is [string] -and (Test-Path $object)) {
                $type = "path"
            } elseif ($object -is [System.IO.FileInfo]) {
                $type = "path"
            } elseif ($object.PSObject.TypeNames -match "PSCustomObject") {
                $type = "psobject"
            } elseif ($object.PSObject.TypeNames -match "PSModuleInfo") {
                # oh yeah!
                $type = "module"
            } else {
                $type = "unsupported"
            }

            # Process based on the file type
            switch ($type) {
                "path" {
                    foreach ($file in $object) {
                        Write-Verbose "Processing $file"
                        $extension = (Get-ChildItem $file).Extension
                        $basename = (Get-ChildItem $file).BaseName
                        $outputFilePath = Join-Path (Get-ChildItem $file).DirectoryName "$basename.jsonl"

                        switch ($extension) {
                            '.txt' {
                                $fileContent = Get-Content $file
                                $jsonlContent = @()

                                foreach ($line in $fileContent) {
                                    $json = @{
                                        messages = @(
                                            @{ role = 'system'; content = $SystemContent },
                                            @{ role = 'assistant'; content = $line }
                                        )
                                    } | ConvertTo-Json
                                    $jsonlContent += $json
                                }
                                $jsonlContent -join "`n" | Set-Content -Path $outputFilePath
                            }

                            '.csv' {
                                $csvContent = Import-Csv $file
                                $jsonlContent = @()

                                foreach ($row in $csvContent) {
                                    $json = @{
                                        messages = @(
                                            @{ role = 'system'; content = $SystemContent },
                                            @{ role = 'assistant'; content = $row }
                                        )
                                    } | ConvertTo-Json
                                    $jsonlContent += $json
                                }
                                $jsonlContent -join "`n" | Set-Content -Path $outputFilePath
                            }

                            '.pdf' {
                                $pdfContent = Import-PDFFile $file
                                $jsonlContent = @()

                                foreach ($line in $pdfContent) {
                                    $json = @{
                                        messages = @(
                                            @{ role = 'system'; content = $SystemContent },
                                            @{ role = 'assistant'; content = $line }
                                        )
                                    } | ConvertTo-Json
                                    $jsonlContent += $json
                                }
                                $jsonlContent -join "`n" | Set-Content -Path $outputFilePath
                            }

                            default {
                                throw "File type $extension is not supported."
                            }
                        }
                    }
                }

                "psobject" {
                    # ... (placeholder code for handling PSCustomObjects)
                }

                "module" {
                    $outputFilePath = Join-Path -Path $pwd -ChildPath "$($object.Name).jsonl"
                    $jsonlContent = New-Object System.Collections.ArrayList

                    $commands = Get-Command -Module $object.Name | Select-Object -First 10
                    $commandCount = $commands.Count
                    $i = 0

                    foreach ($command in $commands) {
                        $commandname = $command.Name
                        Write-Verbose "Processing command: $commandname"
                        $i++
                        $progress = @{
                            Status          = "Processing $commandname"
                            Activity        = "Processing $commandCount commands"
                            PercentComplete = (($i / $commandCount) * 100)
                        }
                        Write-Progress @progress
                        $commandHelp = Get-Help -Name $commandname

                        # For Synopsis
                        if ($Include -contains 'Synopsis') {
                            $synopsis = $commandHelp.Synopsis
                            if ($synopsis) {
                                Write-Verbose "Processing synopsis"
                                $userQuestion = "What is the $($command.Name) command for?"
                                $json = @{
                                    messages = @(
                                        @{ role = 'system'; content = $SystemContent },
                                        @{ role = 'user'; content = $userQuestion },
                                        @{ role = 'assistant'; content = $synopsis }
                                    )
                                } | ConvertTo-Json
                                $null = $jsonlContent.Add($json)
                            } else {
                                Write-Verbose "No synopsis found for $($command.Name)"
                            }
                        }

                        # For Description
                        if ($Include -contains 'Description') {
                            $description = $commandHelp.Description
                            if ($description) {
                                Write-Verbose "Processing description"
                                $userQuestion = "What is the $($command.Name) command for?"
                                $json = @{
                                    messages = @(
                                        @{ role = 'system'; content = $SystemContent },
                                        @{ role = 'user'; content = $userQuestion },
                                        @{ role = 'assistant'; content = $description }
                                    )
                                } | ConvertTo-Json
                                $null = $jsonlContent.Add($json)
                            } else {
                                Write-Verbose "No description found for $($command.Name)"
                            }
                        }

                        # For Parameters
                        if ($Include -contains 'Parameters') {
                            $params = $commandHelp.Parameters.Parameter
                            foreach ($param in $params) {
                                Write-Verbose "Processing parameter: $($param.name)"
                                $userQuestion = "What is the $($param.name) parameter for the $($command.Name) for?"
                                if ($param.description) {
                                    $json = @{
                                        messages = @(
                                            @{ role = 'system'; content = $SystemContent },
                                            @{ role = 'user'; content = $userQuestion },
                                            @{ role = 'assistant'; content = $param.description[0].Text }
                                        )
                                    } | ConvertTo-Json
                                    $null = $jsonlContent.Add($json)
                                } else {
                                    Write-Verbose "No description found for $($param.name)"
                                }
                            }
                        }

                        # For Examples
                        if ($Include -contains 'Examples') {
                            $examples = $commandHelp.Examples.Example
                            foreach ($example in $examples) {
                                if ($example.remarks) {
                                    Write-Verbose "Processing example"
                                    $userQuestion = "I want to $($example.remarks.text)"
                                    $json = @{
                                        messages = @(
                                            @{ role = 'system'; content = $SystemContent },
                                            @{ role = 'user'; content = $userQuestion },
                                            @{ role = 'assistant'; content = $($example.code) }
                                        )
                                    } | ConvertTo-Json
                                    $null = $jsonlContent.Add($json)
                                } else {
                                    Write-Verbose "No description found for $($example.code)"
                                }
                            }
                        }
                    }
                    $jsonlContent -join "`n" | Set-Content -Path $outputFilePath
                    $tokeninfo = $jsonlContent -join "`n" | Measure-TuneToken
                }

                "Unsupported" {
                    throw "The type of InputObject is not supported."
                }
            }
            [PSCustomObject]@{
                FileName        = (Get-ChildItem $outputFilePath).Name
                TokenCount      = $tokeninfo.TokenCount
                TrainingCost    = $tokeninfo.TrainingCost
                InputUsageCost  = $tokeninfo.InputUsageCost
                OutputUsageCost = $tokeninfo.OutputUsageCost
            }
        }
    }
}
