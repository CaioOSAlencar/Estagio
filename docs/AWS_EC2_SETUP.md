# 🚀 AWS EC2 Setup - ServeRest + Robot Framework

**Objetivo**: Configurar duas instâncias EC2 separadas:
- **EC2-1**: Executar a aplicação ServeRest 
- **EC2-2**: Executar os testes Robot Framework

## 📋 Arquitetura da Solução

```
┌─────────────────┐    HTTP/API    ┌─────────────────┐
│   EC2-1         │◄──────────────►│   EC2-2         │
│   ServeRest     │                │   Robot Tests   │
│   Port: 3000    │                │   Python + RF   │
└─────────────────┘                └─────────────────┘
```

---

## 🏗️ PARTE 1: Criação das Instâncias EC2

### 1.1 Pré-requisitos
- ✅ Conta AWS ativa
- ✅ AWS CLI configurado (opcional)
- ✅ Conhecimento básico de terminal Linux

### 1.2 Criar Instâncias
```bash
# Via AWS Console ou CLI
# Configuração recomendada:
- Instance Type: t2.micro (Free Tier)
- OS: Ubuntu Server 22.04 LTS
- Security Group: Portas 22 (SSH), 3000 (ServeRest), 80 (HTTP)
- Key Pair: Criar/usar existente para SSH
```

---

## 🖥️ PARTE 2: EC2-1 - Setup ServeRest

### 2.1 Conectar à Instância
```bash
# Substitua pelos seus valores
ssh -i "sua-chave.pem" ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
```

### 2.2 Instalar Dependências
```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Node.js e npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar instalação
node --version
npm --version
```

### 2.3 Instalar e Configurar ServeRest
```bash
# Instalar ServeRest globalmente
sudo npm install -g serverest

# Criar diretório de trabalho
mkdir ~/serverest-app
cd ~/serverest-app

# Verificar se funciona localmente
npx serverest --version
```

### 2.4 Configurar Serviço SystemD
```bash
# Criar arquivo de serviço
sudo nano /etc/systemd/system/serverest.service
```

**Conteúdo do arquivo:**
```ini
[Unit]
Description=ServeRest API Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/serverest-app
ExecStart=/usr/bin/npx serverest --porta 3000
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

### 2.5 Iniciar Serviço
```bash
# Recarregar systemd e iniciar serviço
sudo systemctl daemon-reload
sudo systemctl enable serverest
sudo systemctl start serverest

# Verificar status
sudo systemctl status serverest

# Testar se está funcionando
curl http://localhost:3000/usuarios
```

### 2.6 Configurar Security Group
```bash
# No AWS Console, adicionar regra:
# Type: Custom TCP
# Port: 3000
# Source: 0.0.0.0/0 (ou IP específico da EC2-2)
```

---

## 🤖 PARTE 3: EC2-2 - Setup Robot Framework

### 3.1 Conectar à Segunda Instância
```bash
ssh -i "sua-chave.pem" ubuntu@ec2-yy-yy-yy-yy.compute-1.amazonaws.com
```

### 3.2 Instalar Python e Dependências
```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Python e pip
sudo apt install -y python3 python3-pip git

# Verificar instalação
python3 --version
pip3 --version
```

### 3.3 Clonar e Configurar Projeto
```bash
# Clonar seu repositório
git clone https://github.com/CaioOSAlencar/Estagio.git
cd Estagio/automation/robot-framework

# Instalar dependências Robot Framework
pip3 install robotframework robotframework-requests robotframework-jsonlibrary

# Verificar instalação
robot --version
```

### 3.4 Configurar Variáveis de Ambiente
```bash
# Criar arquivo de configuração
nano ~/robot-config.sh
```

**Conteúdo:**
```bash
#!/bin/bash
export SERVEREST_BASE_URL="http://EC2-1-PUBLIC-IP:3000"
export ROBOT_OUTPUT_DIR="/home/ubuntu/test-results"
mkdir -p $ROBOT_OUTPUT_DIR
```

```bash
# Tornar executável e carregar
chmod +x ~/robot-config.sh
source ~/robot-config.sh
```

### 3.5 Atualizar Testes para Usar IP da EC2-1
```bash
# Editar arquivo de configuração dos testes
nano resources/keywords/common_keywords.robot
```

**Modificar a URL base:**
```robotframework
*** Variables ***
# Usar IP público da EC2-1
${BASE_URL}    http://SEU-IP-EC2-1:3000
```

---

## 🧪 PARTE 4: Execução dos Testes

### 4.1 Script de Execução Automática
```bash
# Na EC2-2, criar script de execução
nano ~/run-tests.sh
```

**Conteúdo:**
```bash
#!/bin/bash
# Script para executar testes Robot Framework

echo "🚀 Iniciando execução dos testes..."
echo "🎯 Target: $SERVEREST_BASE_URL"

cd /home/ubuntu/Estagio/automation/robot-framework

# Verificar conectividade com ServeRest
echo "📡 Testando conectividade..."
curl -f $SERVEREST_BASE_URL/usuarios || {
    echo "❌ Erro: ServeRest não está acessível!"
    exit 1
}

echo "✅ ServeRest acessível!"

# Executar testes básicos
echo "🧪 Executando testes básicos..."
robot --outputdir $ROBOT_OUTPUT_DIR \
      --variable BASE_URL:$SERVEREST_BASE_URL \
      tests/auth/test_basic_working.robot

# Executar testes completos
echo "🧪 Executando testes completos..."
robot --outputdir $ROBOT_OUTPUT_DIR \
      --variable BASE_URL:$SERVEREST_BASE_URL \
      tests/complete/test_serverest_complete.robot

echo "✅ Testes concluídos! Resultados em: $ROBOT_OUTPUT_DIR"
```

### 4.2 Tornar Executável e Testar
```bash
chmod +x ~/run-tests.sh
source ~/robot-config.sh
~/run-tests.sh
```

---

## 📊 PARTE 5: Monitoramento e Logs

### 5.1 Logs do ServeRest (EC2-1)
```bash
# Ver logs em tempo real
sudo journalctl -u serverest -f

# Ver logs das últimas 100 linhas
sudo journalctl -u serverest --lines=100
```

### 5.2 Resultados dos Testes (EC2-2)
```bash
# Ver resultados
ls -la ~/test-results/

# Copiar resultados para local (do seu PC)
scp -i "sua-chave.pem" ubuntu@ec2-yy-yy-yy-yy.compute-1.amazonaws.com:~/test-results/* ./
```

---

## 🔧 PARTE 6: Automatização e CI/CD

### 6.1 Cron Job para Execução Periódica
```bash
# Na EC2-2, agendar execução automática
crontab -e

# Adicionar linha (executar a cada 30 minutos):
*/30 * * * * /home/ubuntu/robot-config.sh && /home/ubuntu/run-tests.sh >> /home/ubuntu/cron-tests.log 2>&1
```

### 6.2 Script de Health Check
```bash
nano ~/health-check.sh
```

**Conteúdo:**
```bash
#!/bin/bash
# Health check das instâncias

echo "🏥 Health Check - $(date)"

# Verificar ServeRest
if curl -f http://SEU-IP-EC2-1:3000/usuarios > /dev/null 2>&1; then
    echo "✅ ServeRest: OK"
else
    echo "❌ ServeRest: FALHA"
    # Aqui você pode adicionar notificações (email, Slack, etc.)
fi

# Verificar espaço em disco
df -h | grep -E "/$|/home"

echo "------------------------"
```

---

## 💰 PARTE 7: Otimização de Custos

### 7.1 Auto-Shutdown
```bash
# Desligar instâncias automaticamente (opcional)
# Adicionar ao crontab para desligar à noite:
0 22 * * * sudo shutdown -h now
```

### 7.2 Instance Scheduling
- Use **AWS Instance Scheduler** para ligar/desligar automaticamente
- Configure horários de trabalho (ex: 8h-18h)

---

## 🎯 PARTE 8: Validação da Implementação

### Checklist Final:
- [ ] EC2-1 rodando ServeRest na porta 3000
- [ ] EC2-2 executando testes Robot Framework
- [ ] Comunicação entre as instâncias funcionando
- [ ] Testes passando com 100% de sucesso
- [ ] Logs sendo gerados corretamente
- [ ] Scripts de automação funcionando

---

## 🚨 Troubleshooting

### Problemas Comuns:

1. **Connection Refused**
   ```bash
   # Verificar se ServeRest está rodando
   sudo systemctl status serverest
   sudo netstat -tlnp | grep 3000
   ```

2. **Security Group**
   ```bash
   # Verificar regras no AWS Console
   # Garantir que porta 3000 está liberada
   ```

3. **DNS Resolution**
   ```bash
   # Usar IP público em vez de DNS se houver problemas
   nslookup ec2-xx-xx-xx-xx.compute-1.amazonaws.com
   ```

---

## 📈 Próximos Passos (Opcional)

1. **Load Balancer**: Adicionar ALB para alta disponibilidade
2. **Docker**: Containerizar ServeRest e testes
3. **CI/CD Pipeline**: Integrar com GitHub Actions
4. **Monitoring**: Adicionar CloudWatch metrics
5. **Backup**: Configurar snapshots automáticos

---

**🏆 Resultado Final**: Arquitetura distribuída profissional rodando na AWS! 🎉