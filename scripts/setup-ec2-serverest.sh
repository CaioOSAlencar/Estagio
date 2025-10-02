#!/bin/bash
# =============================================================================
# SETUP AUTOMATIZADO - EC2-1 (ServeRest)
# =============================================================================
# Script para configurar automaticamente a instância EC2 que rodará o ServeRest
# Execute: wget -O - https://raw.githubusercontent.com/CaioOSAlencar/Estagio/main/scripts/setup-ec2-serverest.sh | bash

set -e  # Parar em caso de erro

echo "🚀 Iniciando setup do ServeRest na EC2..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# ETAPA 1: Atualizar Sistema
# =============================================================================
print_status "Atualizando sistema operacional..."
sudo apt update && sudo apt upgrade -y
print_success "Sistema atualizado!"

# =============================================================================
# ETAPA 2: Instalar Node.js
# =============================================================================
print_status "Instalando Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar instalação
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
print_success "Node.js instalado: $NODE_VERSION"
print_success "npm instalado: $NPM_VERSION"

# =============================================================================
# ETAPA 3: Instalar ServeRest
# =============================================================================
print_status "Instalando ServeRest globalmente..."
sudo npm install -g serverest

# Verificar instalação
SERVEREST_VERSION=$(npx serverest --version)
print_success "ServeRest instalado: $SERVEREST_VERSION"

# =============================================================================
# ETAPA 4: Criar Diretório de Trabalho
# =============================================================================
print_status "Configurando diretório de trabalho..."
mkdir -p ~/serverest-app
cd ~/serverest-app

# =============================================================================
# ETAPA 5: Configurar Serviço SystemD
# =============================================================================
print_status "Configurando serviço systemd..."

sudo tee /etc/systemd/system/serverest.service > /dev/null <<EOF
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
EOF

print_success "Arquivo de serviço criado!"

# =============================================================================
# ETAPA 6: Iniciar Serviço
# =============================================================================
print_status "Iniciando serviço ServeRest..."
sudo systemctl daemon-reload
sudo systemctl enable serverest
sudo systemctl start serverest

# Aguardar um pouco para o serviço inicializar
sleep 5

# Verificar se o serviço está rodando
if sudo systemctl is-active --quiet serverest; then
    print_success "ServeRest iniciado com sucesso!"
else
    print_error "Falha ao iniciar ServeRest!"
    sudo systemctl status serverest
    exit 1
fi

# =============================================================================
# ETAPA 7: Testar Conectividade
# =============================================================================
print_status "Testando conectividade local..."

# Aguardar mais um pouco
sleep 10

if curl -f http://localhost:3000/usuarios > /dev/null 2>&1; then
    print_success "ServeRest respondendo corretamente!"
else
    print_warning "ServeRest pode estar ainda inicializando..."
    print_status "Verificando logs..."
    sudo journalctl -u serverest --lines=20
fi

# =============================================================================
# ETAPA 8: Configurar Firewall (se estiver ativo)
# =============================================================================
print_status "Configurando firewall..."
if sudo ufw status | grep -q "Status: active"; then
    print_status "UFW ativo, liberando porta 3000..."
    sudo ufw allow 3000/tcp
    print_success "Porta 3000 liberada no firewall!"
else
    print_status "UFW não está ativo, pulando configuração de firewall..."
fi

# =============================================================================
# ETAPA 9: Criar Scripts Úteis
# =============================================================================
print_status "Criando scripts úteis..."

# Script para verificar status
cat > ~/check-serverest.sh << 'EOF'
#!/bin/bash
echo "🔍 Status do ServeRest:"
sudo systemctl status serverest --no-pager

echo ""
echo "📊 Conectividade:"
if curl -f http://localhost:3000/usuarios > /dev/null 2>&1; then
    echo "✅ ServeRest respondendo"
else
    echo "❌ ServeRest não responde"
fi

echo ""
echo "📋 Logs recentes:"
sudo journalctl -u serverest --lines=10 --no-pager
EOF

chmod +x ~/check-serverest.sh

# Script para reiniciar ServeRest
cat > ~/restart-serverest.sh << 'EOF'
#!/bin/bash
echo "🔄 Reiniciando ServeRest..."
sudo systemctl restart serverest
sleep 5
echo "✅ ServeRest reiniciado!"
~/check-serverest.sh
EOF

chmod +x ~/restart-serverest.sh

print_success "Scripts criados: check-serverest.sh, restart-serverest.sh"

# =============================================================================
# ETAPA 10: Informações Finais
# =============================================================================
echo ""
echo "🎉 ============================================="
echo "    SETUP DO SERVEREST CONCLUÍDO!"
echo "============================================="
echo ""
print_success "ServeRest está rodando na porta 3000"
print_status "IP Público da instância: $(curl -s http://checkip.amazonaws.com/)"
print_status "URL de acesso: http://$(curl -s http://checkip.amazonaws.com/):3000"
echo ""
print_status "Scripts disponíveis:"
echo "  - ~/check-serverest.sh    (verificar status)"
echo "  - ~/restart-serverest.sh  (reiniciar serviço)"
echo ""
print_warning "IMPORTANTE: Configure o Security Group da EC2 para liberar a porta 3000!"
echo ""
print_status "Para verificar se tudo está funcionando:"
echo "  curl http://localhost:3000/usuarios"
echo ""
print_status "Para ver logs do serviço:"
echo "  sudo journalctl -u serverest -f"
echo ""
print_success "Setup concluído com sucesso! 🚀"