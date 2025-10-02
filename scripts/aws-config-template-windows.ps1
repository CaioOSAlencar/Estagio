# =============================================================================
# CONFIGURAÇÃO AWS EC2 WINDOWS - TEMPLATE
# =============================================================================
# Copie este arquivo e edite com suas informações

# INFORMAÇÕES DAS INSTÂNCIAS EC2 WINDOWS
$EC2_1_PUBLIC_IP = "3.84.123.456"          # IP público da EC2-1 (ServeRest)
$EC2_2_PUBLIC_IP = "52.91.234.567"         # IP público da EC2-2 (Robot Framework)
$RDP_PASSWORD = "SuaSenhaSegura123!"        # Senha do Administrator (gerada pelo AWS)
$AWS_REGION = "us-east-1"                   # Região AWS utilizada
$SECURITY_GROUP_ID = "sg-0123456789abcdef0" # ID do Security Group

# CONFIGURAÇÕES DE REDE
$SERVEREST_PORT = "3000"                    # Porta onde ServeRest roda
$RDP_PORT = "3389"                         # Porta RDP (Remote Desktop)

# DIRETÓRIOS DE INSTALAÇÃO
$SERVEREST_INSTALL_PATH = "C:\ServeRest"
$ROBOT_INSTALL_PATH = "C:\RobotTests"

# URLS DE ACESSO
$SERVEREST_BASE_URL = "http://${EC2_1_PUBLIC_IP}:${SERVEREST_PORT}"
$RDP_EC2_1 = "${EC2_1_PUBLIC_IP}:${RDP_PORT}"
$RDP_EC2_2 = "${EC2_2_PUBLIC_IP}:${RDP_PORT}"

# COMANDOS DE CONEXÃO RDP (exemplos)
# mstsc /v:$RDP_EC2_1  # Conectar EC2-1
# mstsc /v:$RDP_EC2_2  # Conectar EC2-2

# =============================================================================
# CHECKLIST DE CONFIGURAÇÃO WINDOWS
# =============================================================================

## ✅ PRÉ-REQUISITOS
# [ ] Conta AWS ativa
# [ ] 2 instâncias EC2 criadas (t3.medium para Windows)
# [ ] Sistema: Microsoft Windows Server 2022 Base
# [ ] Security Group configurado (portas 3389, 3000, 80)
# [ ] Senhas do Administrator obtidas no AWS Console
# [ ] IPs públicos anotados

## ✅ EC2-1 (SERVEREST WINDOWS)
# [ ] Conectar via RDP (mstsc /v:IP-EC2-1)
# [ ] Abrir PowerShell como Administrator
# [ ] Executar script setup-ec2-serverest-windows.ps1
# [ ] Verificar serviço: Get-Service ServeRest
# [ ] Testar: Invoke-RestMethod -Uri "http://localhost:3000/usuarios" -Method GET
# [ ] Configurar Windows Firewall (porta 3000)
# [ ] Verificar IP público: Invoke-RestMethod -Uri "http://checkip.amazonaws.com/"

## ✅ EC2-2 (ROBOT FRAMEWORK WINDOWS)
# [ ] Conectar via RDP (mstsc /v:IP-EC2-2)
# [ ] Abrir PowerShell como Administrator
# [ ] Executar script setup-ec2-robot-windows.ps1 (informar IP da EC2-1)
# [ ] Testar conectividade: .\quick-test.ps1
# [ ] Executar testes: .\run-tests.ps1
# [ ] Verificar resultados: Get-ChildItem "C:\RobotTests\Results\"

## ✅ VALIDAÇÃO FINAL WINDOWS
# [ ] ServeRest acessível externamente: Test-NetConnection -ComputerName IP-EC2-1 -Port 3000
# [ ] Serviço Windows ServeRest rodando: Get-Service ServeRest
# [ ] Testes Robot Framework passando 100%
# [ ] Scripts PowerShell executando sem erros
# [ ] RDP funcionando nas duas instâncias

# =============================================================================
# COMANDOS ÚTEIS WINDOWS
# =============================================================================

# Verificar status geral das instâncias (AWS CLI)
function Check-EC2Status {
    aws ec2 describe-instances --instance-ids i-1234567890abcdef0 i-0987654321fedcba0 --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table
}

# Verificar Security Group
function Check-SecurityGroup {
    aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID --query 'SecurityGroups[*].IpPermissions[*].[IpProtocol,FromPort,ToPort,IpRanges[*].CidrIp]' --output table
}

# Testar conectividade de rede
function Test-ServerestConnectivity {
    param($IP = $EC2_1_PUBLIC_IP)
    Test-NetConnection -ComputerName $IP -Port $SERVEREST_PORT -InformationLevel Detailed
}

# Verificar custos (requer AWS CLI configurado)
function Get-MonthlyCosts {
    $startDate = (Get-Date).AddDays(-30).ToString("yyyy-MM-dd")
    $endDate = (Get-Date).ToString("yyyy-MM-dd")
    aws ce get-cost-and-usage --time-period Start=$startDate,End=$endDate --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE
}

# =============================================================================
# TROUBLESHOOTING COMUM WINDOWS
# =============================================================================

## Connection Refused (Porta 3000):
function Fix-ServerestConnection {
    Write-Host "🔧 Verificando conectividade ServeRest..." -ForegroundColor Cyan
    
    # 1. Verificar se ServeRest está rodando
    Write-Host "1. Status do serviço:" -ForegroundColor Yellow
    Get-Service ServeRest -ErrorAction SilentlyContinue
    
    # 2. Verificar Windows Firewall
    Write-Host "2. Regra do firewall:" -ForegroundColor Yellow
    Get-NetFirewallRule -DisplayName "ServeRest" -ErrorAction SilentlyContinue
    
    # 3. Verificar processo Node.js
    Write-Host "3. Processos Node.js:" -ForegroundColor Yellow
    Get-Process | Where-Object {$_.ProcessName -like "*node*"}
    
    # 4. Testar localmente
    Write-Host "4. Teste local:" -ForegroundColor Yellow
    try {
        Invoke-RestMethod -Uri "http://localhost:3000/usuarios" -Method GET -TimeoutSec 5
        Write-Host "✅ ServeRest respondendo localmente" -ForegroundColor Green
    } catch {
        Write-Host "❌ ServeRest não responde localmente" -ForegroundColor Red
    }
}

## Testes falhando:
function Fix-RobotTests {
    Write-Host "🔧 Verificando configuração Robot Framework..." -ForegroundColor Cyan
    
    # 1. Verificar configuração
    Write-Host "1. Configuração atual:" -ForegroundColor Yellow
    if (Test-Path "C:\RobotTests\robot-config.ps1") {
        Get-Content "C:\RobotTests\robot-config.ps1"
    }
    
    # 2. Testar conectividade
    Write-Host "2. Teste de conectividade:" -ForegroundColor Yellow
    Test-NetConnection -ComputerName $EC2_1_PUBLIC_IP -Port 3000
    
    # 3. Verificar instalação Robot Framework
    Write-Host "3. Versão Robot Framework:" -ForegroundColor Yellow
    robot --version
    
    # 4. Verificar Python
    Write-Host "4. Versão Python:" -ForegroundColor Yellow
    python --version
}

## RDP Connection Issues:
function Fix-RDPConnection {
    param($IP)
    
    Write-Host "🔧 Verificando conexão RDP para $IP..." -ForegroundColor Cyan
    
    # 1. Verificar se instância está rodando
    Write-Host "1. Verificar se instância está rodando no AWS Console" -ForegroundColor Yellow
    
    # 2. Testar conectividade RDP
    Write-Host "2. Testando porta RDP:" -ForegroundColor Yellow
    Test-NetConnection -ComputerName $IP -Port 3389
    
    # 3. Verificar Security Group
    Write-Host "3. Verificar Security Group (porta 3389 deve estar liberada)" -ForegroundColor Yellow
    
    # 4. Comando para conectar
    Write-Host "4. Comando para conectar:" -ForegroundColor Yellow
    Write-Host "   mstsc /v:$IP" -ForegroundColor Cyan
}

## Execution Policy Error:
function Fix-ExecutionPolicy {
    Write-Host "🔧 Configurando Execution Policy..." -ForegroundColor Cyan
    
    # Configurar para usuário atual
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    
    # Configurar para processo atual
    Set-ExecutionPolicy Bypass -Scope Process -Force
    
    Write-Host "✅ Execution Policy configurada!" -ForegroundColor Green
    Get-ExecutionPolicy -List
}

# =============================================================================
# OTIMIZAÇÃO DE CUSTOS WINDOWS
# =============================================================================

# Parar instâncias quando não usar (executar do seu PC com AWS CLI)
function Stop-TestInstances {
    Write-Host "⏸️ Parando instâncias de teste..." -ForegroundColor Yellow
    aws ec2 stop-instances --instance-ids i-1234567890abcdef0 i-0987654321fedcba0
    Write-Host "✅ Comando executado. Aguarde alguns minutos." -ForegroundColor Green
}

# Iniciar quando precisar
function Start-TestInstances {
    Write-Host "▶️ Iniciando instâncias de teste..." -ForegroundColor Yellow
    aws ec2 start-instances --instance-ids i-1234567890abcdef0 i-0987654321fedcba0
    Write-Host "✅ Comando executado. Aguarde alguns minutos para RDP ficar disponível." -ForegroundColor Green
}

# Programar desligamento automático (executar dentro da EC2)
function Set-AutoShutdown {
    param($Hour = 22) # Desligar às 22h por padrão
    
    Write-Host "⏰ Programando desligamento automático às ${Hour}h..." -ForegroundColor Yellow
    
    $action = New-ScheduledTaskAction -Execute "shutdown" -Argument "/s /f /t 0"
    $trigger = New-ScheduledTaskTrigger -Daily -At "${Hour}:00"
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
    
    Register-ScheduledTask -TaskName "AutoShutdown" -Action $action -Trigger $trigger -Principal $principal -Force
    
    Write-Host "✅ Desligamento automático configurado para ${Hour}h todos os dias!" -ForegroundColor Green
}

# Verificar custos estimados
function Get-EstimatedCosts {
    Write-Host "💰 Custos estimados Windows vs Linux:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Windows Server (t3.medium):" -ForegroundColor Yellow
    Write-Host "   💻 2 instâncias × ~$0.05/hora = ~$0.10/hora" -ForegroundColor Gray
    Write-Host "   📅 24h/dia = ~$2.40/dia" -ForegroundColor Gray
    Write-Host "   📅 30 dias = ~$72/mês" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Linux (t2.micro - Free Tier):" -ForegroundColor Yellow
    Write-Host "   💻 2 instâncias × ~$0.01/hora = ~$0.02/hora" -ForegroundColor Gray
    Write-Host "   📅 24h/dia = ~$0.48/dia" -ForegroundColor Gray
    Write-Host "   📅 30 dias = ~$14.40/mês" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔍 Dica: Use Linux para economizar ~80% nos custos!" -ForegroundColor Green
}

# =============================================================================
# EXEMPLOS DE USO
# =============================================================================

<# 
Exemplo de execução completa:

1. Configurar variáveis:
   $EC2_1_PUBLIC_IP = "3.84.123.456"
   $EC2_2_PUBLIC_IP = "52.91.234.567"

2. Verificar conectividade:
   Test-ServerestConnectivity

3. Resolver problemas se houver:
   Fix-ServerestConnection
   Fix-RobotTests

4. Parar instâncias ao final:
   Stop-TestInstances
#>

Write-Host "📋 Template de configuração AWS EC2 Windows carregado!" -ForegroundColor Green
Write-Host "✏️ Edite as variáveis no início do arquivo com suas informações" -ForegroundColor Yellow
Write-Host "🔧 Use as funções definidas para troubleshooting e manutenção" -ForegroundColor Cyan