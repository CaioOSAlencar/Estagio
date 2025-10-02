# =============================================================================
# SETUP AUTOMATIZADO - EC2-1 ServeRest (Windows)
# =============================================================================
# Script PowerShell para configurar automaticamente instância Windows EC2 com ServeRest
# Execute como Administrator: powershell -ExecutionPolicy Bypass -File setup-ec2-serverest-windows.ps1

param(
    [string]$InstallPath = "C:\ServeRest"
)

# Verificar se está executando como Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Error "❌ Este script deve ser executado como Administrator!"
    Write-Host "🔧 Clique com botão direito no PowerShell e selecione 'Executar como Administrador'" -ForegroundColor Yellow
    exit 1
}

# Cores para output
function Write-Status { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "[WARNING] $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

Write-Host "🚀 Iniciando setup do ServeRest na EC2 Windows..." -ForegroundColor Cyan
Write-Host "📂 Diretório de instalação: $InstallPath" -ForegroundColor Yellow
Write-Host ""

try {
    # =============================================================================
    # ETAPA 1: Configurar Execution Policy
    # =============================================================================
    Write-Status "Configurando Execution Policy..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Success "Execution Policy configurada!"

    # =============================================================================
    # ETAPA 2: Instalar Chocolatey
    # =============================================================================
    Write-Status "Verificando/Instalando Chocolatey..."
    
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Status "Instalando Chocolatey..."
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Atualizar PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Write-Success "Chocolatey instalado!"
    } else {
        Write-Success "Chocolatey já está instalado!"
    }

    # =============================================================================
    # ETAPA 3: Instalar Node.js
    # =============================================================================
    Write-Status "Instalando Node.js via Chocolatey..."
    choco install nodejs -y --force
    
    # Aguardar e atualizar PATH
    Start-Sleep -Seconds 5
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # Verificar instalação
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Success "Node.js instalado: $nodeVersion"
    Write-Success "npm instalado: $npmVersion"

    # =============================================================================
    # ETAPA 4: Instalar NSSM (Non-Sucking Service Manager)
    # =============================================================================
    Write-Status "Instalando NSSM para gerenciar serviços..."
    choco install nssm -y --force
    Write-Success "NSSM instalado!"

    # =============================================================================
    # ETAPA 5: Instalar ServeRest
    # =============================================================================
    Write-Status "Instalando ServeRest globalmente..."
    npm install -g serverest
    
    # Verificar instalação
    $serverestVersion = npx serverest --version
    Write-Success "ServeRest instalado: $serverestVersion"

    # =============================================================================
    # ETAPA 6: Criar Diretório e Configurações
    # =============================================================================
    Write-Status "Criando diretório de trabalho: $InstallPath"
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Set-Location $InstallPath

    # Criar script PowerShell para iniciar ServeRest
    $startScript = @"
# Script para iniciar ServeRest
Set-Location "$InstallPath"
Write-Host "`$(Get-Date): Iniciando ServeRest na porta 3000..." -ForegroundColor Green
try {
    npx serverest --porta 3000
} catch {
    Write-Host "`$(Get-Date): Erro ao iniciar ServeRest: `$_" -ForegroundColor Red
    Start-Sleep -Seconds 30
}
"@
    
    $startScript | Out-File -FilePath "$InstallPath\start-serverest.ps1" -Encoding UTF8
    Write-Success "Script de inicialização criado!"

    # =============================================================================
    # ETAPA 7: Configurar Serviço Windows
    # =============================================================================
    Write-Status "Configurando serviço Windows..."
    
    # Remover serviço existente se houver
    $existingService = Get-Service ServeRest -ErrorAction SilentlyContinue
    if ($existingService) {
        Write-Warning "Removendo serviço existente..."
        nssm stop ServeRest
        nssm remove ServeRest confirm
    }

    # Criar novo serviço
    nssm install ServeRest "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    nssm set ServeRest Arguments "-ExecutionPolicy Bypass -File `"$InstallPath\start-serverest.ps1`""
    nssm set ServeRest AppDirectory "$InstallPath"
    nssm set ServeRest DisplayName "ServeRest API Server"
    nssm set ServeRest Description "ServeRest API para testes automatizados - Porta 3000"
    nssm set ServeRest Start SERVICE_AUTO_START
    
    Write-Success "Serviço Windows configurado!"

    # =============================================================================
    # ETAPA 8: Configurar Firewall
    # =============================================================================
    Write-Status "Configurando Windows Firewall..."
    
    # Remover regra existente se houver
    Remove-NetFirewallRule -DisplayName "ServeRest" -ErrorAction SilentlyContinue
    
    # Criar nova regra
    New-NetFirewallRule -DisplayName "ServeRest" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
    Write-Success "Firewall configurado para porta 3000!"

    # =============================================================================
    # ETAPA 9: Iniciar Serviço
    # =============================================================================
    Write-Status "Iniciando serviço ServeRest..."
    nssm start ServeRest
    
    # Aguardar inicialização
    Write-Status "Aguardando inicialização do serviço..."
    Start-Sleep -Seconds 15
    
    # Verificar status do serviço
    $service = Get-Service ServeRest -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        Write-Success "Serviço ServeRest iniciado com sucesso!"
    } else {
        Write-Warning "Serviço pode estar ainda inicializando..."
    }

    # =============================================================================
    # ETAPA 10: Testar Conectividade
    # =============================================================================
    Write-Status "Testando conectividade local..."
    Start-Sleep -Seconds 10
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:3000/usuarios" -Method GET -TimeoutSec 10
        Write-Success "✅ ServeRest respondendo corretamente!"
        Write-Success "👥 Usuários encontrados: $($response.quantidade)"
    } catch {
        Write-Warning "⚠️ ServeRest pode estar ainda inicializando..."
        Write-Status "Aguarde mais alguns segundos e teste novamente..."
    }

    # =============================================================================
    # ETAPA 11: Criar Scripts Utilitários
    # =============================================================================
    Write-Status "Criando scripts utilitários..."
    
    # Script para verificar status
    $checkScript = @"
Write-Host "🔍 Status do ServeRest:" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

# Status do serviço
`$service = Get-Service ServeRest -ErrorAction SilentlyContinue
if (`$service) {
    Write-Host "🔧 Serviço: `$(`$service.Status)" -ForegroundColor Yellow
} else {
    Write-Host "❌ Serviço não encontrado!" -ForegroundColor Red
}

# Conectividade
Write-Host ""
Write-Host "📊 Conectividade:" -ForegroundColor Cyan
try {
    `$response = Invoke-RestMethod -Uri "http://localhost:3000/usuarios" -Method GET -TimeoutSec 5
    Write-Host "✅ ServeRest respondendo" -ForegroundColor Green
    Write-Host "👥 Usuários: `$(`$response.quantidade)" -ForegroundColor Yellow
} catch {
    Write-Host "❌ ServeRest não responde" -ForegroundColor Red
}

# IP Público
Write-Host ""
Write-Host "🌐 Informações de Rede:" -ForegroundColor Cyan
try {
    `$publicIP = Invoke-RestMethod -Uri "http://checkip.amazonaws.com/" -TimeoutSec 5
    Write-Host "📍 IP Público: `$publicIP" -ForegroundColor Yellow
    Write-Host "🔗 URL Externa: http://`${publicIP}:3000" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Erro ao obter IP público" -ForegroundColor Red
}

Write-Host ""
Write-Host "💾 Recursos do Sistema:" -ForegroundColor Cyan
Get-Process | Where-Object {`$_.ProcessName -like "*node*" -or `$_.ProcessName -like "*serverest*"} | 
    Select-Object ProcessName, @{Name="Memory(MB)";Expression={[math]::round(`$_.WorkingSet/1MB,2)}} |
    Format-Table -AutoSize
"@
    
    $checkScript | Out-File -FilePath "$InstallPath\check-serverest.ps1" -Encoding UTF8

    # Script para reiniciar ServeRest
    $restartScript = @"
Write-Host "🔄 Reiniciando ServeRest..." -ForegroundColor Cyan
try {
    Restart-Service ServeRest -Force
    Start-Sleep -Seconds 10
    Write-Host "✅ ServeRest reiniciado!" -ForegroundColor Green
    
    # Verificar status após reinicialização
    . "$InstallPath\check-serverest.ps1"
} catch {
    Write-Host "❌ Erro ao reiniciar ServeRest: `$_" -ForegroundColor Red
}
"@
    
    $restartScript | Out-File -FilePath "$InstallPath\restart-serverest.ps1" -Encoding UTF8

    Write-Success "Scripts utilitários criados!"

    # =============================================================================
    # ETAPA 12: Obter IP Público
    # =============================================================================
    Write-Status "Obtendo informações da instância..."
    try {
        $publicIP = Invoke-RestMethod -Uri "http://checkip.amazonaws.com/" -TimeoutSec 10
        Write-Success "IP Público da instância: $publicIP"
    } catch {
        Write-Warning "Não foi possível obter IP público automaticamente"
        $publicIP = "SEU-IP-PUBLICO"
    }

    # =============================================================================
    # INFORMAÇÕES FINAIS
    # =============================================================================
    Write-Host ""
    Write-Host "🎉 =============================================" -ForegroundColor Green
    Write-Host "    SETUP DO SERVEREST WINDOWS CONCLUÍDO!" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""
    Write-Success "✅ ServeRest configurado como serviço Windows"
    Write-Success "✅ Firewall configurado para porta 3000" 
    Write-Success "✅ Scripts utilitários criados"
    Write-Host ""
    Write-Host "📍 Informações importantes:" -ForegroundColor Cyan
    Write-Host "   🏠 Diretório: $InstallPath" -ForegroundColor Yellow
    Write-Host "   🌐 IP Público: $publicIP" -ForegroundColor Yellow
    Write-Host "   🔗 URL Externa: http://${publicIP}:3000" -ForegroundColor Yellow
    Write-Host "   🔧 Serviço: ServeRest (Auto-start habilitado)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔧 Scripts disponíveis:" -ForegroundColor Cyan
    Write-Host "   📊 $InstallPath\check-serverest.ps1    (verificar status)" -ForegroundColor Yellow
    Write-Host "   🔄 $InstallPath\restart-serverest.ps1  (reiniciar serviço)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⚠️ IMPORTANTE:" -ForegroundColor Red
    Write-Host "   Configure o Security Group da EC2 para liberar a porta 3000!" -ForegroundColor Yellow
    Write-Host "   AWS Console → EC2 → Security Groups → Add Inbound Rule:" -ForegroundColor Yellow
    Write-Host "   Type: Custom TCP, Port: 3000, Source: 0.0.0.0/0" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🧪 Para testar:" -ForegroundColor Cyan
    Write-Host "   Invoke-RestMethod -Uri 'http://localhost:3000/usuarios' -Method GET" -ForegroundColor Yellow
    Write-Host ""
    Write-Success "🚀 Setup concluído com sucesso!"
    
} catch {
    Write-Error "❌ Erro durante o setup: $_"
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Verifique se está executando como Administrator" -ForegroundColor Gray
    Write-Host "   2. Verifique conexão com internet" -ForegroundColor Gray
    Write-Host "   3. Execute novamente o script" -ForegroundColor Gray
    Write-Host ""
    exit 1
}