# 🚀 Guia Rápido - AWS EC2 Setup (Windows)

## ⚡ Execução em 5 Passos (Windows Server)

### 1️⃣ Criar Instâncias EC2 Windows
```powershell
# No AWS Console:
- Criar 2 instâncias t3.medium (Windows Server 2022 Base)
- Security Group: Portas 3389 (RDP), 3000 (ServeRest), 80 (HTTP)
- Mesmo Key Pair para ambas
- Anotar IPs públicos e senhas do Administrator
```

### 2️⃣ Setup EC2-1 (ServeRest Windows)
```powershell
# Conectar via RDP
# Endereço: IP-PUBLICO-EC2-1
# Usuário: Administrator

# Abrir PowerShell como Administrador e executar:
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# IMPORTANTE: Fechar e reabrir PowerShell como Administrator, depois:
# Atualizar PATH manualmente (refreshenv só funciona após Chocolatey instalado)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verificar se Node.js já está instalado, senão instalar via Chocolatey
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    choco install nodejs -y
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "✅ Node.js já está instalado: $(node --version)"
}

# Instalar NSSM se precisar (para criar serviços Windows)
if (!(Get-Command nssm -ErrorAction SilentlyContinue)) {
    choco install nssm -y
}

npm install -g serverest

# Configurar serviço
New-Item -ItemType Directory -Path "C:\ServeRest" -Force
Set-Location "C:\ServeRest"

$psScript = @"
Set-Location "C:\ServeRest"
Write-Host "Iniciando ServeRest na porta 3000..."
npx serverest --porta 3000
"@
$psScript | Out-File -FilePath "C:\ServeRest\start-serverest.ps1" -Encoding UTF8

nssm install ServeRest "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
nssm set ServeRest Arguments "-ExecutionPolicy Bypass -File C:\ServeRest\start-serverest.ps1"
nssm set ServeRest AppDirectory "C:\ServeRest"
nssm start ServeRest

# Configurar firewall
New-NetFirewallRule -DisplayName "ServeRest" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow

# Testar
Start-Sleep -Seconds 15
Invoke-RestMethod -Uri "http://localhost:3000/usuarios" -Method GET
```

### 3️⃣ Setup EC2-2 (Robot Framework Windows)
```powershell
# Conectar via RDP na segunda instância
# Endereço: IP-PUBLICO-EC2-2  
# Usuário: Administrator

# Instalar dependências
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Atualizar PATH manualmente
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verificar se Python já está instalado, senão instalar
if (!(Get-Command py -ErrorAction SilentlyContinue) -and !(Get-Command python -ErrorAction SilentlyContinue)) {
    choco install python -y
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
} else {
    Write-Host "✅ Python já está instalado: $(py --version 2>$null || python --version)"
}

# Verificar se Git já está instalado, senão instalar
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    choco install git -y
}

# Configurar projeto
New-Item -ItemType Directory -Path "C:\RobotTests" -Force
Set-Location "C:\RobotTests"
git clone https://github.com/CaioOSAlencar/Estagio.git
Set-Location "C:\RobotTests\Estagio\automation\robot-framework"

# Instalar Robot Framework (usar py em vez de pip)
py -m pip install robotframework robotframework-requests robotframework-jsonlibrary

# Configurar IP do ServeRest (substituir pelo IP real da EC2-1)
$serverestIP = "IP-PUBLICO-EC2-1"  # <- ALTERE AQUI
$configContent = @"
`$env:SERVEREST_BASE_URL = "http://$serverestIP:3000"
`$env:ROBOT_OUTPUT_DIR = "C:\RobotTests\Results"
if (!(Test-Path `$env:ROBOT_OUTPUT_DIR)) {
    New-Item -ItemType Directory -Path `$env:ROBOT_OUTPUT_DIR -Force
}
"@
$configContent | Out-File -FilePath "C:\RobotTests\robot-config.ps1" -Encoding UTF8
```

### 4️⃣ Configurar Security Group
```powershell
# No AWS Console:
EC2 → Security Groups → Seu-Security-Group
Inbound Rules → Add Rule:
- Type: Custom TCP
- Port: 3000  
- Source: 0.0.0.0/0
```

### 5️⃣ Executar Testes
```powershell
# Na EC2-2, criar e executar script de testes:
$runScript = @"
. "C:\RobotTests\robot-config.ps1"
Set-Location "C:\RobotTests\Estagio\automation\robot-framework"

Write-Host "🧪 Executando testes básicos..." -ForegroundColor Cyan
py -m robot --outputdir "`$env:ROBOT_OUTPUT_DIR" --variable BASE_URL:`$env:SERVEREST_BASE_URL tests\auth\test_basic_working.robot

Write-Host "🧪 Executando testes completos..." -ForegroundColor Cyan  
py -m robot --outputdir "`$env:ROBOT_OUTPUT_DIR" --variable BASE_URL:`$env:SERVEREST_BASE_URL tests\complete\test_serverest_complete.robot

Write-Host "✅ Testes concluídos! Resultados em: `$env:ROBOT_OUTPUT_DIR" -ForegroundColor Green
"@
$runScript | Out-File -FilePath "C:\RobotTests\run-tests.ps1" -Encoding UTF8

# Executar
. "C:\RobotTests\run-tests.ps1"
```

---

## 🔧 Comandos Úteis Windows

### EC2-1 (ServeRest):
```powershell
# Ver status do serviço
Get-Service ServeRest

# Reiniciar serviço
Restart-Service ServeRest

# Testar localmente
Invoke-RestMethod -Uri "http://localhost:3000/usuarios" -Method GET

# Ver IP público
Invoke-RestMethod -Uri "http://checkip.amazonaws.com/"

# Monitorar logs do serviço
Get-EventLog -LogName System -Source "Service Control Manager" | Where-Object {$_.Message -like "*ServeRest*"} | Select-Object -First 10
```

### EC2-2 (Robot Framework):
```powershell
# Testar conectividade
. "C:\RobotTests\robot-config.ps1"
Invoke-RestMethod -Uri "$env:SERVEREST_BASE_URL/usuarios" -Method GET

# Executar testes
. "C:\RobotTests\run-tests.ps1"

# Ver resultados
Get-ChildItem "C:\RobotTests\Results\"

# Verificar instalação Robot Framework
py -m robot --version
py --version
```

---

## 🎯 URLs de Teste

- **ServeRest**: `http://IP-EC2-1:3000`
- **Endpoint usuarios**: `http://IP-EC2-1:3000/usuarios`
- **Endpoint produtos**: `http://IP-EC2-1:3000/produtos`
- **RDP EC2-1**: `IP-EC2-1:3389`
- **RDP EC2-2**: `IP-EC2-2:3389`

---

## 🚨 Troubleshooting Windows

### ServeRest não responde:
```powershell
# Verificar serviço
Get-Service ServeRest
Restart-Service ServeRest -Force

# Verificar firewall
Get-NetFirewallRule -DisplayName "ServeRest"

# Verificar processo Node.js
Get-Process | Where-Object {$_.ProcessName -like "*node*"}
```

### Testes falhando:
```powershell
# Verificar conectividade
Test-NetConnection -ComputerName IP-EC2-1 -Port 3000

# Verificar configuração
Get-Content "C:\RobotTests\robot-config.ps1"

# Recriar configuração se necessário
$serverestIP = "NOVO-IP-EC2-1"
# ... repetir configuração
```

### Execution Policy Error:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# ou
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### RDP Connection Issues:
- Verificar se instância está rodando no AWS Console
- Verificar Security Group (porta 3389)
- Usar IP público correto
- Aguardar alguns minutos após iniciar instância

---

## 💡 Dicas Importantes Windows

1. **Windows Server precisa mais recursos** - usar t3.medium em vez de t2.micro
2. **RDP pode demorar** alguns minutos para ficar disponível após boot
3. **Executar PowerShell como Administrator** sempre
4. **IPs Públicos mudam** quando reinicia EC2 - atualizar configurações
5. **Windows Firewall** precisa ser configurado além do Security Group
6. **NSSM** facilita criar serviços Windows para Node.js
7. **Chocolatey** é o gerenciador de pacotes mais prático para Windows
8. **⚠️ refreshenv** só funciona APÓS instalar Chocolatey - use atualização manual do PATH
9. **⚠️ python vs py** - Windows moderno usa `py` command, não `python`
10. **⚠️ Verificar instalações** - Node.js e Python podem já estar instalados

---

## 📊 Resultados Esperados

- ✅ **Serviço ServeRest rodando** como Windows Service
- ✅ **11 testes passando** no Robot Framework  
- ✅ **RDP funcionando** nas duas instâncias
- ✅ **Comunicação entre EC2s** através da porta 3000
- ✅ **Scripts PowerShell** executando sem erros

---

## 💰 Custos Windows vs Linux

| Aspecto | Windows | Linux |
|---------|---------|-------|
| Instance Type | t3.medium (mais caro) | t2.micro (Free Tier) |
| Licença OS | Inclusa no custo EC2 | Gratuita |
| Recursos RAM | 4GB (necessário) | 1GB (suficiente) |
| Custo/hora | ~$0.05 | ~$0.01 (Free Tier) |
| **Recomendação** | Apenas se Windows for obrigatório | Preferir Linux para economizar |

**🏆 Sucesso**: Arquitetura distribuída Windows rodando na AWS! 🎉