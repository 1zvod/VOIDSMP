# VOID SMP Plugin Installer
# Usage: .\install-plugin.ps1 <plugin-name> <mc-version>
# Example: .\install-plugin.ps1 simple-voice-chat 1.21.1
# You can also just double-click and it will ask you

param(
    [string]$PluginName,
    [string]$MCVersion
)

$pluginsDir = Join-Path $PSScriptRoot "plugins"
$headers = @{'User-Agent' = 'VOIDSMP/1.0'}

Write-Host "`n=== VOID SMP Plugin Installer ===" -ForegroundColor Cyan
Write-Host ""

if (-not $PluginName) {
    $PluginName = Read-Host "Plugin name (Modrinth slug, e.g. 'simple-voice-chat')"
}
if (-not $MCVersion) {
    $MCVersion = Read-Host "Minecraft version (e.g. '1.21.1')"
}

Write-Host "`nSearching Modrinth for '$PluginName' (MC $MCVersion)..." -ForegroundColor Yellow

try {
    # Search for the plugin
    $url = "https://api.modrinth.com/v2/project/$PluginName/version?game_versions=[`"$MCVersion`"]&loaders=[`"paper`",`"bukkit`",`"spigot`",`"purpur`"]"
    $versions = Invoke-RestMethod -Uri $url -Headers $headers -ErrorAction Stop

    if ($versions.Count -eq 0) {
        Write-Host "No Paper/Bukkit version found for '$PluginName' on MC $MCVersion" -ForegroundColor Red
        Write-Host "Check the slug at: https://modrinth.com/plugins?q=$PluginName" -ForegroundColor Yellow
        Read-Host "`nPress Enter to exit"
        exit 1
    }

    $latest = $versions[0]
    $file = $latest.files[0]

    Write-Host "Found: $($file.filename)" -ForegroundColor Green
    Write-Host "Version: $($latest.version_number)"
    Write-Host "Size: $([math]::Round($file.size / 1MB, 2)) MB"
    Write-Host ""

    # Check if already exists
    $existing = Get-ChildItem "$pluginsDir\*$PluginName*" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Existing file found: $($existing.Name)" -ForegroundColor Yellow
        $confirm = Read-Host "Replace it? (y/n)"
        if ($confirm -ne 'y') {
            Write-Host "Cancelled." -ForegroundColor Red
            Read-Host "`nPress Enter to exit"
            exit 0
        }
        Remove-Item $existing.FullName -Force
    }

    # Download
    Write-Host "Downloading..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $file.url -OutFile (Join-Path $pluginsDir $file.filename)
    Write-Host "`nInstalled: plugins\$($file.filename)" -ForegroundColor Green
    Write-Host "Use '/plugman load $PluginName' in-game to activate without restart." -ForegroundColor Cyan

} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "Plugin '$PluginName' not found on Modrinth." -ForegroundColor Red
        Write-Host "Search here: https://modrinth.com/plugins?q=$PluginName" -ForegroundColor Yellow
    } else {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Read-Host "Press Enter to exit"
