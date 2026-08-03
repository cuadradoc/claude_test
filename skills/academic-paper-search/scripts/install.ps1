<#
.SYNOPSIS
    Install the academic-paper-search skill on Windows.

.DESCRIPTION
    PowerShell counterpart to install.sh, for machines without WSL or Git Bash.
    Installs to $env:USERPROFILE\.claude\skills for local Claude Code and builds
    a .zip to upload at claude.ai, which is what reaches every other surface.

.PARAMETER Email
    Polite-pool email for OpenAlex, Crossref and Unpaywall. Without it those
    APIs return 429 from shared IPs.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -Email you@example.com
#>

[CmdletBinding()]
param(
    [string]$Email = ""
)

$ErrorActionPreference = "Stop"

$SkillDir  = Split-Path -Parent $PSScriptRoot
$SkillName = Split-Path -Leaf $SkillDir
$Dest      = Join-Path $env:USERPROFILE ".claude\skills\$SkillName"

Write-Host "==> Skill source: $SkillDir"

# --- prerequisites -----------------------------------------------------------
$uv = Get-Command uv -ErrorAction SilentlyContinue
if ($uv) {
    Write-Host "==> uv found: $(& uv --version)"
} else {
    Write-Warning "uv not found. The CLI needs it to resolve its dependencies."
    Write-Host "    Install it with:"
    Write-Host '      powershell -c "irm https://astral.sh/uv/install.ps1 | iex"'
    Write-Host "    Then reopen PowerShell so PATH picks it up."
    Write-Host "    Alternative without uv:  pip install paper-search-mcp==0.1.4"
}

# --- 1. local Claude Code ----------------------------------------------------
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Dest) | Out-Null
if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
Copy-Item -Recurse -Force $SkillDir $Dest
Write-Host "==> Installed for local Claude Code: $Dest"

# --- 2. polite-pool credentials ---------------------------------------------
# The library reads this path on every platform, so keep it identical to the
# POSIX installer rather than using a Windows-specific location.
$EnvFile = Join-Path $env:USERPROFILE ".config\paper-search-mcp\.env"
if ($Email) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $EnvFile) | Out-Null
    if ((Test-Path $EnvFile) -and
        (Select-String -Path $EnvFile -Pattern '^PAPER_SEARCH_MCP_UNPAYWALL_EMAIL=' -Quiet)) {
        Write-Host "==> Email already set in $EnvFile - leaving it alone"
    } else {
        # UTF8 without BOM: the library's parser treats a BOM as part of the key name.
        $line = "PAPER_SEARCH_MCP_UNPAYWALL_EMAIL=$Email`n"
        [System.IO.File]::AppendAllText($EnvFile, $line, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "==> Wrote polite-pool email to $EnvFile"
    }
} elseif (-not (Test-Path $EnvFile)) {
    Write-Warning "No polite-pool email configured. OpenAlex and Crossref will return 429 from shared IPs."
    Write-Host "    Fix with: .\scripts\install.ps1 -Email you@example.com"
}

# --- 3. bundle for claude.ai (this is what reaches every surface) ------------
$Bundle = Join-Path (Split-Path -Parent $SkillDir) "$SkillName.zip"
if (Test-Path $Bundle) { Remove-Item -Force $Bundle }
$staging = Join-Path ([System.IO.Path]::GetTempPath()) "psm-$([guid]::NewGuid().ToString('N'))"
try {
    New-Item -ItemType Directory -Force -Path $staging | Out-Null
    Copy-Item -Recurse -Force $SkillDir (Join-Path $staging $SkillName)
    # Where-Object rather than -Include: -Include has surprising interactions
    # with -Directory and -Recurse across PowerShell versions.
    Get-ChildItem -Path $staging -Recurse -Force -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -in @('__pycache__', '.venv') } |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $staging -Recurse -Force -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -eq '.pyc' } |
        Remove-Item -Force -ErrorAction SilentlyContinue
    Compress-Archive -Path (Join-Path $staging $SkillName) -DestinationPath $Bundle -Force
    Write-Host "==> Upload bundle: $Bundle"
} finally {
    Remove-Item -Recurse -Force $staging -ErrorAction SilentlyContinue
}

Write-Host @"

Next steps
----------
1. Local Claude Code: ready now. Start a session and ask it to search for papers.

2. Every other surface (claude.ai chat, Projects, Cowork, cloud Code sessions):
   upload the .zip at claude.ai -> Settings -> Capabilities -> Skills -> Upload skill.
   That copy syncs to the account, which is what makes it available everywhere.

3. Verify the install:
     python tests\pilot_test.py
     uv run scripts\paper_search.py doctor

Note: PowerShell continues lines with a backtick, not a backslash. Keep each
command on one line and you will not need either.
"@
