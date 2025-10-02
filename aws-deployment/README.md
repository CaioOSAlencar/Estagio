# Tarefa Extra: Deploy ServeRest em AWS EC2

## 📋 Visão Geral

Esta é a tarefa **extra** do challenge: configurar o ServeRest em uma instância EC2 da AWS e executar os testes automatizados de outra instância EC2.

### Arquitetura Proposta
```
┌─────────────────┐    ┌─────────────────┐
│   EC2 Instance  │    │   EC2 Instance  │
│   "ServeRest"   │◄───┤   "Test Runner" │
│                 │    │                 │  
│ - Node.js       │    │ - Python        │
│ - ServeRest API │    │ - Robot Framework│
│ - Port 3000     │    │ - Newman        │
│ - Public IP     │    │ - Git           │
└─────────────────┘    └─────────────────┘
```

---

## 🚀 Parte 1: Configuração da EC2 do ServeRest

### 1.1 Criação da Instância
```bash
# Configurações recomendadas:
Instance Type: t2.micro (Free Tier)
AMI: Amazon Linux 2023  
Security Group: Allow HTTP (80), HTTPS (443), SSH (22), Custom (3000)
Storage: 8GB GP3 (Free Tier)
Key Pair: Criar novo ou usar existente
```

### 1.2 Configuração do Security Group
```bash
# Regras de entrada necessárias:
Type: SSH, Protocol: TCP, Port: 22, Source: Your IP
Type: HTTP, Protocol: TCP, Port: 80, Source: Anywhere (0.0.0.0/0)  
Type: Custom TCP, Protocol: TCP, Port: 3000, Source: Anywhere (0.0.0.0/0)
Type: Custom TCP, Protocol: TCP, Port: 3000, Source: Test Runner SG
```

### 1.3 Script de Configuração da EC2 ServeRest
```bash
#!/bin/bash
# user-data-serverest.sh

# Atualizar sistema
sudo yum update -y

# Instalar Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verificar instalação
node --version
npm --version

# Instalar ServeRest globalmente
sudo npm install -g serverest

# Criar diretório para logs
sudo mkdir -p /var/log/serverest
sudo chmod 755 /var/log/serverest

# Criar arquivo de configuração systemd
sudo tee /etc/systemd/system/serverest.service > /dev/null <<EOF
[Unit]
Description=ServeRest API Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/npx serverest
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3000
StandardOutput=append:/var/log/serverest/output.log
StandardError=append:/var/log/serverest/error.log

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar serviço
sudo systemctl daemon-reload
sudo systemctl enable serverest
sudo systemctl start serverest

# Verificar status
sudo systemctl status serverest

# Criar script de monitoramento
sudo tee /home/ec2-user/check-serverest.sh > /dev/null <<'EOF'
#!/bin/bash
# Script de verificação de saúde do ServeRest

HEALTH_CHECK_URL="http://localhost:3000/usuarios"
LOG_FILE="/var/log/serverest/health-check.log"

echo "$(date): Checking ServeRest health..." >> $LOG_FILE

if curl -f -s $HEALTH_CHECK_URL > /dev/null; then
    echo "$(date): ServeRest is healthy" >> $LOG_FILE
    exit 0
else
    echo "$(date): ServeRest is down, restarting..." >> $LOG_FILE
    sudo systemctl restart serverest
    sleep 10
    
    if curl -f -s $HEALTH_CHECK_URL > /dev/null; then
        echo "$(date): ServeRest restarted successfully" >> $LOG_FILE
    else
        echo "$(date): Failed to restart ServeRest" >> $LOG_FILE
        exit 1
    fi
fi
EOF

sudo chmod +x /home/ec2-user/check-serverest.sh

# Adicionar ao crontab para verificação a cada 5 minutos
echo "*/5 * * * * /home/ec2-user/check-serverest.sh" | sudo crontab -

echo "ServeRest installation and configuration completed!"
echo "API should be available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
```

---

## 🧪 Parte 2: Configuração da EC2 Test Runner

### 2.1 Criação da Segunda Instância
```bash
# Configurações:
Instance Type: t2.small (mais RAM para executar testes)
AMI: Amazon Linux 2023
Security Group: Allow SSH (22), Outbound All
Storage: 10GB GP3
Key Pair: Mesmo da primeira instância
```

### 2.2 Script de Configuração da EC2 Test Runner  
```bash
#!/bin/bash
# user-data-testrunner.sh

# Atualizar sistema
sudo yum update -y

# Instalar Python e pip
sudo yum install -y python3 python3-pip git

# Instalar Node.js para Newman
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Instalar ferramentas de teste
sudo pip3 install robotframework
sudo pip3 install robotframework-requests
sudo pip3 install robotframework-jsonlibrary
sudo npm install -g newman

# Verificar instalações
echo "Python version: $(python3 --version)"
echo "Robot Framework version: $(robot --version)"
echo "Newman version: $(newman --version)"

# Criar estrutura de diretórios
sudo mkdir -p /opt/tests
sudo chown ec2-user:ec2-user /opt/tests
cd /opt/tests

# Criar script de clone do repositório
tee /home/ec2-user/setup-tests.sh > /dev/null <<'EOF'
#!/bin/bash
# Script para configurar ambiente de testes

cd /opt/tests

# Clonar repositório de testes (substitua pela sua URL)
if [ ! -d "Estagio" ]; then
    echo "Cloning test repository..."
    git clone https://github.com/seu-usuario/Estagio.git
else
    echo "Repository exists, pulling latest changes..."
    cd Estagio
    git pull origin main
    cd ..
fi

echo "Test environment setup completed!"
EOF

chmod +x /home/ec2-user/setup-tests.sh

# Criar script de execução de testes
tee /home/ec2-user/run-tests.sh > /dev/null <<'EOF'
#!/bin/bash
# Script para executar testes contra ServeRest na outra EC2

# Configurações
SERVEREST_IP="$1"  # IP da EC2 do ServeRest será passado como parâmetro
SERVEREST_URL="http://${SERVEREST_IP}:3000"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_DIR="/opt/tests/results/${TIMESTAMP}"

# Validar parâmetros
if [ -z "$SERVEREST_IP" ]; then
    echo "Usage: $0 <SERVEREST_EC2_IP>"
    echo "Example: $0 3.85.123.45"
    exit 1
fi

echo "🚀 Starting test execution against ServeRest at: $SERVEREST_URL"

# Criar diretório de resultados
mkdir -p "$RESULTS_DIR"
cd /opt/tests/Estagio

# Verificar se ServeRest está disponível
echo "🔍 Checking ServeRest availability..."
if ! curl -f -s "${SERVEREST_URL}/usuarios" > /dev/null; then
    echo "❌ ServeRest not available at $SERVEREST_URL"
    exit 1
fi
echo "✅ ServeRest is available!"

# Executar testes Postman com Newman
echo "🧪 Running Postman tests with Newman..."
newman run postman/ServeRest.postman_collection.json \
    --environment <(echo '{"values":[{"key":"baseUrl","value":"'$SERVEREST_URL'"}]}') \
    --reporters cli,junit,htmlextra \
    --reporter-junit-export "$RESULTS_DIR/newman-results.xml" \
    --reporter-htmlextra-export "$RESULTS_DIR/newman-report.html" \
    --timeout-request 10000

# Executar testes Robot Framework  
echo "🤖 Running Robot Framework tests..."
cd automation/robot-framework

robot --variable BASE_URL:$SERVEREST_URL \
      --outputdir "$RESULTS_DIR/robot" \
      --log robot-log.html \
      --report robot-report.html \
      --output robot-output.xml \
      --loglevel INFO \
      tests/

# Gerar relatório consolidado
echo "📊 Generating consolidated report..."
cd "$RESULTS_DIR"

cat > execution-summary.md <<EOL
# Test Execution Summary

**Date:** $(date)
**ServeRest URL:** $SERVEREST_URL  
**Test Runner:** $(hostname)
**Results Directory:** $RESULTS_DIR

## Newman Results
- Report: [newman-report.html](newman-report.html)
- XML: newman-results.xml

## Robot Framework Results  
- Report: [robot/robot-report.html](robot/robot-report.html)
- Log: [robot/robot-log.html](robot/robot-log.html)
- XML: robot/robot-output.xml

## Test Status
$(if [ -f "newman-results.xml" ]; then echo "✅ Newman tests completed"; else echo "❌ Newman tests failed"; fi)
$(if [ -f "robot/robot-output.xml" ]; then echo "✅ Robot Framework tests completed"; else echo "❌ Robot Framework tests failed"; fi)

Generated at: $(date)
EOL

echo "✅ Test execution completed!"
echo "📁 Results saved to: $RESULTS_DIR"
echo "📊 Summary: $RESULTS_DIR/execution-summary.md"
EOF

chmod +x /home/ec2-user/run-tests.sh

# Criar script de execução agendada
tee /home/ec2-user/schedule-tests.sh > /dev/null <<'EOF'
#!/bin/bash
# Script para execução agendada dos testes

# Configurar para executar testes diariamente às 02:00
SERVEREST_IP="$1"

if [ -z "$SERVEREST_IP" ]; then
    echo "Usage: $0 <SERVEREST_EC2_IP>"
    exit 1
fi

# Adicionar ao crontab
echo "0 2 * * * /home/ec2-user/run-tests.sh $SERVEREST_IP >> /var/log/scheduled-tests.log 2>&1" | crontab -

echo "✅ Tests scheduled to run daily at 02:00 UTC"
echo "📝 Logs will be saved to: /var/log/scheduled-tests.log"
EOF

chmod +x /home/ec2-user/schedule-tests.sh

echo "Test Runner setup completed!"
echo "Next steps:"
echo "1. Run: /home/ec2-user/setup-tests.sh"
echo "2. Run: /home/ec2-user/run-tests.sh <SERVEREST_IP>"
```

---

## 🔧 Parte 3: Configuração de Rede e Segurança

### 3.1 Configuração de Security Groups
```bash
# Security Group para ServeRest EC2
aws ec2 create-security-group \
    --group-name serverest-sg \
    --description "Security group for ServeRest API server"

# Adicionar regras
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxxx \
    --protocol tcp \
    --port 22 \
    --source-group sg-yyyyyyyyy  # Test Runner SG

aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxxx \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0

# Security Group para Test Runner EC2  
aws ec2 create-security-group \
    --group-name test-runner-sg \
    --description "Security group for test execution instance"
```

### 3.2 Elastic IPs (Recomendado)
```bash
# Alocar IP elástico para ServeRest (para IP fixo)
aws ec2 allocate-address --domain vpc

# Associar à instância ServeRest
aws ec2 associate-address \
    --instance-id i-xxxxxxxxx \
    --allocation-id eipalloc-yyyyyyyyy
```

---

## 📊 Parte 4: Monitoramento e Logs

### 4.1 CloudWatch Logs para ServeRest
```bash
# Instalar CloudWatch Agent na EC2 ServeRest
sudo yum install -y amazon-cloudwatch-agent

# Configurar coleta de logs
sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<'EOF'
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/serverest/output.log",
                        "log_group_name": "/aws/ec2/serverest/application",
                        "log_stream_name": "{instance_id}-output"
                    },
                    {
                        "file_path": "/var/log/serverest/error.log", 
                        "log_group_name": "/aws/ec2/serverest/errors",
                        "log_stream_name": "{instance_id}-errors"
                    }
                ]
            }
        }
    }
}
EOF

# Iniciar agente
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

### 4.2 Dashboard de Monitoramento
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/EC2", "CPUUtilization", "InstanceId", "i-serverest"],
          ["AWS/EC2", "CPUUtilization", "InstanceId", "i-testrunner"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "EC2 CPU Utilization"
      }
    },
    {
      "type": "log",
      "properties": {
        "query": "SOURCE '/aws/ec2/serverest/application'\n| fields @timestamp, @message\n| sort @timestamp desc\n| limit 100",
        "region": "us-east-1", 
        "title": "ServeRest Application Logs"
      }
    }
  ]
}
```

---

## 🚀 Parte 5: Automatização com Scripts

### 5.1 Script de Deploy Completo
```bash
#!/bin/bash
# deploy-aws-infrastructure.sh

set -e

echo "🚀 Deploying ServeRest AWS Infrastructure..."

# Variáveis
KEY_NAME="serverest-key"
REGION="us-east-1"
AMI_ID="ami-0abcdef1234567890"  # Amazon Linux 2023

# 1. Criar Key Pair se não existir
if ! aws ec2 describe-key-pairs --key-names $KEY_NAME --region $REGION > /dev/null 2>&1; then
    echo "Creating key pair..."
    aws ec2 create-key-pair \
        --key-name $KEY_NAME \
        --region $REGION \
        --query 'KeyMaterial' \
        --output text > ${KEY_NAME}.pem
    chmod 400 ${KEY_NAME}.pem
fi

# 2. Criar Security Groups
echo "Creating security groups..."
SERVEREST_SG=$(aws ec2 create-security-group \
    --group-name serverest-sg \
    --description "ServeRest API Security Group" \
    --region $REGION \
    --query 'GroupId' \
    --output text)

TESTRUNNER_SG=$(aws ec2 create-security-group \
    --group-name test-runner-sg \
    --description "Test Runner Security Group" \
    --region $REGION \
    --query 'GroupId' \
    --output text)

# 3. Configurar regras de segurança
aws ec2 authorize-security-group-ingress \
    --group-id $SERVEREST_SG \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region $REGION

aws ec2 authorize-security-group-ingress \
    --group-id $SERVEREST_SG \
    --protocol tcp \
    --port 3000 \
    --source-group $TESTRUNNER_SG \
    --region $REGION

aws ec2 authorize-security-group-ingress \
    --group-id $TESTRUNNER_SG \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region $REGION

# 4. Lançar instância ServeRest
echo "Launching ServeRest instance..."
SERVEREST_INSTANCE=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --security-group-ids $SERVEREST_SG \
    --user-data file://user-data-serverest.sh \
    --region $REGION \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ServeRest-API}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

# 5. Lançar instância Test Runner  
echo "Launching Test Runner instance..."
TESTRUNNER_INSTANCE=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t2.small \
    --key-name $KEY_NAME \
    --security-group-ids $TESTRUNNER_SG \
    --user-data file://user-data-testrunner.sh \
    --region $REGION \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test-Runner}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

# 6. Aguardar instâncias ficarem disponíveis
echo "Waiting for instances to be ready..."
aws ec2 wait instance-running \
    --instance-ids $SERVEREST_INSTANCE $TESTRUNNER_INSTANCE \
    --region $REGION

# 7. Obter IPs públicos
SERVEREST_IP=$(aws ec2 describe-instances \
    --instance-ids $SERVEREST_INSTANCE \
    --region $REGION \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

TESTRUNNER_IP=$(aws ec2 describe-instances \
    --instance-ids $TESTRUNNER_INSTANCE \
    --region $REGION \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

# 8. Salvar informações de deployment
cat > deployment-info.txt <<EOF
# ServeRest AWS Deployment Information

## Instances
ServeRest Instance ID: $SERVEREST_INSTANCE
Test Runner Instance ID: $TESTRUNNER_INSTANCE

## IP Addresses  
ServeRest Public IP: $SERVEREST_IP
Test Runner Public IP: $TESTRUNNER_IP

## URLs
ServeRest API: http://$SERVEREST_IP:3000
Health Check: http://$SERVEREST_IP:3000/usuarios

## SSH Access
ssh -i ${KEY_NAME}.pem ec2-user@$SERVEREST_IP
ssh -i ${KEY_NAME}.pem ec2-user@$TESTRUNNER_IP

## Test Execution
From Test Runner: /home/ec2-user/run-tests.sh $SERVEREST_IP

## Security Groups
ServeRest SG: $SERVEREST_SG  
Test Runner SG: $TESTRUNNER_SG

Deployment completed at: $(date)
EOF

echo "✅ Deployment completed successfully!"
echo "📁 Check deployment-info.txt for details"
echo "🔗 ServeRest will be available at: http://$SERVEREST_IP:3000"
echo "⏱️  Allow 2-3 minutes for services to start"
```

---

## 📋 Parte 6: Guia de Uso e Manutenção

### 6.1 Comandos Úteis
```bash
# Verificar status do ServeRest
ssh -i serverest-key.pem ec2-user@<SERVEREST_IP>
sudo systemctl status serverest
curl http://localhost:3000/usuarios

# Executar testes manualmente
ssh -i serverest-key.pem ec2-user@<TESTRUNNER_IP>  
/home/ec2-user/run-tests.sh <SERVEREST_IP>

# Ver logs do ServeRest
sudo tail -f /var/log/serverest/output.log
sudo tail -f /var/log/serverest/error.log

# Reiniciar ServeRest se necessário
sudo systemctl restart serverest
```

### 6.2 Troubleshooting
```bash
# Se ServeRest não responder:
1. Verificar se processo está rodando: sudo systemctl status serverest
2. Verificar logs: sudo journalctl -u serverest -f
3. Verificar porta: sudo netstat -tlnp | grep 3000
4. Reiniciar: sudo systemctl restart serverest

# Se testes falharem:
1. Verificar conectividade: curl http://<SERVEREST_IP>:3000/usuarios
2. Verificar security groups
3. Verificar se git pull foi feito
4. Verificar logs: tail -f /var/log/scheduled-tests.log
```

### 6.3 Monitoramento de Custos
```bash
# Estimativa de custos (Free Tier):
# t2.micro (ServeRest): $0/mês (750 horas free tier)
# t2.small (Test Runner): ~$17/mês
# Elastic IP: $0 (se associado à instância)
# Storage: $0.8/mês (8GB GP3)
# Data Transfer: $0 (primeiros 1GB grátis)

# Total estimado: ~$18/mês (após free tier)
```

---

## ✅ Checklist de Implementação

### Pré-Deploy
- [ ] Conta AWS configurada
- [ ] AWS CLI instalado e configurado
- [ ] Chave SSH criada
- [ ] Scripts de user-data preparados

### Deploy
- [ ] Executar script de deploy
- [ ] Verificar instâncias criadas
- [ ] Testar acesso SSH às duas instâncias
- [ ] Aguardar inicialização completa (5-10 min)

### Validação
- [ ] ServeRest responde em `http://<IP>:3000/usuarios`
- [ ] Test Runner consegue clonar repositório git
- [ ] Testes executam com sucesso
- [ ] Logs estão sendo gerados corretamente

### Manutenção
- [ ] Configurar backups se necessário
- [ ] Monitorar custos AWS
- [ ] Agendar execução de testes
- [ ] Configurar alertas CloudWatch

---

## 🎯 Benefícios da Implementação AWS

### Técnicos
- ✅ **Ambiente isolado** para testes
- ✅ **Escalabilidade** conforme necessário  
- ✅ **Disponibilidade** 24/7
- ✅ **Monitoramento** integrado com CloudWatch

### Operacionais  
- ✅ **Automação completa** da execução
- ✅ **Histórico de execuções** preservado
- ✅ **Integração com CI/CD** facilitada
- ✅ **Ambiente próximo à produção**

### Educacionais
- ✅ **Experiência com AWS** EC2, Security Groups, CloudWatch
- ✅ **DevOps practices** com infraestrutura como código
- ✅ **Network troubleshooting** entre instâncias
- ✅ **Monitoring e logging** em ambiente cloud