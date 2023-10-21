function Send-TuneFile {
    <#
        .SYNOPSIS
            Submits files to the model for training.

        .DESCRIPTION
            This function uploads files specified by the user to the model for training.

        .PARAMETER FilePath
            Path to the file(s) to be uploaded.

        .EXAMPLE
            Send-TuneFile -FilePath C:\path\to\file.csv

        .EXAMPLE
            Get-ChildItem *.jsonl | Send-ModelFil
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$FilePath
    )
    begin {
        $tempDirectory = [System.IO.Path]::GetTempPath()
        if (-not $script:WebSession) {
            $null = Connect-TuneService
        }

        function ConvertTo-JsonL {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory, ValueFromPipeline)]
                $InputObject # The collection of PowerShell objects to convert to JSON.
            )

            begin {
                $sb = [System.Text.StringBuilder]::New() # Create a new StringBuilder object to store the JSON string.
            }

            process {
                foreach ($obj in $InputObject) {
                    # Loop through each object in the collection.
                    $null = $sb.AppendLine(($obj | ConvertTo-Json)) # Convert the object to JSON and append it to the StringBuilder object.
                }
            }

            end {
                $sb.ToString() # Convert the StringBuilder object to a string and return it.
            }
        }
    }
    process {
        foreach ($file in "$FilePath") {
            Write-Verbose "Processing $file"
            $extension = (Get-ChildItem $file).Extension
            $basename = (Get-ChildItem $file).BaseName
            # Process the file content
            $fileContent = switch ($extension) {
                '.csv' { Import-Csv $file | ConvertTo-JsonL }
                '.pdf' { Import-PDFFile $file | ConvertTo-JsonL }  # Ensure Import-PDFFile is a valid cmdlet or function
                default {
                    if ($extension -eq ".json") {
                        Get-Content $file -Raw | ConvertFrom-Json | ConvertTo-JsonL
                    } elseif ($extension -ne ".jsonl") {
                        Write-Verbose "File type $extension is not supported but will try anyway."
                        (Get-Content $file -Raw).ToString() | ConvertTo-JsonL
                    }
                }
            }

            if ($extension -eq ".jsonl") {
                $tempFile = $file
            } else {
                # Write the file content to a temporary .jsonl file in the temporary directory with the original basename
                $tempFile = Join-Path -Path $tempDirectory -ChildPath "$basename.jsonl"

                # Convert the JSON content to an array of objects
                $jsonObjects = ConvertFrom-Json $fileContent

                # Convert each object to a JSONL string and write it to the JSONL file
                $jsonObjects | ForEach-Object {
                    $PSItem | ConvertTo-Json -Depth 1 | Out-File -FilePath $tempFile -Append -Encoding utf8
                }
            }

            # Existing variables
            $uri = "https://api.openai.com/v1/files"
            $Form = @{
                purpose = "fine-tune"
                file = Get-Item -Path $tempFile
            }

            $Params = @{
                Uri        = $Uri
                Method     = "POST"
                Form       = $Form
            }

            Invoke-RestMethod2 @Params

            if ($tempfile -ne $file) {
                # Delete the temporary .jsonl file
                Remove-Item -Path $tempFile -Verbose
            }
        }
    }
}
