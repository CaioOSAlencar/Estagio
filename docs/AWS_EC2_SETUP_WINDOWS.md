# 🚀 AWS EC2 Setup - ServeRest + Robot Framework (Windows)

**Objetivo**: Configurar duas instâncias EC2 Windows separadas:
- **EC2-1**: Executar a aplicação ServeRest 
- **EC2-2**: Executar os testes Robot Framework

## 📋 Arquitetura da Solução

```
┌─────────────────┐    HTTP/API    ┌─────────────────┐
│   EC2-1         │◄──────────────►│   EC2-2         │
│   ServeRest     │                │   Robot Tests   │
│   Port: 3000    │                │   Python + RF   │
│   Windows       │                │   Windows       │
└─────────────────┘                └─────────────────┘
```

---

## 🏗️ PARTE 1: Criação das Instâncias EC2

### 1.1 Pré-requisitos
- ✅ Conta AWS ativa
- ✅ AWS CLI configurado (opcional)
- ✅ Conhecimento básico de PowerShell
- ✅ RDP Client para conexão remota

### 1.2 Criar Instâncias Windows
```powershell
# Via AWS Console
# Configuração recomendada:
# - Instance Type: t3.medium (Windows precisa mais recursos)
# - OS: Microsoft Windows Server 2022 Base
# - Security Group: Portas 3389 (RDP), 3000 (ServeRest), 80 (HTTP)
# - Key Pair: Criar/usar existente para RDP
```

---

## 🖥️ PARTE 2: EC2-1 - Setup ServeRest (Windows)

### 2.1 Conectar à Instância
```powershell
# Via RDP (Remote Desktop)
# 1. No AWS Console, pegar senha do Administrator
# 2. Usar Remote Desktop Connection
# Endereço: ec2-xx-xx-xx-xx.compute-1.amazonaws.com
# Usuário: Administrator
```

### 2.2 Instalar Chocolatey (Gerenciador de Pacotes)
```powershell
# Abrir PowerShell como Administrador
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Fechar e reabrir PowerShell
refreshenv
```

### 2.3 Instalar Node.js
```powershell
# Instalar Node.js via Chocolatey
choco install nodejs -y

# Verificar instalação
refreshenv
node --version
npm --version
```

### 2.4 Instalar e Configurar ServeRest
```powershell
# Instalar ServeRest globalmente
npm install -g serverest

# Criar diretório de trabalho
New-Item -ItemType Directory -Path "C:\ServeRest" -Force
Set-Location "C:\ServeRest"

# Verificar instalação
npx serverest --version
```

### 2.5 Criar Script de Inicialização
```powershell
# Criar script para iniciar ServeRest
$scriptContent = @"
@echo off
cd /d C:\ServeRest
echo Iniciando ServeRest...
npx serverest --porta 3000
pause
"@

$scriptContent | Out-File -FilePath "C:\ServeRest\start-serverest.bat" -Encoding ASCII

# Criar script PowerShell para serviço
$psScript = @"
Set-Location "C:\ServeRest"
Write-Host "Iniciando ServeRest na porta 3000..."
npx serverest --porta 3000
"@

$psScript | Out-File -FilePath "C:\ServeRest\start-serverest.ps1" -Encoding UTF8
```

### 2.6 Configurar como Serviço Windows
```powershell
# Instalar NSSM (Non-Sucking Service Manager)
choco install nssm -y
refreshenv

# Criar serviço
nssm install ServeRest "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
nssm set ServeRest Arguments "-ExecutionPolicy Bypass -File C:\ServeRest\start-serverest.ps1"
nssm set ServeRest AppDirectory "C:\ServeRest"
nssm set ServeRest DisplayName "ServeRest API Server"
nssm set ServeRest Description "ServeRest API para testes automatizados"

# Iniciar serviço
nssm start ServeRest

# Verificar status
Get-Service ServeRest
```

### 2.7 Configurar Firewall
```powershell
# Liberar porta 3000 no Windows Firewall
New-NetFirewallRule -DisplayName "ServeRest" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow

# Verificar regra criada
Get-NetFirewallRule -DisplayName "ServeRest"
```

### 2.8 Testar Funcionamento
```powershell
# Aguardar um pouco para o serviço iniciar
Start-Sleep -Seconds 10

# Testar localmente
Invoke-RestMethod -Uri "http://localhost:3000/usuarios" -Method GET

# Ver IP público para configurar EC2-2
Invoke-RestMethod -Uri "http://checkip.amazonaws.com/"
```

---

## 🤖 PARTE 3: EC2-2 - Setup Robot Framework (Windows)

### 3.1 Conectar à Segunda Instância
```powershell
# Via RDP - mesmo processo da EC2-1
# Endereço: ec2-yy-yy-yy-yy.compute-1.amazonaws.com
# Usuário: Administrator
```

### 3.2 Instalar Chocolatey e Dependências
```powershell
# Instalar Chocolatey (mesmo processo da EC2-1)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

refreshenv

# Instalar Python e Git
choco install python git -y
refreshenv

# Verificar instalação
python --version
pip --version
git --version
```

### 3.3 Clonar e Configurar Projeto
```powershell
# Criar diretório de trabalho
New-Item -ItemType Directory -Path "C:\RobotTests" -Force
Set-Location "C:\RobotTests"

# Clonar repositório
git clone https://github.com/CaioOSAlencar/Estagio.git
Set-Location "C:\RobotTests\Estagio\automation\robot-framework"

# Instalar dependências Robot Framework
pip install robotframework robotframework-requests robotframework-jsonlibrary

# Verificar instalação
robot --version
```

### 3.4 Configurar Variáveis de Ambiente
```powershell
# Solicitar IP da EC2-1
$serverestIP = Read-Host "Digite o IP público da EC2-1 (ServeRest)"

# Criar arquivo de configuração
$configContent = @"
# Configuração Robot Framework Windows
`$env:SERVEREST_BASE_URL = "http://$serverestIP:3000"
`$env:ROBOT_OUTPUT_DIR = "C:\RobotTests\Results"

# Criar diretório de resultados se não existir
if (!(Test-Path `$env:ROBOT_OUTPUT_DIR)) {
    New-Item -ItemType Directory -Path `$env:ROBOT_OUTPUT_DIR -Force
}

Write-Host "Configurado para usar ServeRest em: `$env:SERVEREST_BASE_URL" -ForegroundColor Green
"@

$configContent | Out-File -FilePath "C:\RobotTests\robot-config.ps1" -Encoding UTF8

# Carregar configuração
. "C:\RobotTests\robot-config.ps1"
```

### 3.5 Criar Scripts de Execução
```powershell
# Script principal de execução dos testes
$runTestsScript = @"
# Script para executar testes Robot Framework no Windows
. "C:\RobotTests\robot-config.ps1"

Write-Host "🚀 Iniciando execução dos testes Robot Framework" -ForegroundColor Cyan
Write-Host "🎯 Target ServeRest: `$env:SERVEREST_BASE_URL" -ForegroundColor Yellow
Write-Host "📁 Resultados em: `$env:ROBOT_OUTPUT_DIR" -ForegroundColor Yellow
Write-Host ""

Set-Location "C:\RobotTests\Estagio\automation\robot-framework"

# Verificar conectividade com ServeRest
Write-Host "📡 Testando conectividade com ServeRest..." -ForegroundColor Blue
try {
    `$response = Invoke-RestMethod -Uri "`$env:SERVEREST_BASE_URL/usuarios" -Method GET -TimeoutSec 10
    Write-Host "✅ ServeRest acessível!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro: ServeRest não está acessível em `$env:SERVEREST_BASE_URL" -ForegroundColor Red
    Write-Host "🔍 Verifique se:" -ForegroundColor Yellow
    Write-Host "  - A instância EC2-1 está rodando" -ForegroundColor Yellow
    Write-Host "  - O ServeRest está ativo na EC2-1" -ForegroundColor Yellow
    Write-Host "  - O Security Group permite tráfego na porta 3000" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🧪 Executando testes básicos..." -ForegroundColor Cyan
robot --outputdir "`$env:ROBOT_OUTPUT_DIR" ``
      --variable BASE_URL:`$env:SERVEREST_BASE_URL ``
      --name "Testes_Basicos_AWS_Windows" ``
      tests\auth\test_basic_working.robot

Write-Host ""
Write-Host "🧪 Executando testes completos..." -ForegroundColor Cyan
robot --outputdir "`$env:ROBOT_OUTPUT_DIR" ``
      --variable BASE_URL:`$env:SERVEREST_BASE_URL ``
      --name "Testes_Completos_AWS_Windows" ``
      tests\complete\test_serverest_complete.robot

Write-Host ""
Write-Host "✅ Execução concluída!" -ForegroundColor Green
Write-Host "📊 Resultados disponíveis em: `$env:ROBOT_OUTPUT_DIR" -ForegroundColor Yellow
Get-ChildItem `$env:ROBOT_OUTPUT_DIR
"@

$runTestsScript | Out-File -FilePath "C:\RobotTests\run-tests.ps1" -Encoding UTF8

# Script de teste rápido
$quickTestScript = @"
# Teste rápido de conectividade Windows
. "C:\RobotTests\robot-config.ps1"

Write-Host "🔍 Teste rápido de conectividade" -ForegroundColor Cyan
Write-Host "🎯 Target: `$env:SERVEREST_BASE_URL" -ForegroundColor Yellow

# Testar endpoints básicos
Write-Host "📡 Testando /usuarios..." -ForegroundColor Blue
try {
    `$usuarios = Invoke-RestMethod -Uri "`$env:SERVEREST_BASE_URL/usuarios" -Method GET
    Write-Host "✅ Endpoint /usuarios OK - Encontrados: `$(`$usuarios.quantidade) usuários" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no endpoint /usuarios" -ForegroundColor Red
}

Write-Host "📡 Testando /produtos..." -ForegroundColor Blue
try {
    `$produtos = Invoke-RestMethod -Uri "`$env:SERVEREST_BASE_URL/produtos" -Method GET
    Write-Host "✅ Endpoint /produtos OK - Encontrados: `$(`$produtos.quantidade) produtos" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no endpoint /produtos" -ForegroundColor Red
}

Write-Host "✅ Teste de conectividade concluído!" -ForegroundColor Green
"@

$quickTestScript | Out-File -FilePath "C:\RobotTests\quick-test.ps1" -Encoding UTF8
```

### 3.6 Executar Teste Inicial
```powershell
# Executar teste de conectividade
. "C:\RobotTests\quick-test.ps1"

# Se conectividade OK, executar testes completos
. "C:\RobotTests\run-tests.ps1"
```

---

## 📊 PARTE 4: Scripts de Monitoramento

### 4.1 Script de Monitoramento (EC2-1)
```powershell
# Na EC2-1, criar script de monitoramento do ServeRest
$monitorScript = @"
# Monitor ServeRest Windows
while (`$true) {
    Clear-Host
    Write-Host "🖥️ Monitor ServeRest - `$(Get-Date)" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    
    # Status do serviço
    `$service = Get-Service ServeRest -ErrorAction SilentlyContinue
    if (`$service) {
        if (`$service.Status -eq "Running") {
            Write-Host "✅ Serviço ServeRest: RODANDO" -ForegroundColor Green
        } else {
            Write-Host "❌ Serviço ServeRest: PARADO" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Serviço ServeRest: NÃO ENCONTRADO" -ForegroundColor Red
    }
    
    # Teste de conectividade
    try {
        `$response = Invoke-RestMethod -Uri "http://localhost:3000/usuarios" -Method GET -TimeoutSec 5
        Write-Host "✅ API ServeRest: RESPONDENDO" -ForegroundColor Green
        Write-Host "👥 Usuários cadastrados: `$(`$response.quantidade)" -ForegroundColor Yellow
    } catch {
        Write-Host "❌ API ServeRest: NÃO RESPONDE" -ForegroundColor Red
    }
    
    # Recursos do sistema
    Write-Host ""
    Write-Host "💾 Uso de Memória:" -ForegroundColor Blue
    Get-Process | Where-Object {`$_.ProcessName -like "*node*" -or `$_.ProcessName -like "*serverest*"} | 
        Select-Object ProcessName, @{Name="Memory(MB)";Expression={[math]::round(`$_.WorkingSet/1MB,2)}} |
        Format-Table -AutoSize
    
    Write-Host "Press Ctrl+C to exit..." -ForegroundColor Gray
    Start-Sleep -Seconds 30
}
"@

$monitorScript | Out-File -FilePath "C:\ServeRest\monitor-serverest.ps1" -Encoding UTF8
```

### 4.2 Script de Monitoramento (EC2-2)
```powershell
# Na EC2-2, criar script de monitoramento dos testes
$monitorTestsScript = @"
# Monitor Robot Framework Windows
. "C:\RobotTests\robot-config.ps1"

while (`$true) {
    Clear-Host
    Write-Host "🖥️ Monitor Robot Framework - `$(Get-Date)" -ForegroundColor Cyan
    Write-Host "🎯 Target: `$env:SERVEREST_BASE_URL" -ForegroundColor Yellow
    Write-Host "================================" -ForegroundColor Cyan
    
    # Status da conectividade
    try {
        `$response = Invoke-RestMethod -Uri "`$env:SERVEREST_BASE_URL/usuarios" -Method GET -TimeoutSec 5
        Write-Host "✅ ServeRest: ONLINE" -ForegroundColor Green
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
    Write-Host "💾 Uso de disco:" -ForegroundColor Blue
    Get-PSDrive C | Select-Object Name, @{Name="Used(GB)";Expression={[math]::round(`$_.Used/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::round(`$_.Free/1GB,2)}}
    
    Write-Host ""
    Write-Host "Press Ctrl+C to exit..." -ForegroundColor Gray
    Start-Sleep -Seconds 30
}
"@

$monitorTestsScript | Out-File -FilePath "C:\RobotTests\monitor-tests.ps1" -Encoding UTF8
```

---

## 🔧 PARTE 5: Scripts Utilitários

### 5.1 Scripts para EC2-1 (ServeRest)
```powershell
# Script para verificar status
$checkScript = @"
Write-Host "🔍 Status do ServeRest:" -ForegroundColor Cyan
Get-Service ServeRest

Write-Host ""
Write-Host "📊 Conectividade:" -ForegroundColor Cyan
try {
    `$response = Invoke-RestMethod -Uri "http://localhost:3000/usuarios" -Method GET
    Write-Host "✅ ServeRest respondendo - Usuários: `$(`$response.quantidade)" -ForegroundColor Green
} catch {
    Write-Host "❌ ServeRest não responde" -ForegroundColor Red
}

Write-Host ""
Write-Host "🌐 IP Público:" -ForegroundColor Cyan
try {
    `$publicIP = Invoke-RestMethod -Uri "http://checkip.amazonaws.com/"
    Write-Host "📍 `$publicIP" -ForegroundColor Yellow
    Write-Host "🔗 URL Externa: http://`${publicIP}:3000" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Erro ao obter IP público" -ForegroundColor Red
}
"@

$checkScript | Out-File -FilePath "C:\ServeRest\check-serverest.ps1" -Encoding UTF8

# Script para reiniciar ServeRest
$restartScript = @"
Write-Host "🔄 Reiniciando ServeRest..." -ForegroundColor Cyan
Restart-Service ServeRest
Start-Sleep -Seconds 5
Write-Host "✅ ServeRest reiniciado!" -ForegroundColor Green
. "C:\ServeRest\check-serverest.ps1"
"@

$restartScript | Out-File -FilePath "C:\ServeRest\restart-serverest.ps1" -Encoding UTF8
```

---

## 🎯 PARTE 6: Validação da Implementação

### Checklist Final Windows:
- [ ] EC2-1 rodando Windows Server com ServeRest na porta 3000
- [ ] EC2-2 rodando Windows Server executando testes Robot Framework
- [ ] Comunicação entre as instâncias funcionando
- [ ] Testes passando com 100% de sucesso
- [ ] Scripts PowerShell funcionando corretamente
- [ ] Firewall Windows configurado
- [ ] Serviços Windows criados e funcionando

---

## 🚨 Troubleshooting Windows

### Problemas Comuns:

1. **Execution Policy Error**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Serviço não inicia**
   ```powershell
   # Verificar logs
   Get-EventLog -LogName System -Source "Service Control Manager" | Where-Object {$_.Message -like "*ServeRest*"}
   
   # Reiniciar serviço
   Restart-Service ServeRest -Force
   ```

3. **Firewall bloqueando**
   ```powershell
   # Verificar regras
   Get-NetFirewallRule -DisplayName "ServeRest"
   
   # Recriar regra se necessário
   Remove-NetFirewallRule -DisplayName "ServeRest"
   New-NetFirewallRule -DisplayName "ServeRest" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
   ```

4. **Problema com PowerShell Scripts**
   ```powershell
   # Verificar se está executando como Administrator
   if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
   {
       Write-Host "Execute como Administrator!" -ForegroundColor Red
       exit 1
   }
   ```

---

## 💰 Parte 7: Otimização de Custos Windows

### 7.1 Auto-Shutdown
```powershell
# Agendar desligamento automático
# Via Task Scheduler ou comando direto:
schtasks /create /tn "Auto Shutdown" /tr "shutdown /s /f /t 0" /sc daily /st 22:00
```

### 7.2 Scripts de Economia
```powershell
# Script para parar instâncias (executar do seu PC com AWS CLI)
aws ec2 stop-instances --instance-ids i-1234567890abcdef0 i-0987654321fedcba0

# Script para iniciar instâncias  
aws ec2 start-instances --instance-ids i-1234567890abcdef0 i-0987654321fedcba0
```

---

**🏆 Resultado Final Windows**: Arquitetura distribuída profissional rodando na AWS com Windows Server! 🎉