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
        $script:currentModel
    }
}
