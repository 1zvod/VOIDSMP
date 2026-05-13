Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$pluginsDir = Join-Path $PSScriptRoot "plugins"
$headers = @{'User-Agent' = 'VOIDSMP/1.0'}

# --- Main Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "VOID SMP - Plugin Manager"
$form.Size = New-Object System.Drawing.Size(720, 580)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# --- Title ---
$title = New-Object System.Windows.Forms.Label
$title.Text = "VOID SMP Plugin Manager"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
$title.Location = New-Object System.Drawing.Point(20, 10)
$title.AutoSize = $true
$form.Controls.Add($title)

# --- Search Box ---
$searchLabel = New-Object System.Windows.Forms.Label
$searchLabel.Text = "Search Modrinth:"
$searchLabel.Location = New-Object System.Drawing.Point(20, 55)
$searchLabel.AutoSize = $true
$form.Controls.Add($searchLabel)

$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(150, 52)
$searchBox.Size = New-Object System.Drawing.Size(300, 28)
$searchBox.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$searchBox.ForeColor = [System.Drawing.Color]::White
$searchBox.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$form.Controls.Add($searchBox)

# --- Version Dropdown ---
$verLabel = New-Object System.Windows.Forms.Label
$verLabel.Text = "MC:"
$verLabel.Location = New-Object System.Drawing.Point(460, 55)
$verLabel.AutoSize = $true
$form.Controls.Add($verLabel)

$verBox = New-Object System.Windows.Forms.ComboBox
$verBox.Location = New-Object System.Drawing.Point(495, 52)
$verBox.Size = New-Object System.Drawing.Size(80, 28)
$verBox.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$verBox.ForeColor = [System.Drawing.Color]::White
$verBox.DropDownStyle = "DropDownList"
$verBox.Items.AddRange(@("1.21.1","1.21","1.20.6","1.20.4","1.20.2","1.20.1","1.20","1.19.4","1.19.2"))
$verBox.SelectedIndex = 0
$form.Controls.Add($verBox)

# --- Search Button ---
$searchBtn = New-Object System.Windows.Forms.Button
$searchBtn.Text = "Search"
$searchBtn.Location = New-Object System.Drawing.Point(585, 50)
$searchBtn.Size = New-Object System.Drawing.Size(100, 30)
$searchBtn.BackColor = [System.Drawing.Color]::FromArgb(60, 140, 230)
$searchBtn.ForeColor = [System.Drawing.Color]::White
$searchBtn.FlatStyle = "Flat"
$searchBtn.Cursor = "Hand"
$form.Controls.Add($searchBtn)

# --- Results List ---
$resultsList = New-Object System.Windows.Forms.ListView
$resultsList.Location = New-Object System.Drawing.Point(20, 95)
$resultsList.Size = New-Object System.Drawing.Size(665, 250)
$resultsList.View = "Details"
$resultsList.FullRowSelect = $true
$resultsList.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$resultsList.ForeColor = [System.Drawing.Color]::White
$resultsList.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
$resultsList.GridLines = $true
$resultsList.Columns.Add("Plugin", 200) | Out-Null
$resultsList.Columns.Add("Author", 120) | Out-Null
$resultsList.Columns.Add("Downloads", 90) | Out-Null
$resultsList.Columns.Add("Description", 245) | Out-Null
$form.Controls.Add($resultsList)

# --- Install Button ---
$installBtn = New-Object System.Windows.Forms.Button
$installBtn.Text = "Install Selected"
$installBtn.Location = New-Object System.Drawing.Point(20, 355)
$installBtn.Size = New-Object System.Drawing.Size(150, 35)
$installBtn.BackColor = [System.Drawing.Color]::FromArgb(50, 180, 80)
$installBtn.ForeColor = [System.Drawing.Color]::White
$installBtn.FlatStyle = "Flat"
$installBtn.Cursor = "Hand"
$form.Controls.Add($installBtn)

# --- Uninstall Button ---
$uninstallBtn = New-Object System.Windows.Forms.Button
$uninstallBtn.Text = "Uninstall"
$uninstallBtn.Location = New-Object System.Drawing.Point(180, 355)
$uninstallBtn.Size = New-Object System.Drawing.Size(100, 35)
$uninstallBtn.BackColor = [System.Drawing.Color]::FromArgb(200, 60, 60)
$uninstallBtn.ForeColor = [System.Drawing.Color]::White
$uninstallBtn.FlatStyle = "Flat"
$uninstallBtn.Cursor = "Hand"
$form.Controls.Add($uninstallBtn)

# --- Show Installed Button ---
$installedBtn = New-Object System.Windows.Forms.Button
$installedBtn.Text = "Show Installed"
$installedBtn.Location = New-Object System.Drawing.Point(540, 355)
$installedBtn.Size = New-Object System.Drawing.Size(145, 35)
$installedBtn.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$installedBtn.ForeColor = [System.Drawing.Color]::White
$installedBtn.FlatStyle = "Flat"
$installedBtn.Cursor = "Hand"
$form.Controls.Add($installedBtn)

# --- Status/Log Box ---
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location = New-Object System.Drawing.Point(20, 400)
$logBox.Size = New-Object System.Drawing.Size(665, 130)
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.ReadOnly = $true
$logBox.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 100)
$logBox.Font = New-Object System.Drawing.Font("Consolas", 9.5)
$form.Controls.Add($logBox)

# --- Store search results ---
$script:searchResults = @()

function Log($msg) {
    $logBox.AppendText("$(Get-Date -Format 'HH:mm:ss') $msg`r`n")
}

# --- Search ---
$searchBtn.Add_Click({
    $query = $searchBox.Text.Trim()
    if (-not $query) { Log "Enter a search term."; return }

    $resultsList.Items.Clear()
    $script:searchResults = @()
    Log "Searching for '$query'..."
    $form.Cursor = "WaitCursor"

    try {
        $mcver = $verBox.SelectedItem
        $results = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/search?query=$query&facets=[[`"categories:paper`",`"categories:bukkit`",`"categories:spigot`"],[`"versions:$mcver`"],[`"project_type:mod`",`"project_type:plugin`"]]&limit=20" -Headers $headers -ErrorAction Stop

        if ($results.hits.Count -eq 0) {
            Log "No plugins found for '$query' on MC $mcver"
        } else {
            foreach ($hit in $results.hits) {
                $item = New-Object System.Windows.Forms.ListViewItem($hit.title)
                $item.SubItems.Add($hit.author) | Out-Null
                $item.SubItems.Add([string]$hit.downloads) | Out-Null
                $desc = if ($hit.description.Length -gt 60) { $hit.description.Substring(0,57) + "..." } else { $hit.description }
                $item.SubItems.Add($desc) | Out-Null
                $resultsList.Items.Add($item) | Out-Null
                $script:searchResults += $hit
            }
            Log "Found $($results.hits.Count) plugins."
        }
    } catch {
        Log "Error: $($_.Exception.Message)"
    }
    $form.Cursor = "Default"
})

# --- Enter key triggers search ---
$searchBox.Add_KeyDown({
    if ($_.KeyCode -eq "Return") { $searchBtn.PerformClick() }
})

# --- Install ---
$installBtn.Add_Click({
    if ($resultsList.SelectedItems.Count -eq 0) { Log "Select a plugin first."; return }

    $idx = $resultsList.SelectedIndices[0]
    $plugin = $script:searchResults[$idx]
    $slug = $plugin.slug
    $mcver = $verBox.SelectedItem

    Log "Fetching download for $($plugin.title)..."
    $form.Cursor = "WaitCursor"

    try {
        $versions = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/project/$slug/version?game_versions=[`"$mcver`"]&loaders=[`"paper`",`"bukkit`",`"spigot`",`"purpur`"]" -Headers $headers -ErrorAction Stop

        if ($versions.Count -eq 0) {
            Log "No compatible version found."
            $form.Cursor = "Default"
            return
        }

        $file = $versions[0].files[0]
        $dest = Join-Path $pluginsDir $file.filename

        # Check existing
        $existing = Get-ChildItem "$pluginsDir\*" | Where-Object { $_.Name -like "*$slug*" -or $_.Name -like "*$($plugin.title.Replace(' ',''))*" }
        if ($existing) {
            $answer = [System.Windows.Forms.MessageBox]::Show("Found existing: $($existing.Name)`nReplace it?", "Plugin Exists", "YesNo", "Question")
            if ($answer -eq "No") { Log "Cancelled."; $form.Cursor = "Default"; return }
            Remove-Item $existing.FullName -Force
            Log "Removed old: $($existing.Name)"
        }

        Log "Downloading $($file.filename) ($([math]::Round($file.size/1MB,2)) MB)..."
        Invoke-WebRequest -Uri $file.url -OutFile $dest
        Log "Installed: $($file.filename)"
        Log "Use: /plugman load $slug"
    } catch {
        Log "Error: $($_.Exception.Message)"
    }
    $form.Cursor = "Default"
})

# --- Uninstall ---
$uninstallBtn.Add_Click({
    if ($resultsList.SelectedItems.Count -eq 0) { Log "Select an installed plugin first (use Show Installed)."; return }

    $name = $resultsList.SelectedItems[0].Text
    $jar = Get-ChildItem "$pluginsDir\*.jar" | Where-Object { $_.Name -like "*$name*" } | Select-Object -First 1

    if (-not $jar) { Log "Could not find jar matching '$name'"; return }

    $answer = [System.Windows.Forms.MessageBox]::Show("Delete $($jar.Name)?", "Confirm Uninstall", "YesNo", "Warning")
    if ($answer -eq "Yes") {
        Remove-Item $jar.FullName -Force
        Log "Uninstalled: $($jar.Name)"
        Log "Use: /plugman unload $name (if still loaded)"
        $installedBtn.PerformClick()
    }
})

# --- Show Installed ---
$installedBtn.Add_Click({
    $resultsList.Items.Clear()
    $script:searchResults = @()

    $jars = Get-ChildItem "$pluginsDir\*.jar" | Sort-Object Name
    foreach ($jar in $jars) {
        $item = New-Object System.Windows.Forms.ListViewItem($jar.BaseName)
        $item.SubItems.Add("Local") | Out-Null
        $item.SubItems.Add("$([math]::Round($jar.Length/1MB,1)) MB") | Out-Null
        $item.SubItems.Add($jar.Name) | Out-Null
        $resultsList.Items.Add($item) | Out-Null
    }
    Log "Showing $($jars.Count) installed plugins."
})

# --- Show installed on load ---
$form.Add_Shown({ $installedBtn.PerformClick() })

[void]$form.ShowDialog()
