# =============================================================================
# CONFIGURAÇÃO AWS EC2 - TEMPLATE
# =============================================================================
# Copie este arquivo e edite com suas informações

# INFORMAÇÕES DAS INSTÂNCIAS EC2
EC2_1_PUBLIC_IP="3.84.123.456"          # IP público da EC2-1 (ServeRest)
EC2_2_PUBLIC_IP="52.91.234.567"         # IP público da EC2-2 (Robot Framework)  
KEY_PAIR_FILE="minha-chave.pem"          # Nome do arquivo da chave SSH
AWS_REGION="us-east-1"                   # Região AWS utilizada

# CONFIGURAÇÕES DE REDE
SERVEREST_PORT="3000"                    # Porta onde ServeRest roda
SECURITY_GROUP_ID="sg-0123456789abcdef0" # ID do Security Group

# URLS DE ACESSO
SERVEREST_BASE_URL="http://${EC2_1_PUBLIC_IP}:${SERVEREST_PORT}"

# COMANDOS DE CONEXÃO SSH (exemplos)
# ssh -i "${KEY_PAIR_FILE}" ubuntu@${EC2_1_PUBLIC_IP}  # Conectar EC2-1
# ssh -i "${KEY_PAIR_FILE}" ubuntu@${EC2_2_PUBLIC_IP}  # Conectar EC2-2

# =============================================================================
# CHECKLIST DE CONFIGURAÇÃO
# =============================================================================

## ✅ PRÉ-REQUISITOS
# [ ] Conta AWS ativa
# [ ] Key Pair criado e baixado
# [ ] 2 instâncias EC2 criadas (t2.micro)
# [ ] Security Group configurado (portas 22, 80, 3000)
# [ ] IPs públicos anotados

## ✅ EC2-1 (SERVEREST)
# [ ] Conectar via SSH
# [ ] Executar script setup-ec2-serverest.sh
# [ ] Verificar serviço: sudo systemctl status serverest
# [ ] Testar: curl http://localhost:3000/usuarios
# [ ] Verificar IP público: curl http://checkip.amazonaws.com

## ✅ EC2-2 (ROBOT FRAMEWORK)
# [ ] Conectar via SSH
# [ ] Executar script setup-ec2-robot.sh (informar IP da EC2-1)
# [ ] Testar conectividade: ~/quick-test.sh
# [ ] Executar testes: ~/run-tests.sh
# [ ] Verificar resultados: ls ~/test-results/

## ✅ VALIDAÇÃO FINAL
# [ ] ServeRest acessível externamente: curl http://${EC2_1_PUBLIC_IP}:3000/usuarios
# [ ] Testes Robot Framework passando 100%
# [ ] Logs sendo gerados corretamente
# [ ] Comunicação entre EC2s funcionando

# =============================================================================
# COMANDOS ÚTEIS DE VERIFICAÇÃO
# =============================================================================

# Verificar status geral das instâncias
# aws ec2 describe-instances --instance-ids i-1234567890abcdef0 i-0987654321fedcba0

# Verificar Security Group
# aws ec2 describe-security-groups --group-ids ${SECURITY_GROUP_ID}

# Monitorar custos
# aws ce get-cost-and-usage --time-period Start=2025-10-01,End=2025-10-31 --granularity DAILY --metrics BlendedCost

# =============================================================================
# TROUBLESHOOTING COMUM
# =============================================================================

## Connection Refused:
# 1. Verificar se ServeRest está rodando: sudo systemctl status serverest
# 2. Verificar Security Group (porta 3000 liberada)
# 3. Verificar IP público correto

## Testes falhando:
# 1. Testar conectividade: ~/quick-test.sh
# 2. Verificar configuração: cat ~/robot-config.sh
# 3. Ver logs: sudo journalctl -u serverest -f

## Performance lenta:
# 1. Verificar recursos: htop
# 2. Verificar rede: ping between instances
# 3. Considerar instância maior se necessário

# =============================================================================
# OTIMIZAÇÃO DE CUSTOS
# =============================================================================

# Parar instâncias quando não usar:
# aws ec2 stop-instances --instance-ids i-1234567890abcdef0 i-0987654321fedcba0

# Iniciar quando precisar:
# aws ec2 start-instances --instance-ids i-1234567890abcdef0 i-0987654321fedcba0

# Programar desligamento automático (crontab):
# 0 22 * * * sudo shutdown -h now  # Desligar às 22h

# Monitorar uso:
# aws cloudwatch get-metric-statistics \
#   --namespace AWS/EC2 \
#   --metric-name CPUUtilization \
#   --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
#   --start-time 2025-10-01T00:00:00Z \
#   --end-time 2025-10-02T00:00:00Z \
#   --period 3600 \
#   --statistics Average