#
# Module manifest for module 'finetuna'
#
# Generated by: Chrissy LeMaire
#
# Generated on: 10/19/2023
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'finetuna.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.4'

    # Minimum PowerShell version
    PowerShellVersion = '5.1'

    # ID used to uniquely identify this module
    GUID = '3dc00ef4-ff85-48c9-8701-b96aa91cfa99'

    # Author of this module
    Author = 'Chrissy LeMaire'

    # Copyright statement for this module
    Copyright = 'MIT (c) 2024 Chrissy LeMaire. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'OpenAI Fine Tuner'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @(
        'PowerShellAIAssistant'
        'ReadPDF'
    )

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @(
        "./lib/SharpToken.dll"
    )

    FunctionsToExport  = @(
        'Get-TuneFile',
        'Get-TuneFileContent',
        'Get-TuneJob',
        'Get-TuneJobEvent',
        'Get-TuneModel',
        'Get-TuneModelDefault',
        'Invoke-TuneChat',
        'Invoke-TuneBotChat',
        'Measure-TuneToken',
        'New-TuneModel',
        'Remove-TuneFile',
        'Remove-TuneModel',
        'Request-TuneFileReview',
        'Send-TuneFile',
        'Set-TuneModelDefault',
        'Start-TuneJob',
        'Stop-TuneJob',
        'Test-TuneFile'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @(
        "Invoke-TunedChat",
        "Create-CustomModel"
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @("openai", "chatgpt", "modeling", "tuning", "fine-tuning", "potato")

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/potatoqualitee/finetuna/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/potatoqualitee/finetuna'

            # A URL to an icon representing this module.
            IconUri = 'https://github.com/potatoqualitee/finetuna/assets/8278033/b6e12c36-afd2-46a1-8024-a9fd12c9b773'

        }
    }
}
