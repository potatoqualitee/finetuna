function Get-TuneModelDefault {
    <#
    .SYNOPSIS
        Gets your preferred default model.

    .DESCRIPTION
        Gets your preferred default model.

    .EXAMPLE
        Get-TuneModelDefault

        Gets your preferred default model.
    #>
    [CmdletBinding()]
    param ()
    process {
        if (-not $script:currentModel) {
            $script:currentModel = "gpt-4-0613"
        }
        $script:currentModel
    }
}
