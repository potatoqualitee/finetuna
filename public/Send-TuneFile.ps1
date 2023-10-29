function Send-TuneFile {
    <#
        .SYNOPSIS
            Submits files to the model for training.

        .DESCRIPTION
            This function uploads files specified by the user to the model for training.

        .PARAMETER FilePath
            Path to the file(s) to be uploaded.

        .PARAMETER WhatIf
            Shows what would happen if the cmdlet runs. The cmdlet is not run.

        .PARAMETER Confirm
            Prompts you for confirmation before running the cmdlet.

        .EXAMPLE
            Get-ChildItem *.jsonl | Send-TuneFile

        .EXAMPLE
            Send-TuneFile -FilePath C:\path\to\file.csv

        .EXAMPLE
            Send-TuneFile -FilePath C:\path\to\file.csv -WhatIf

            Shows what would happen if the cmdlet runs, but does not execute the cmdlet.

        .EXAMPLE
            Send-TuneFile -FilePath C:\path\to\file.csv -Confirm

            Prompts for confirmation before executing the cmdlet.
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({ return (Test-Path $_) })]
        [System.IO.FileInfo[]]$FilePath
    )
    process {
        foreach ($file in $FilePath) {
            if ($PSCmdlet.ShouldProcess("File: $file", 'Send for training')) {
                Write-Verbose "Processing $file"
                $extension = (Get-ChildItem $file).Extension
                $basename = (Get-ChildItem $file).BaseName

                # UGH, I cannot figure out how to effectively convert to JSONL
                $fileContent = switch ($extension) {
                    '.csv' {
                        throw "CSV file conversion is not yet supported."
                        Write-Verbose "Converting to CSV"
                        Import-Csv $file
                    }
                    '.pdf' {
                        throw "PDF file conversion is not yet supported."
                        Write-Verbose "Converting from PDF"
                        Import-PDFFile $file
                    }
                    default {
                        if ($extension -eq ".json") {
                            throw "JSON file conversion is not yet supported."
                            Get-Content $file | ConvertFrom-Json
                        } elseif ($extension -ne ".jsonl") {
                            throw "Non JSONL files not yet supported."
                            Write-Verbose "File type $extension is not supported but will try anyway."
                            Get-Content $file
                        }
                    }
                }

                if ($extension -eq ".jsonl") {
                    Write-Verbose "Resolving $file"
                    $tp = Join-Path -Path $pwd -ChildPath $file
                    $tempFile = (Get-ChildItem $tp -ErrorAction SilentlyContinue).FullName
                    Write-Verbose "Got tempfile $tempfile"

                    if (-not $tempfile) {
                        $tempfile = $file
                    }
                    Write-Verbose "It's a jsonl, got $tempfile"
                } else {
                    # Invoke-RestMethod -File requires a physical file.
                    $tempFile = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "$basename.jsonl"

                    foreach ($row in $fileContent) {
                        $addContentParams = @{
                            Path     = $tempFile
                            Value    = ($row | ConvertTo-Json -Compress)
                            Encoding = 'utf8'
                        }
                        Add-Content @addContentParams
                    }
                }

                # PowerShell 5.1 needs to create a manual boundary
                # for multipart/form-data

                $uri = "https://api.openai.com/v1/files"

                if ($PSVersionTable.PSVersion.Major -le 5) {
                    Write-Verbose "Using PowerShell 5.1 multipart/form-data workaround, processing $tempFile"
                    $fileBytes = [System.IO.File]::ReadAllBytes($tempFile)
                    $fileEnc = [System.Text.Encoding]::GetEncoding('UTF-8').GetString($fileBytes)
                    $boundary = [System.Guid]::NewGuid().ToString()

                    $LF = "`r`n"

                    $bodyLines = (
                        "--$boundary",
                        "Content-Disposition: form-data; name=`"purpose`"$LF",
                        "fine-tune",
                        "--$boundary",
                        "Content-Disposition: form-data; name=`"file`"; filename=`"$basename.jsonl`"",
                        "Content-Type: application/octet-stream$LF",
                        $fileEnc,
                        "--$boundary--$LF"
                    ) -join $LF

                    # turn invoke-restmethod into splat
                    $params = @{
                        Uri         = $Uri
                        Method      = "POST"
                        ContentType = "multipart/form-data; boundary=`"$boundary`""
                        Body        = $bodyLines
                    }
                } else {
                    # Existing variables
                    $form = @{
                        purpose = "fine-tune"
                        file    = Get-Item -Path $tempFile
                    }

                    $params = @{
                        Uri    = $Uri
                        Method = "POST"
                        Form   = $Form
                    }
                }

                Invoke-RestMethod2 @params

                if ((Get-ChildItem $tempfile -ErrorAction SilentlyContinue).FullName -ne (Get-ChildItem $file -ErrorAction SilentlyContinue).FullName) {
                    # Delete the temporary .jsonl file
                    Remove-Item -Path $tempFile -Verbose
                }
            }
        }
    }
}
