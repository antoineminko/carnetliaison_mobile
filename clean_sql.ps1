$tables = @('admin_informations', 'conversations', 'incidents', 'messages', 'notifications', 'appointments')
$lines = Get-Content 'sirh_carnet (2).sql' -Encoding UTF8
$new_lines = @()
$skip = $false

foreach ($line in $lines) {
    if (-not $skip) {
        $matched = $false
        foreach ($table in $tables) {
            if ($line -match "INSERT INTO \`$table\`") {
                $matched = $true
                break
            }
        }
        if ($matched) {
            $skip = $true
            if ($line -match ';$') {
                $skip = $false
            }
        } else {
            $new_lines += $line
        }
    } else {
        if ($line -match ';$') {
            $skip = $false
        }
    }
}

$new_lines | Set-Content 'sirh_carnet_cleaned.sql' -Encoding UTF8
Write-Host 'Cleaned SQL file created at sirh_carnet_cleaned.sql'
