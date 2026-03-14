#Requires -RunAsAdministrator
<#
.SYNOPSIS
    OpenClaw Automated Installer for Windows
.DESCRIPTION
    Installs WSL2, Ubuntu, Ollama, and OpenClaw in one command.
    Must be run as Administrator in PowerShell.

    Usage (one-liner from web):
        irm https://raw.githubusercontent.com/Goib-Sullivan/openclaw-starter-kit/main/install-windows.ps1 | iex

    Or if you have the file locally:
        powershell -ExecutionPolicy Bypass -File install-windows.ps1

.PARAMETER Help
    Show this help message and exit.

.EXAMPLE
    irm https://raw.githubusercontent.com/Goib-Sullivan/openclaw-starter-kit/main/install-windows.ps1 | iex
#>

param(
    [switch]$Help
)

# ─────────────────────────────────────────────
#  Help flag
# ─────────────────────────────────────────────
if ($Help) {
    Write-Host @"
OpenClaw Windows Installer
==========================
This script installs everything needed to run OpenClaw with a local AI model.

What it installs:
  - WSL2 (Windows Subsystem for Linux)
  - Ubuntu (inside WSL2)
  - Ollama + Qwen3.5 32B AI model
  - OpenClaw and workspace templates

Requirements:
  - Windows 10 (version 2004 or later) or Windows 11
  - NVIDIA GPU with up-to-date drivers (for local AI)
  - ~30 GB free disk space
  - Run as Administrator

Usage:
  irm https://raw.githubusercontent.com/Goib-Sullivan/openclaw-starter-kit/main/install-windows.ps1 | iex
"@
    exit 0
}

# ─────────────────────────────────────────────
#  Color helpers
# ─────────────────────────────────────────────
function Write-Banner {
    param([string]$Text)
    Write-Host ""
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Text)
    Write-Host "  ➤  $Text" -ForegroundColor Cyan
}

function Write-OK {
    param([string]$Text)
    Write-Host "  ✓  $Text" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Text)
    Write-Host "  ⚠  $Text" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Text)
    Write-Host "  ✗  $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host "     $Text" -ForegroundColor Gray
}

# ─────────────────────────────────────────────
#  Constants
# ─────────────────────────────────────────────
$RESUME_SCRIPT   = "$env:TEMP\openclaw-install-resume.ps1"
$RESUME_TASK     = "OpenClawInstallResume"
$WSL_INSTALLER   = "https://raw.githubusercontent.com/Goib-Sullivan/openclaw-starter-kit/main/install-wsl.sh"

# ─────────────────────────────────────────────
#  Welcome banner
# ─────────────────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                                                      ║" -ForegroundColor Cyan
Write-Host "  ║      Welcome to the OpenClaw Installer               ║" -ForegroundColor Cyan
Write-Host "  ║                                                      ║" -ForegroundColor Cyan
Write-Host "  ║  This script will set up your personal AI assistant  ║" -ForegroundColor Cyan
Write-Host "  ║  running entirely on your own computer.              ║" -ForegroundColor Cyan
Write-Host "  ║                                                      ║" -ForegroundColor Cyan
Write-Host "  ║  What's happening:                                   ║" -ForegroundColor Cyan
Write-Host "  ║    1. Enable WSL2 (Linux on Windows)                 ║" -ForegroundColor Cyan
Write-Host "  ║    2. Install Ubuntu                                 ║" -ForegroundColor Cyan
Write-Host "  ║    3. Install Ollama + AI model (~20 GB download)    ║" -ForegroundColor Cyan
Write-Host "  ║    4. Install OpenClaw & configure your assistant    ║" -ForegroundColor Cyan
Write-Host "  ║                                                      ║" -ForegroundColor Cyan
Write-Host "  ║  Time estimate: 20–40 minutes (mostly downloading)   ║" -ForegroundColor Cyan
Write-Host "  ║                                                      ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Before you start, make sure you have:" -ForegroundColor White
Write-Host "    • Your Telegram Bot Token  (from @BotFather)" -ForegroundColor White
Write-Host "    • Your Telegram User ID    (from @userinfobot)" -ForegroundColor White
Write-Host "    • ~30 GB of free disk space" -ForegroundColor White
Write-Host ""
Write-Host "  Don't have these yet? See ACCOUNTS-SETUP.md first." -ForegroundColor Yellow
Write-Host ""

# ─────────────────────────────────────────────
#  Step 0: Check if this is a post-reboot resume
# ─────────────────────────────────────────────
$IsResume = $false
if (Test-Path "$env:TEMP\openclaw-install-flag.txt") {
    $IsResume = $true
    Write-OK "Resuming after reboot — welcome back!"
    Remove-Item "$env:TEMP\openclaw-install-flag.txt" -Force -ErrorAction SilentlyContinue
    # Remove the scheduled task now that we're running
    Unregister-ScheduledTask -TaskName $RESUME_TASK -Confirm:$false -ErrorAction SilentlyContinue
    Write-OK "Cleanup: removed scheduled resume task"
    Write-Host ""
    Write-Info "Waiting 10 seconds for WSL to finish initializing..."
    Start-Sleep -Seconds 10
}

# ─────────────────────────────────────────────
#  Step 1: Check Windows version
# ─────────────────────────────────────────────
Write-Step "Checking Windows version..."

$os = Get-CimInstance -ClassName Win32_OperatingSystem
$buildNumber = [int]$os.BuildNumber
$version     = $os.Caption

Write-Info "Detected: $version (Build $buildNumber)"

# Windows 10 2004 = build 19041; Windows 11 = build 22000+
if ($buildNumber -lt 19041) {
    Write-Fail "Your Windows version is not supported."
    Write-Info "  You need Windows 10 version 2004 (Build 19041) or later, or Windows 11."
    Write-Info "  Current build: $buildNumber"
    Write-Info ""
    Write-Info "  To check your version: press Win+R, type 'winver', press Enter."
    Write-Info "  To upgrade: Settings → Windows Update → Check for updates."
    exit 1
}

Write-OK "Windows version OK (Build $buildNumber)"

# ─────────────────────────────────────────────
#  Step 2: Check/install WSL2
# ─────────────────────────────────────────────
Write-Step "Checking WSL2 status..."

$wslInstalled = $false

try {
    # wsl --status exits non-zero if WSL is not installed; suppress stderr
    $wslStatus = wsl --status 2>&1
    if ($LASTEXITCODE -eq 0) {
        $wslInstalled = $true
        Write-OK "WSL2 is already installed"
    }
} catch {
    $wslInstalled = $false
}

if (-not $wslInstalled) {
    Write-Warn "WSL2 is not installed. Installing now..."
    Write-Info "This will install WSL2 and Ubuntu. A reboot is required."
    Write-Host ""

    # Install WSL2 + Ubuntu
    try {
        wsl --install
        if ($LASTEXITCODE -ne 0) {
            throw "wsl --install returned exit code $LASTEXITCODE"
        }
    } catch {
        Write-Fail "WSL2 installation failed."
        Write-Info "  Error: $_"
        Write-Info ""
        Write-Info "  Try these steps:"
        Write-Info "    1. Make sure virtualization is enabled in your BIOS."
        Write-Info "       Search for your PC model + 'enable virtualization' for instructions."
        Write-Info "    2. Run Windows Update and restart, then try again."
        Write-Info "    3. See: https://aka.ms/wsl2-install"
        exit 1
    }

    # ── Create a resume script that will run after reboot ──────────────
    $resumeScriptContent = @"
# OpenClaw installer — post-reboot resume script
# Auto-generated. Do not edit manually.
# This file deletes itself after running.

# Signal to the main installer that this is a resume
Set-Content -Path "$env:TEMP\openclaw-install-flag.txt" -Value "resume"

# Re-download and run the main installer
try {
    `$installer = Invoke-RestMethod -Uri "$WSL_INSTALLER/../install-windows.ps1" -UseBasicParsing -ErrorAction Stop
    Invoke-Expression `$installer
} catch {
    # Fallback: launch a new elevated PowerShell window with instructions
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -Command `"Write-Host 'OpenClaw resume failed. Please re-run: irm https://raw.githubusercontent.com/Goib-Sullivan/openclaw-starter-kit/main/install-windows.ps1 | iex' -ForegroundColor Yellow; Read-Host 'Press Enter to close'`"" -Verb RunAs
}

# Clean up this resume script
Remove-Item -Path '$RESUME_SCRIPT' -Force -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName '$RESUME_TASK' -Confirm:`$false -ErrorAction SilentlyContinue
"@

    Set-Content -Path $RESUME_SCRIPT -Value $resumeScriptContent -Encoding UTF8

    # Register a scheduled task to run the resume script after next login
    try {
        $action  = New-ScheduledTaskAction -Execute "powershell.exe" `
                       -Argument "-ExecutionPolicy Bypass -WindowStyle Normal -File `"$RESUME_SCRIPT`""
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        Register-ScheduledTask -TaskName $RESUME_TASK `
                               -Action $action `
                               -Trigger $trigger `
                               -Settings $settings `
                               -RunLevel Highest `
                               -Force | Out-Null
        Write-OK "Scheduled resume task created — installer will continue after reboot"
    } catch {
        Write-Warn "Could not create scheduled task: $_"
        Write-Info "After reboot, you'll need to re-run this installer manually:"
        Write-Info "  irm https://raw.githubusercontent.com/Goib-Sullivan/openclaw-starter-kit/main/install-windows.ps1 | iex"
    }

    Write-Host ""
    Write-Host "  ┌──────────────────────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "  │  A restart is required to finish installing WSL2.    │" -ForegroundColor Yellow
    Write-Host "  │                                                      │" -ForegroundColor Yellow
    Write-Host "  │  IMPORTANT — After rebooting:                        │" -ForegroundColor Yellow
    Write-Host "  │    1. Ubuntu will open automatically and ask you     │" -ForegroundColor Yellow
    Write-Host "  │       to create a username and password.             │" -ForegroundColor Yellow
    Write-Host "  │    2. Follow those prompts (use a simple lowercase   │" -ForegroundColor Yellow
    Write-Host "  │       username, no spaces).                          │" -ForegroundColor Yellow
    Write-Host "  │    3. The OpenClaw installer will resume             │" -ForegroundColor Yellow
    Write-Host "  │       automatically after you log back in.          │" -ForegroundColor Yellow
    Write-Host "  └──────────────────────────────────────────────────────┘" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Press Enter to restart your computer now (or Ctrl+C to cancel)..." -ForegroundColor White
    Read-Host

    Restart-Computer -Force
    exit 0
}

# ─────────────────────────────────────────────
#  Step 3: Check Ubuntu is installed in WSL
# ─────────────────────────────────────────────
Write-Step "Checking Ubuntu installation in WSL..."

$wslList = wsl -l 2>&1
$ubuntuInstalled = ($wslList -match "Ubuntu")

if (-not $ubuntuInstalled) {
    Write-Warn "Ubuntu not found in WSL. Installing..."

    try {
        wsl --install Ubuntu
        if ($LASTEXITCODE -ne 0) {
            throw "wsl --install Ubuntu returned exit code $LASTEXITCODE"
        }
        Write-OK "Ubuntu installed"
    } catch {
        Write-Fail "Failed to install Ubuntu in WSL."
        Write-Info "  Error: $_"
        Write-Info ""
        Write-Info "  Try running manually:"
        Write-Info "    wsl --install Ubuntu"
        Write-Info "  Or visit the Microsoft Store and search for 'Ubuntu'."
        exit 1
    }

    # If a reboot is now needed, prompt for one
    Write-Warn "Ubuntu was just installed. You may need to restart for changes to take effect."
    Write-Info "If the next steps fail, restart your computer and re-run this installer."
} else {
    Write-OK "Ubuntu is installed in WSL"
}

# ─────────────────────────────────────────────
#  Step 4: Check NVIDIA GPU passthrough (non-blocking)
# ─────────────────────────────────────────────
Write-Step "Checking NVIDIA GPU support in WSL..."

$nvidiaSmi = wsl bash -c "nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>/dev/null" 2>&1

if ($LASTEXITCODE -eq 0 -and $nvidiaSmi -match "\S") {
    Write-OK "NVIDIA GPU detected in WSL:"
    Write-Info "  $nvidiaSmi"
} else {
    Write-Warn "NVIDIA GPU not detected inside WSL."
    Write-Info "  The AI model will still work, but it may run slowly on CPU only."
    Write-Info "  To enable GPU:"
    Write-Info "    1. Open 'NVIDIA GeForce Experience' on Windows"
    Write-Info "    2. Check for driver updates and install them"
    Write-Info "    3. Restart your computer, then re-run this installer"
    Write-Info "  (Continuing anyway — you can fix this later)"
    Write-Host ""
}

# ─────────────────────────────────────────────
#  Step 5: Ensure WSL Ubuntu is fully initialized
#          (for post-reboot resume: wait for /etc/os-release)
# ─────────────────────────────────────────────
Write-Step "Verifying WSL Ubuntu is ready..."

$maxAttempts = 12
$attempt     = 0
$wslReady    = $false

while ($attempt -lt $maxAttempts) {
    $attempt++
    $check = wsl bash -c "test -f /etc/os-release && echo OK" 2>&1
    if ($check -match "OK") {
        $wslReady = $true
        break
    }
    Write-Info "  Waiting for Ubuntu to finish initializing... (attempt $attempt/$maxAttempts)"
    Start-Sleep -Seconds 5
}

if (-not $wslReady) {
    Write-Fail "Ubuntu did not become ready in time."
    Write-Info ""
    Write-Info "  Please:"
    Write-Info "    1. Open the Ubuntu app from your Start menu"
    Write-Info "    2. Complete the initial username/password setup if prompted"
    Write-Info "    3. Close Ubuntu, then re-run this installer"
    exit 1
}

Write-OK "WSL Ubuntu is ready"

# ─────────────────────────────────────────────
#  Step 6: Download the WSL installer script
# ─────────────────────────────────────────────
Write-Step "Downloading the Linux installer into WSL..."

$downloadCmd = "curl -fsSL '$WSL_INSTALLER' -o /tmp/install-wsl.sh && chmod +x /tmp/install-wsl.sh"

wsl bash -c $downloadCmd 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Fail "Failed to download the Linux installer."
    Write-Info ""
    Write-Info "  Possible causes:"
    Write-Info "    • No internet connection — check your network"
    Write-Info "    • curl is not installed — run: wsl bash -c 'sudo apt install curl -y'"
    Write-Info "    • GitHub is temporarily unavailable — wait a moment and retry"
    Write-Info ""
    Write-Info "  To retry, re-run this script or manually run:"
    Write-Info "    wsl bash -c `"curl -fsSL $WSL_INSTALLER -o /tmp/install-wsl.sh && chmod +x /tmp/install-wsl.sh`""
    exit 1
}

Write-OK "Linux installer downloaded"

# ─────────────────────────────────────────────
#  Step 7: Launch the WSL installer
# ─────────────────────────────────────────────
Write-Host ""
Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  Launching the Linux setup now. A new terminal will open." -ForegroundColor White
Write-Host "  Follow the prompts to complete setup." -ForegroundColor White
Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# Run the WSL installer interactively so the user can respond to prompts
wsl bash -c "/tmp/install-wsl.sh"
$wslExitCode = $LASTEXITCODE

if ($wslExitCode -ne 0) {
    Write-Host ""
    Write-Fail "The Linux installer exited with an error (code: $wslExitCode)."
    Write-Info ""
    Write-Info "  What to try:"
    Write-Info "    1. Open Ubuntu from your Start menu"
    Write-Info "    2. Re-run the installer manually:"
    Write-Info "       bash /tmp/install-wsl.sh"
    Write-Info ""
    Write-Info "  If the script was already downloaded but failed partway through,"
    Write-Info "  it is safe to re-run — it skips steps that already completed."
    exit 1
}

# ─────────────────────────────────────────────
#  All done!
# ─────────────────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                      ║" -ForegroundColor Green
Write-Host "  ║  ✅  OpenClaw is installed!                          ║" -ForegroundColor Green
Write-Host "  ║                                                      ║" -ForegroundColor Green
Write-Host "  ║  To use your assistant:                              ║" -ForegroundColor Green
Write-Host "  ║    📱  Open Telegram and message your bot            ║" -ForegroundColor Green
Write-Host "  ║    🌐  Or visit: http://127.0.0.1:18789/            ║" -ForegroundColor Green
Write-Host "  ║                                                      ║" -ForegroundColor Green
Write-Host "  ║  Guides are in: ~/openclaw-starter-kit/              ║" -ForegroundColor Green
Write-Host "  ║                                                      ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
