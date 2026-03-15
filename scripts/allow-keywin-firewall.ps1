$ErrorActionPreference = 'Stop'

$base = 'D:\keywin copy\build\bin'
$programRules = @(
  @{ DisplayName='KeyWin Daemon In'; Direction='Inbound'; Program=(Join-Path $base 'keywin-daemon.exe') },
  @{ DisplayName='KeyWin Daemon Out'; Direction='Outbound'; Program=(Join-Path $base 'keywin-daemon.exe') },
  @{ DisplayName='KeyWin Server In'; Direction='Inbound'; Program=(Join-Path $base 'keywin-server.exe') },
  @{ DisplayName='KeyWin Server Out'; Direction='Outbound'; Program=(Join-Path $base 'keywin-server.exe') },
  @{ DisplayName='KeyWin Client In'; Direction='Inbound'; Program=(Join-Path $base 'keywin-client.exe') },
  @{ DisplayName='KeyWin Client Out'; Direction='Outbound'; Program=(Join-Path $base 'keywin-client.exe') },
  @{ DisplayName='KeyWin GUI In'; Direction='Inbound'; Program=(Join-Path $base 'keywin.exe') },
  @{ DisplayName='KeyWin GUI Out'; Direction='Outbound'; Program=(Join-Path $base 'keywin.exe') }
)

foreach ($r in $programRules) {
  if (-not (Get-NetFirewallRule -DisplayName $r.DisplayName -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $r.DisplayName -Direction $r.Direction -Action Allow -Program $r.Program -Profile Any | Out-Null
  }
}

$portRules = @(
  @{ DisplayName='KeyWin Port TCP 24800 In'; Direction='Inbound'; Protocol='TCP'; LocalPort='24800' },
  @{ DisplayName='KeyWin Port TCP 24800 Out'; Direction='Outbound'; Protocol='TCP'; RemotePort='24800' },
  @{ DisplayName='KeyWin Port UDP 24800-24801 In'; Direction='Inbound'; Protocol='UDP'; LocalPort='24800-24801' },
  @{ DisplayName='KeyWin Port UDP 24800-24801 Out'; Direction='Outbound'; Protocol='UDP'; RemotePort='24800-24801' }
)

foreach ($r in $portRules) {
  if (-not (Get-NetFirewallRule -DisplayName $r.DisplayName -ErrorAction SilentlyContinue)) {
    $params = @{
      DisplayName = $r.DisplayName
      Direction   = $r.Direction
      Action      = 'Allow'
      Protocol    = $r.Protocol
      Profile     = 'Any'
    }

    if ($r.ContainsKey('LocalPort')) {
      $params['LocalPort'] = $r.LocalPort
    }
    if ($r.ContainsKey('RemotePort')) {
      $params['RemotePort'] = $r.RemotePort
    }

    New-NetFirewallRule @params | Out-Null
  }
}

Get-NetFirewallRule -DisplayName 'KeyWin*' |
  Select-Object DisplayName, Enabled, Direction, Action |
  Sort-Object DisplayName
