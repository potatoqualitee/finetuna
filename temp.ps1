$commandHelps = @{}

# List all commands in the dbatools module
$commands = Get-Command -Module finetuna

foreach ($command in $commands) {
    # Fetch help content for the command
    $helpContent = Get-Help $command.Name -Full

    # Concatenate relevant sections into a single text block
    $textBlock = @"
    Synopsis: $($helpContent.synopsis)
    Description: $($helpContent.description.text)
    Parameters: $(foreach ($param in $helpContent.parameters.parameter) { "$($param.name): $($param.description.text) " })
    Examples: $(foreach ($example in $helpContent.examples.example) { "$($example.title): $($example.code) " })
"@

    # Store the text block in a hashtable using the command name as the key
    $commandHelps[$command.Name] = $textBlock
}

$embeddingStorage = @{}
$i = 0
foreach ($key in $commandHelps.Keys) {
    $i++
    $i

    # Assuming the API returns an embedding in a desired format
    $embeddingStorage[$key] = (New-TuneEmbedding -Text $commandHelps[$key])
}

