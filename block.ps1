# =========================
# CF Lockdown (IP mode - compatible)
# Only allow Codeforces + Cloudflare
# =========================

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Run PowerShell as Administrator." -ForegroundColor Red
    exit 1
}

$RulePrefix = "CF-LOCKDOWN"

# Remove old rules from previous runs
Get-NetFirewallRule -ErrorAction SilentlyContinue |
  Where-Object { $_.DisplayName -like "$RulePrefix*" } |
  Remove-NetFirewallRule -ErrorAction SilentlyContinue

# Block all outbound by default
Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Block

# Allow DNS (needed)
New-NetFirewallRule -DisplayName "$RulePrefix - Allow DNS UDP" -Direction Outbound -Action Allow -Protocol UDP -RemotePort 53 -Profile Any | Out-Null
New-NetFirewallRule -DisplayName "$RulePrefix - Allow DNS TCP" -Direction Outbound -Action Allow -Protocol TCP -RemotePort 53 -Profile Any | Out-Null

# Resolve IPs (IPv4 + IPv6), then unique them
$hostsToResolve = @(
  "codeforces.com","www.codeforces.com","mirror.codeforces.com","codeforces.org",
  "cloudflare.com","www.cloudflare.com","cloudflareinsights.com","challenges.cloudflare.com"
)

$ipList = @()

foreach ($h in $hostsToResolve) {
  try { $ipList += (Resolve-DnsName $h -Type A    -ErrorAction Stop | Select-Object -ExpandProperty IPAddress) } catch {}
  try { $ipList += (Resolve-DnsName $h -Type AAAA -ErrorAction Stop | Select-Object -ExpandProperty IPAddress) } catch {}
}

$ipList = $ipList | Where-Object { $_ } | Sort-Object -Unique

if ($ipList.Count -lt 1) {
  Write-Host "ERROR: Could not resolve any IPs. Restoring outbound allow." -ForegroundColor Red
  Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Allow
  exit 2
}

# Allow HTTP/HTTPS to those IPs
New-NetFirewallRule -DisplayName "$RulePrefix - Allow IP TCP 80/443" -Direction Outbound -Action Allow `
  -Protocol TCP -RemotePort 80,443 -RemoteAddress $ipList -Profile Any | Out-Null

# Allow QUIC (UDP 443) to those IPs (Chrome/Edge sometimes use QUIC)
New-NetFirewallRule -DisplayName "$RulePrefix - Allow IP UDP 443" -Direction Outbound -Action Allow `
  -Protocol UDP -RemotePort 443 -RemoteAddress $ipList -Profile Any | Out-Null

Write-Host "DONE: Allowed $($ipList.Count) IPs for Codeforces/Cloudflare only." -ForegroundColor Green
Write-Host "If access breaks later, re-run this script (IPs may change)."