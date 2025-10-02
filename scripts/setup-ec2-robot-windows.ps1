# =============================================================================
# SETUP AUTOMATIZADO - EC2-2 Robot Framework (Windows)
# =============================================================================
# Script PowerShell para configurar automaticamente instância Windows EC2 com Robot Framework
# Execute como Administrator: powershell -ExecutionPolicy Bypass -File setup-ec2-robot-windows.ps1

param(
    [string]$InstallPath = "C:\RobotTests",
    [string]$ServerestIP = ""
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

Write-Host "🤖 Iniciando setup do Robot Framework na EC2 Windows..." -ForegroundColor Cyan
Write-Host "📂 Diretório de instalação: $InstallPath" -ForegroundColor Yellow
Write-Host ""

# Solicitar IP do ServeRest se não foi fornecido
if ([string]::IsNullOrEmpty($ServerestIP)) {
    Write-Host "🎯 Configuração do Robot Framework" -ForegroundColor Cyan
    Write-Host ""
    $ServerestIP = Read-Host "📡 Digite o IP público da EC2 que roda o ServeRest"
    
    if ([string]::IsNullOrEmpty($ServerestIP)) {
        Write-Error "IP do ServeRest é obrigatório!"
        exit 1
    }
}

Write-Status "IP do ServeRest configurado: $ServerestIP"

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
    # ETAPA 3: Instalar Python e Git
    # =============================================================================
    Write-Status "Instalando Python e Git via Chocolatey..."
    choco install python git -y --force
    
    # Aguardar e atualizar PATH
    Start-Sleep -Seconds 5
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # Verificar instalação
    $pythonVersion = python --version
    $gitVersion = git --version
    $pipVersion = pip --version
    Write-Success "Python instalado: $pythonVersion"
    Write-Success "Git instalado: $gitVersion" 
    Write-Success "pip instalado: $pipVersion"

    # =============================================================================
    # ETAPA 4: Criar Diretório e Clonar Repositório
    # =============================================================================
    Write-Status "Criando diretório de trabalho: $InstallPath"
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Set-Location $InstallPath

    Write-Status "Clonando repositório do projeto..."
    if (Test-Path "Estagio") {
        Write-Warning "Diretório Estagio já existe, atualizando..."
        Set-Location "Estagio"
        git pull
        Set-Location ..
    } else {
        git clone https://github.com/CaioOSAlencar/Estagio.git
    }
    Write-Success "Repositório clonado/atualizado!"

    # =============================================================================
    # ETAPA 5: Instalar Robot Framework
    # =============================================================================
    Write-Status "Instalando Robot Framework e dependências..."
    pip install robotframework robotframework-requests robotframework-jsonlibrary
    
    # Verificar instalação
    $robotVersion = robot --version 2>$null
    if ([string]::IsNullOrEmpty($robotVersion)) {
        $robotVersion = python -m robot --version
    }
    Write-Success "Robot Framework instalado: $robotVersion"

    # =============================================================================
    # ETAPA 6: Configurar Variáveis de Ambiente
    # =============================================================================
    Write-Status "Configurando variáveis de ambiente..."
    
    $configContent = @"
# Configuração Robot Framework Windows
`$env:SERVEREST_BASE_URL = "http://$ServerestIP:3000"
`$env:ROBOT_OUTPUT_DIR = "$InstallPath\Results"

# Criar diretório de resultados se não existir
if (!(Test-Path `$env:ROBOT_OUTPUT_DIR)) {
    New-Item -ItemType Directory -Path `$env:ROBOT_OUTPUT_DIR -Force | Out-Null
}

Write-Host "🎯 Configurado para usar ServeRest em: `$env:SERVEREST_BASE_URL" -ForegroundColor Green
"@
    
    $configContent | Out-File -FilePath "$InstallPath\robot-config.ps1" -Encoding UTF8
    
    # Carregar configuração
    . "$InstallPath\robot-config.ps1"
    
    Write-Success "Variáveis configuradas!"
    Write-Status "ServeRest Target: $env:SERVEREST_BASE_URL"

    # =============================================================================
    # ETAPA 7: Criar Scripts de Execução
    # =============================================================================
    Write-Status "Criando scripts de execução..."

    # Script principal de execução
    $runTestsScript = @"
# Script para executar testes Robot Framework no Windows
. "$InstallPath\robot-config.ps1"

Write-Host "🚀 Iniciando execução dos testes Robot Framework" -ForegroundColor Cyan
Write-Host "🎯 Target ServeRest: `$env:SERVEREST_BASE_URL" -ForegroundColor Yellow
Write-Host "📁 Resultados em: `$env:ROBOT_OUTPUT_DIR" -ForegroundColor Yellow
Write-Host ""

Set-Location "$InstallPath\Estagio\automation\robot-framework"

# Verificar conectividade com ServeRest
Write-Host "📡 Testando conectividade com ServeRest..." -ForegroundColor Blue
try {
    `$response = Invoke-RestMethod -Uri "`$env:SERVEREST_BASE_URL/usuarios" -Method GET -TimeoutSec 10
    Write-Host "✅ ServeRest acessível! Usuários encontrados: `$(`$response.quantidade)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro: ServeRest não está acessível em `$env:SERVEREST_BASE_URL" -ForegroundColor Red
    Write-Host "🔍 Verifique se:" -ForegroundColor Yellow
    Write-Host "  - A instância EC2-1 está rodando" -ForegroundColor Yellow
    Write-Host "  - O ServeRest está ativo na EC2-1" -ForegroundColor Yellow  
    Write-Host "  - O Security Group permite tráfego na porta 3000" -ForegroundColor Yellow
    Write-Host "  - O IP `$ServerestIP está correto" -ForegroundColor Yellow
    Read-Host "Pressione Enter para continuar mesmo assim ou Ctrl+C para cancelar"
}

Write-Host ""
Write-Host "🧪 Executando testes básicos..." -ForegroundColor Cyan
try {
    robot --outputdir "`$env:ROBOT_OUTPUT_DIR" ``
          --variable BASE_URL:`$env:SERVEREST_BASE_URL ``
          --name "Testes_Basicos_AWS_Windows" ``
          --log "log_basicos.html" ``
          --report "report_basicos.html" ``
          tests\auth\test_basic_working.robot
    Write-Host "✅ Testes básicos concluídos!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro nos testes básicos: `$_" -ForegroundColor Red
}

Write-Host ""
Write-Host "🧪 Executando testes completos..." -ForegroundColor Cyan
try {
    robot --outputdir "`$env:ROBOT_OUTPUT_DIR" ``
          --variable BASE_URL:`$env:SERVEREST_BASE_URL ``
          --name "Testes_Completos_AWS_Windows" ``
          --log "log_completos.html" ``
          --report "report_completos.html" ``
          tests\complete\test_serverest_complete.robot
    Write-Host "✅ Testes completos concluídos!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro nos testes completos: `$_" -ForegroundColor Red
}

Write-Host ""
Write-Host "✅ Execução concluída!" -ForegroundColor Green
Write-Host "📊 Resultados disponíveis em: `$env:ROBOT_OUTPUT_DIR" -ForegroundColor Yellow
Get-ChildItem `$env:ROBOT_OUTPUT_DIR | Format-Table Name, Length, LastWriteTime
Write-Host ""
Write-Host "🌐 Para ver relatórios HTML, abra no navegador:" -ForegroundColor Cyan
Get-ChildItem "`$env:ROBOT_OUTPUT_DIR\*.html" | ForEach-Object {
    Write-Host "   📄 `$(`$_.FullName)" -ForegroundColor Yellow
}
"@
    
    $runTestsScript | Out-File -FilePath "$InstallPath\run-tests.ps1" -Encoding UTF8

    # Script de teste rápido
    $quickTestScript = @"
# Teste rápido de conectividade Windows
. "$InstallPath\robot-config.ps1"

Write-Host "🔍 Teste rápido de conectividade" -ForegroundColor Cyan
Write-Host "🎯 Target: `$env:SERVEREST_BASE_URL" -ForegroundColor Yellow
Write-Host ""

# Testar endpoints básicos
Write-Host "📡 Testando /usuarios..." -ForegroundColor Blue
try {
    `$usuarios = Invoke-RestMethod -Uri "`$env:SERVEREST_BASE_URL/usuarios" -Method GET -TimeoutSec 5
    Write-Host "✅ Endpoint /usuarios OK - Encontrados: `$(`$usuarios.quantidade) usuários" -ForegroundColor Green
    
    if (`$usuarios.quantidade -gt 0) {
        Write-Host "👤 Primeiro usuário: `$(`$usuarios.usuarios[0].nome)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erro no endpoint /usuarios: `$(`$_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📡 Testando /produtos..." -ForegroundColor Blue
try {
    `$produtos = Invoke-RestMethod -Uri "`$env:SERVEREST_BASE_URL/produtos" -Method GET -TimeoutSec 5
    Write-Host "✅ Endpoint /produtos OK - Encontrados: `$(`$produtos.quantidade) produtos" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no endpoint /produtos: `$(`$_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📡 Testando /login..." -ForegroundColor Blue
try {
    # Teste básico do endpoint de login (deve retornar erro mas endpoint deve responder)
    `$loginTest = Invoke-RestMethod -Uri "`$env:SERVEREST_BASE_URL/login" -Method POST -Body '{}' -ContentType 'application/json' -ErrorAction SilentlyContinue
    Write-Host "✅ Endpoint /login responde (testado com payload vazio)" -ForegroundColor Green
} catch {
    if (`$_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✅ Endpoint /login OK (retornou erro 400 como esperado para payload vazio)" -ForegroundColor Green
    } else {
        Write-Host "❌ Erro inesperado no endpoint /login: `$(`$_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🖥️ Informações do sistema:" -ForegroundColor Cyan
Write-Host "   💻 IP desta máquina: `$(Test-NetConnection -ComputerName checkip.amazonaws.com -Port 80 -InformationLevel Quiet; if (`$?) { Invoke-RestMethod -Uri 'http://checkip.amazonaws.com/' })" -ForegroundColor Yellow
Write-Host "   🎯 Target ServeRest: $ServerestIP" -ForegroundColor Yellow
Write-Host "   📁 Diretório de trabalho: $InstallPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ Teste de conectividade concluído!" -ForegroundColor Green
"@
    
    $quickTestScript | Out-File -FilePath "$InstallPath\quick-test.ps1" -Encoding UTF8

    # Script de monitoramento
    $monitorScript = @"
# Monitor Robot Framework Windows
. "$InstallPath\robot-config.ps1"

while (`$true) {
    Clear-Host
    Write-Host "🖥️ Monitor Robot Framework - `$(Get-Date)" -ForegroundColor Cyan
    Write-Host "🎯 Target: `$env:SERVEREST_BASE_URL" -ForegroundColor Yellow
    Write-Host "================================" -ForegroundColor Cyan
    
    # Status da conectividade
    try {
        `$response = Invoke-RestMethod -Uri "`$env:SERVEREST_BASE_URL/usuarios" -Method GET -TimeoutSec 5
        Write-Host "✅ ServeRest: ONLINE (`$(`$response.quantidade) usuários)" -ForegroundColor Green
    } catch {
        Write-Host "❌ ServeRest: OFFLINE" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "📊 Últimos resultados de teste:" -ForegroundColor Blue
    if (Test-Path `$env:ROBOT_OUTPUT_DIR) {
        Get-ChildItem `$env:ROBOT_OUTPUT_DIR -File | 
            Sort-Object LastWriteTime -Descending | 
            Select-Object -First 5 Name, LastWriteTime, @{Name="Size(KB)";Expression={[math]::round(`$_.Length/1KB,2)}} |
            Format-Table -AutoSize
    } else {
        Write-Host "Nenhum resultado encontrado ainda." -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "💾 Uso de disco (Drive C:):" -ForegroundColor Blue
    Get-PSDrive C | Select-Object Name, @{Name="Used(GB)";Expression={[math]::round(`$_.Used/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::round(`$_.Free/1GB,2)}} | Format-Table
    
    Write-Host ""
    Write-Host "🔄 Processos Python/Robot:" -ForegroundColor Blue
    Get-Process | Where-Object {`$_.ProcessName -like "*python*" -or `$_.ProcessName -like "*robot*"} | 
        Select-Object ProcessName, @{Name="Memory(MB)";Expression={[math]::round(`$_.WorkingSet/1MB,2)}} |
        Format-Table -AutoSize
    
    Write-Host ""
    Write-Host "Press Ctrl+C to exit..." -ForegroundColor Gray
    Start-Sleep -Seconds 30
}
"@
    
    $monitorScript | Out-File -FilePath "$InstallPath\monitor-tests.ps1" -Encoding UTF8

    Write-Success "Scripts de execução criados!"

    # =============================================================================
    # ETAPA 8: Testar Conectividade Inicial  
    # =============================================================================
    Write-Status "Testando conectividade inicial..."
    Start-Sleep -Seconds 3
    
    try {
        $response = Invoke-RestMethod -Uri "http://${ServerestIP}:3000/usuarios" -Method GET -TimeoutSec 10
        Write-Success "✅ Conectividade com ServeRest OK! Usuários encontrados: $($response.quantidade)"
    } catch {
        Write-Warning "⚠️ ServeRest não acessível ainda. Verifique:"
        Write-Host "  1. Se a EC2-1 está rodando" -ForegroundColor Gray
        Write-Host "  2. Se o ServeRest está ativo" -ForegroundColor Gray
        Write-Host "  3. Se o Security Group permite porta 3000" -ForegroundColor Gray
        Write-Host "  4. Se o IP $ServerestIP está correto" -ForegroundColor Gray
    }

    # =============================================================================
    # ETAPA 9: Executar Teste de Exemplo
    # =============================================================================
    Write-Status "Criando teste de conectividade simples..."
    
    $simpleTestPath = "$InstallPath\test_connectivity_simple.robot"
    $simpleTestContent = @"
*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Variables ***
`${BASE_URL}    http://$ServerestIP:3000

*** Test Cases ***
Test ServeRest Connectivity Windows
    [Documentation]    Teste básico de conectividade com ServeRest na AWS
    [Tags]    connectivity    aws    windows
    
    # Criar sessão HTTP
    Create Session    serverest    `${BASE_URL}    verify=False
    
    # Testar endpoint de usuários
    `${response}=    GET On Session    serverest    /usuarios    expected_status=200
    
    # Validar resposta
    `${json_data}=    Set Variable    `${response.json()}
    Dictionary Should Contain Key    `${json_data}    usuarios
    Dictionary Should Contain Key    `${json_data}    quantidade
    
    `${quantidade}=    Get From Dictionary    `${json_data}    quantidade
    Should Be True    `${quantidade} >= 0
    
    Log    ✅ ServeRest conectado com sucesso! Usuários encontrados: `${quantidade}
    Log    🌐 Testando de: Windows EC2-2
    Log    🎯 Conectando em: `${BASE_URL}
"@
    
    $simpleTestContent | Out-File -FilePath $simpleTestPath -Encoding UTF8
    
    if (Test-NetConnection -ComputerName $ServerestIP -Port 3000 -InformationLevel Quiet) {
        Write-Status "Executando teste de exemplo..."
        try {
            Set-Location "$InstallPath"
            robot --outputdir "$env:ROBOT_OUTPUT_DIR" --name "Teste_Conectividade_Windows" $simpleTestPath
            Write-Success "Teste de exemplo executado!"
        } catch {
            Write-Warning "Erro no teste de exemplo, mas instalação está OK"
        }
    } else {
        Write-Warning "Pulando teste de exemplo - ServeRest não acessível na porta 3000"
    }

    # =============================================================================
    # INFORMAÇÕES FINAIS
    # =============================================================================
    Write-Host ""
    Write-Host "🤖 =============================================" -ForegroundColor Green
    Write-Host "    SETUP DO ROBOT FRAMEWORK WINDOWS CONCLUÍDO!" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""
    Write-Success "✅ Robot Framework configurado e pronto para uso!"
    
    # Obter IP desta instância
    try {
        $thisIP = Invoke-RestMethod -Uri "http://checkip.amazonaws.com/" -TimeoutSec 5
        Write-Status "IP desta instância (EC2-2): $thisIP"
    } catch {
        Write-Status "IP desta instância: Não foi possível obter automaticamente"
    }
    
    Write-Status "Target ServeRest: http://${ServerestIP}:3000"
    Write-Status "Diretório de trabalho: $InstallPath"
    Write-Status "Resultados em: $env:ROBOT_OUTPUT_DIR"
    Write-Host ""
    Write-Host "🔧 Scripts disponíveis:" -ForegroundColor Cyan
    Write-Host "   🧪 $InstallPath\run-tests.ps1      (executar todos os testes)" -ForegroundColor Yellow
    Write-Host "   ⚡ $InstallPath\quick-test.ps1     (teste rápido de conectividade)" -ForegroundColor Yellow
    Write-Host "   📊 $InstallPath\monitor-tests.ps1  (monitor contínuo)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🚀 Para executar os testes:" -ForegroundColor Cyan
    Write-Host "   . '$InstallPath\run-tests.ps1'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📡 Para testar conectividade:" -ForegroundColor Cyan
    Write-Host "   . '$InstallPath\quick-test.ps1'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📊 Para monitorar em tempo real:" -ForegroundColor Cyan
    Write-Host "   . '$InstallPath\monitor-tests.ps1'" -ForegroundColor Yellow
    Write-Host ""
    
    if (Test-NetConnection -ComputerName $ServerestIP -Port 3000 -InformationLevel Quiet) {
        Write-Success "🎉 Tudo pronto! ServeRest acessível e Robot Framework configurado!"
    } else {
        Write-Warning "⚠️ Configure o ServeRest na EC2-1 e Security Group antes de executar os testes"
        Write-Host "   1. Verifique se EC2-1 está rodando" -ForegroundColor Gray
        Write-Host "   2. Verifique se ServeRest está ativo na EC2-1" -ForegroundColor Gray
        Write-Host "   3. Configure Security Group para permitir porta 3000" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Success "🚀 Setup concluído com sucesso!"
    
} catch {
    Write-Error "❌ Erro durante o setup: $_"
    Write-Host ""
    Write-Host "🔧 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   1. Verifique se está executando como Administrator" -ForegroundColor Gray
    Write-Host "   2. Verifique conexão com internet" -ForegroundColor Gray
    Write-Host "   3. Verifique se o IP $ServerestIP está correto" -ForegroundColor Gray
    Write-Host "   4. Execute novamente o script" -ForegroundColor Gray
    Write-Host ""
    exit 1
}