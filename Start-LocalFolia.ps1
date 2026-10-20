param([int]$MaxHeapMB = 2048)

$ErrorActionPreference = 'Stop'
$serverDir = Join-Path $PSScriptRoot '.local-folia'
$serverJar = Join-Path $serverDir 'folia-1.21.11-14.jar'
$pluginJar = Join-Path $PSScriptRoot 'bukkit/build/libs/grimac-bukkit-2.3.74-2b2t-entityspeed40.jar'
if (!(Test-Path -LiteralPath $serverJar) -or !(Test-Path -LiteralPath $pluginJar)) {
    throw 'Build the fork and download Folia 1.21.11 build 14 first. See ENTITYSPEED-FORK.md.'
}
if (Get-NetTCPConnection -State Listen -LocalPort 25565 -ErrorAction SilentlyContinue) {
    throw 'Port 25565 is already in use. Stop the existing server first.'
}
if ((Get-FileHash -LiteralPath $serverJar -Algorithm SHA256).Hash -ne 'f52c408490a0225611e67907a3ca19f7e6da2c6bc899e715d5f46844e7103c39') {
    throw 'Folia SHA256 mismatch.'
}
New-Item -ItemType Directory -Force (Join-Path $serverDir 'plugins') | Out-Null
Copy-Item -LiteralPath $pluginJar -Destination (Join-Path $serverDir 'plugins/GrimAC-entityspeed40.jar') -Force
if (!(Test-Path -LiteralPath (Join-Path $serverDir 'server.properties'))) {
    @'
server-ip=127.0.0.1
server-port=25565
online-mode=true
allow-flight=false
motd=2b2t.org.ru EntitySpeed 40 km/h test - Folia 1.21.11
view-distance=6
simulation-distance=4
spawn-protection=0
max-players=5
enable-query=false
enable-rcon=false
'@ | Set-Content -LiteralPath (Join-Path $serverDir 'server.properties') -Encoding ASCII
}
'eula=true' | Set-Content -LiteralPath (Join-Path $serverDir 'eula.txt') -Encoding ASCII
Push-Location $serverDir
try {
    & java '-Xms512M' "-Xmx${MaxHeapMB}M" '-jar' $serverJar 'nogui'
    if ($LASTEXITCODE -ne 0) { throw "Folia exited with code $LASTEXITCODE" }
} finally {
    Pop-Location
}
