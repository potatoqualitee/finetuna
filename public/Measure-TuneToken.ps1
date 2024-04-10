function Measure-TuneToken {
    <#
    .SYNOPSIS
    This command measures the token usage of the provided text using the SharpToken library.

    .DESCRIPTION
    Measure-TuneToken takes an array of strings, combines them, and utilizes the SharpToken library to tokenize the combined string. It then returns the count of tokens as a PSCustomObject.

    .PARAMETER InputObject
    An array of strings to be tokenized. This parameter is mandatory and accepts pipeline input.

    .PARAMETER Model
    Specifies the model to use for tokenization. Defaults to 'cl100k_base'. Other valid values are 'r50k_base', 'p50k_base', and 'p50k_edit'.

    .EXAMPLE
    Measure-TuneToken -InputObject "Hello, world!" -Model cl100k_base

    This command will tokenize the string "Hello, world!" using the 'cl100k_base' model and return the token count as a PSCustomObject.

    .EXAMPLE
    Get-Content -Path C:\path\to\file.txt | Measure-TuneToken -Model p50k_base

    This command will read the content of file.txt, pass the content as a string to Measure-TuneToken, and return the token count as a PSCustomObject.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('String')]
        [string[]]$InputObject,
        [ValidateSet('cl100k_base', 'p50k_base', 'r50k_base', 'textembeddingada002', 'codex', 'textdavinci002', 'textdavinci003', 'davinci')]
        [string]$Model = 'cl100k_base'
    )
    begin {
        if ($script:modelmapping.ContainsKey($Model)) {
            $encodingName = $script:modelmapping[$Model]
        } else {
            $encodingName = $Model
        }

        $combinedString = New-Object System.Text.StringBuilder
    }
    process {
        foreach ($string in $InputObject) {
            $null = $combinedString.Append($string)
        }
    }
    end {
        $encodingName = $Model.ToString()
        $encoding = [SharpToken.GptEncoding]::GetEncoding($encodingName)
        $encoded = $encoding.Encode($combinedString.ToString())
        $tokenCount = $encoded.Count

        # Pricing details based on the provided table
        # https://openai.com/pricing
        $pricingDetails = @{
            'cl100k_base'              = @{ Training = 0.0080; InputUsage = 0.0030; OutputUsage = 0.0060 }
            'p50k_base'                = @{ Training = 0.0060; InputUsage = 0.0120; OutputUsage = 0.0120 }
            'r50k_base'                = @{ Training = 0.0004; InputUsage = 0.0016; OutputUsage = 0.0016 }
            'davinci-002'              = @{ Training = $null; InputUsage = 0.0030; OutputUsage = 0.0030 }
            'babbage-002'              = @{ Training = $null; InputUsage = 0.0030; OutputUsage = 0.0030 }
            'text-embedding-3-small'   = @{ Training = $null; InputUsage = 0.00002; OutputUsage = $null }
            'text-embedding-3-large'   = @{ Training = $null; InputUsage = 0.00013; OutputUsage = $null }
            'text-embedding-ada-002'   = @{ Training = $null; InputUsage = 0.0001; OutputUsage = $null }
        }

        $trainingCost = $tokenCount * ($pricingDetails[$encodingName].Training / 1000)
        $inputUsageCost = $tokenCount * ($pricingDetails[$encodingName].InputUsage / 1000)
        $outputUsageCost = $tokenCount * ($pricingDetails[$encodingName].OutputUsage / 1000)

        [PSCustomObject]@{
            TokenCount      = $tokenCount
            TrainingCost    = $trainingCost
            InputUsageCost  = $inputUsageCost
            OutputUsageCost = $outputUsageCost
        }
    }
}
