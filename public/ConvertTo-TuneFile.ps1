function ConvertTo-TuneFile {
    <#
        .SYNOPSIS
            Converts files to JSONL format for chatbot training.

        .DESCRIPTION
            This function takes in text or CSV files and converts them to JSONL format. Each line or row becomes an "assistant" message in the JSONL.

        .PARAMETER FilePath
            Path to the files to be converted.

        .PARAMETER SystemContent
            The system message for the JSONL file.

        .EXAMPLE
            ConvertTo-TuneFile -FilePath C:\path\to\file.txt -SystemContent 'You are a friendly dbatools and PowerShell expert who offers tech support to DBAs and Systems Engineers'

            Converts 'file.txt' to 'file.jsonl' using the system message 'You are a friendly dbatools expert who offers tech support to DBAs and Systems Engineers'

        .EXAMPLE
            ConvertTo-TuneFile -FilePath C:\path\to\file.csv -SystemContent 'You are a chatbot'

            Converts 'file.csv' to 'file.jsonl' using the system message 'You are a chatbot'.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ return (Test-Path $_) })]
        [psobject[]]$FilePath,
        [Parameter(Mandatory)]
        [string]$SystemContent
    )
    process {
        foreach ($file in $FilePath) {
            if ($PSCmdlet.ShouldProcess("File: $file", 'Convert to JSONL')) {
                Write-Verbose "Processing $file"
                $extension = (Get-ChildItem $file).Extension
                $basename = (Get-ChildItem $file).BaseName
                $outputFilePath = Join-Path (Get-ChildItem $file).DirectoryName "$basename.jsonl"

                switch ($extension) {
                    '.txt' {
                        $fileContent = Get-Content $file
                        $jsonlContent = @()

                        foreach ($line in $fileContent) {
                            $jsonObj = @{
                                messages = @(
                                    @{ role = 'system'; content = $SystemContent },
                                    @{ role = 'assistant'; content = $line }
                                )
                            } | ConvertTo-Json
                            $jsonlContent += $jsonObj
                        }
                        $jsonlContent -join "`n" | Set-Content -Path $outputFilePath
                    }

                    '.csv' {
                        $csvContent = Import-Csv $file
                        $jsonlContent = @()

                        foreach ($row in $csvContent) {
                            $jsonObj = @{
                                messages = @(
                                    @{ role = 'system'; content = $SystemContent },
                                    @{ role = 'assistant'; content = $row.'Assistant Content' }
                                )
                            } | ConvertTo-Json
                            $jsonlContent += $jsonObj
                        }
                        $jsonlContent -join "`n" | Set-Content -Path $outputFilePath
                    }

                    '.pdf' {
                        $pdfContent = Import-PDFFile $file
                        $jsonlContent = @()

                        foreach ($line in $pdfContent) {
                            $jsonObj = @{
                                messages = @(
                                    @{ role = 'system'; content = $SystemContent },
                                    @{ role = 'assistant'; content = $line }
                                )
                            } | ConvertTo-Json
                            $jsonlContent += $jsonObj
                        }
                        $jsonlContent -join "`n" | Set-Content -Path $outputFilePath
                    }

                    default {
                        throw "File type $extension is not supported."
                    }
                }
            }
        }
    }
}
