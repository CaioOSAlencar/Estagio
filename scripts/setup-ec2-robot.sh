#!/bin/bash
# =============================================================================
# SETUP AUTOMATIZADO - EC2-2 (Robot Framework)
# =============================================================================
# Script para configurar automaticamente a instância EC2 que executará os testes
# Execute: wget -O - https://raw.githubusercontent.com/CaioOSAlencar/Estagio/main/scripts/setup-ec2-robot.sh | bash

set -e  # Parar em caso de erro

echo "🤖 Iniciando setup do Robot Framework na EC2..."

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

# Solicitar IP do ServeRest
echo "🎯 Configuração do Robot Framework"
echo ""
read -p "📡 Digite o IP público da EC2 que roda o ServeRest: " SERVEREST_IP

if [[ -z "$SERVEREST_IP" ]]; then
    print_error "IP do ServeRest é obrigatório!"
    exit 1
fi

print_status "IP do ServeRest configurado: $SERVEREST_IP"

# =============================================================================
# ETAPA 1: Atualizar Sistema
# =============================================================================
print_status "Atualizando sistema operacional..."
sudo apt update && sudo apt upgrade -y
print_success "Sistema atualizado!"

# =============================================================================
# ETAPA 2: Instalar Dependências
# =============================================================================
print_status "Instalando Python, pip e git..."
sudo apt install -y python3 python3-pip git curl wget

# Verificar instalação
PYTHON_VERSION=$(python3 --version)
PIP_VERSION=$(pip3 --version)
print_success "Python instalado: $PYTHON_VERSION"
print_success "pip instalado: $PIP_VERSION"

# =============================================================================
# ETAPA 3: Clonar Repositório
# =============================================================================
print_status "Clonando repositório do projeto..."
cd ~
if [ -d "Estagio" ]; then
    print_warning "Diretório Estagio já existe, atualizando..."
    cd Estagio
    git pull
else
    git clone https://github.com/CaioOSAlencar/Estagio.git
    cd Estagio
fi

print_success "Repositório clonado/atualizado!"

# =============================================================================
# ETAPA 4: Instalar Robot Framework
# =============================================================================
print_status "Instalando Robot Framework e dependências..."
pip3 install --user robotframework robotframework-requests robotframework-jsonlibrary

# Adicionar ao PATH se necessário
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
source ~/.bashrc

# Verificar instalação
ROBOT_VERSION=$(~/.local/bin/robot --version 2>/dev/null || python3 -m robot --version)
print_success "Robot Framework instalado: $ROBOT_VERSION"

# =============================================================================
# ETAPA 5: Configurar Variáveis de Ambiente
# =============================================================================
print_status "Configurando variáveis de ambiente..."

cat > ~/robot-config.sh << EOF
#!/bin/bash
# Configurações do Robot Framework
export SERVEREST_BASE_URL="http://$SERVEREST_IP:3000"
export ROBOT_OUTPUT_DIR="/home/ubuntu/test-results"
export PATH=\$PATH:~/.local/bin
mkdir -p \$ROBOT_OUTPUT_DIR
echo "🎯 Configurado para usar ServeRest em: \$SERVEREST_BASE_URL"
EOF

chmod +x ~/robot-config.sh
source ~/robot-config.sh

print_success "Variáveis configuradas!"
print_status "ServeRest Target: $SERVEREST_BASE_URL"

# =============================================================================
# ETAPA 6: Atualizar Configuração dos Testes
# =============================================================================
print_status "Atualizando configuração dos testes..."

cd ~/Estagio/automation/robot-framework

# Criar arquivo de configuração personalizado
cat > resources/config/aws_config.robot << EOF
*** Variables ***
# Configuração AWS - IP da instância ServeRest
\${BASE_URL}    http://$SERVEREST_IP:3000

*** Keywords ***
Setup AWS Session
    [Documentation]    Configura sessão para usar ServeRest na AWS
    Create Session    serverest    \${BASE_URL}    verify=false
    Set Suite Variable    \${BASE_URL}
EOF

print_success "Configuração dos testes atualizada!"

# =============================================================================
# ETAPA 7: Criar Scripts de Execução
# =============================================================================
print_status "Criando scripts de execução..."

# Script principal de execução
cat > ~/run-tests.sh << 'EOF'
#!/bin/bash
# Script para executar testes Robot Framework na AWS

source ~/robot-config.sh

echo "🚀 Iniciando execução dos testes Robot Framework"
echo "🎯 Target ServeRest: $SERVEREST_BASE_URL"
echo "📁 Resultados em: $ROBOT_OUTPUT_DIR"
echo ""

cd ~/Estagio/automation/robot-framework

# Verificar conectividade com ServeRest
echo "📡 Testando conectividade com ServeRest..."
if curl -f $SERVEREST_BASE_URL/usuarios > /dev/null 2>&1; then
    echo "✅ ServeRest acessível!"
else
    echo "❌ Erro: ServeRest não está acessível em $SERVEREST_BASE_URL"
    echo "🔍 Verifique se:"
    echo "  - A instância EC2-1 está rodando"
    echo "  - O ServeRest está ativo na EC2-1"
    echo "  - O Security Group permite tráfego na porta 3000"
    exit 1
fi

echo ""
echo "🧪 Executando testes básicos..."
robot --outputdir $ROBOT_OUTPUT_DIR \
      --variable BASE_URL:$SERVEREST_BASE_URL \
      --name "Testes_Basicos_AWS" \
      tests/auth/test_basic_working.robot

echo ""
echo "🧪 Executando testes completos..."
robot --outputdir $ROBOT_OUTPUT_DIR \
      --variable BASE_URL:$SERVEREST_BASE_URL \
      --name "Testes_Completos_AWS" \
      tests/complete/test_serverest_complete.robot

echo ""
echo "✅ Execução concluída!"
echo "📊 Resultados disponíveis em: $ROBOT_OUTPUT_DIR"
ls -la $ROBOT_OUTPUT_DIR/
EOF

chmod +x ~/run-tests.sh

# Script de teste rápido
cat > ~/quick-test.sh << 'EOF'
#!/bin/bash
# Teste rápido de conectividade

source ~/robot-config.sh

echo "🔍 Teste rápido de conectividade"
echo "🎯 Target: $SERVEREST_BASE_URL"

# Testar endpoints básicos
echo "📡 Testando /usuarios..."
curl -s $SERVEREST_BASE_URL/usuarios | head -c 200
echo ""

echo "📡 Testando /produtos..."
curl -s $SERVEREST_BASE_URL/produtos | head -c 200
echo ""

echo "✅ Teste de conectividade concluído!"
EOF

chmod +x ~/quick-test.sh

# Script de monitoramento
cat > ~/monitor-tests.sh << 'EOF'
#!/bin/bash
# Monitor contínuo dos testes

source ~/robot-config.sh

while true; do
    clear
    echo "🖥️  Monitor de Testes Robot Framework - $(date)"
    echo "🎯 Target: $SERVEREST_BASE_URL"
    echo ""
    
    # Status da conectividade
    if curl -f $SERVEREST_BASE_URL/usuarios > /dev/null 2>&1; then
        echo "✅ ServeRest: ONLINE"
    else
        echo "❌ ServeRest: OFFLINE"
    fi
    
    echo ""
    echo "📊 Últimos resultados de teste:"
    if [ -d "$ROBOT_OUTPUT_DIR" ]; then
        ls -lt $ROBOT_OUTPUT_DIR/ | head -5
    else
        echo "Nenhum resultado encontrado ainda."
    fi
    
    echo ""
    echo "💾 Uso de disco:"
    df -h | grep -E "/$"
    
    echo ""
    echo "Press Ctrl+C to exit..."
    sleep 30
done
EOF

chmod +x ~/monitor-tests.sh

print_success "Scripts de execução criados!"

# =============================================================================
# ETAPA 8: Testar Conectividade Inicial
# =============================================================================
print_status "Testando conectividade inicial..."

sleep 3
if curl -f $SERVEREST_BASE_URL/usuarios > /dev/null 2>&1; then
    print_success "✅ Conectividade com ServeRest OK!"
else
    print_warning "⚠️ ServeRest não acessível ainda. Verifique:"
    echo "  1. Se a EC2-1 está rodando"
    echo "  2. Se o ServeRest está ativo"
    echo "  3. Se o Security Group permite porta 3000"
fi

# =============================================================================
# ETAPA 9: Executar Teste de Exemplo
# =============================================================================
print_status "Executando teste de exemplo..."

cd ~/Estagio/automation/robot-framework
mkdir -p $ROBOT_OUTPUT_DIR

# Executar um teste simples se ServeRest estiver acessível
if curl -f $SERVEREST_BASE_URL/usuarios > /dev/null 2>&1; then
    print_status "Executando teste básico de conectividade..."
    
    # Criar teste mínimo
    cat > /tmp/test_connectivity.robot << EOF
*** Settings ***
Library    RequestsLibrary

*** Test Cases ***
Test ServeRest Connectivity
    [Documentation]    Teste básico de conectividade com ServeRest
    Create Session    serverest    $SERVEREST_BASE_URL
    \${response}=    GET On Session    serverest    /usuarios
    Should Be Equal As Numbers    \${response.status_code}    200
    Log    ✅ ServeRest conectado com sucesso!
EOF

    robot --outputdir $ROBOT_OUTPUT_DIR /tmp/test_connectivity.robot || true
    print_success "Teste de exemplo executado!"
else
    print_warning "Pulando teste de exemplo - ServeRest não acessível"
fi

# =============================================================================
# ETAPA 10: Informações Finais
# =============================================================================
echo ""
echo "🤖 ============================================="
echo "    SETUP DO ROBOT FRAMEWORK CONCLUÍDO!"
echo "============================================="
echo ""
print_success "Robot Framework configurado e pronto para uso!"
print_status "IP desta instância: $(curl -s http://checkip.amazonaws.com/)"
print_status "Target ServeRest: $SERVEREST_BASE_URL"
print_status "Resultados em: $ROBOT_OUTPUT_DIR"
echo ""
print_status "Scripts disponíveis:"
echo "  - ~/run-tests.sh      (executar todos os testes)"
echo "  - ~/quick-test.sh     (teste rápido de conectividade)"
echo "  - ~/monitor-tests.sh  (monitor contínuo)"
echo ""
print_status "Para executar os testes:"
echo "  ~/run-tests.sh"
echo ""
print_status "Para monitorar em tempo real:"
echo "  ~/monitor-tests.sh"
echo ""
print_status "Para testar conectividade:"
echo "  ~/quick-test.sh"
echo ""
if curl -f $SERVEREST_BASE_URL/usuarios > /dev/null 2>&1; then
    print_success "🎉 Tudo pronto! ServeRest acessível e Robot Framework configurado!"
else
    print_warning "⚠️ Configure o ServeRest na EC2-1 antes de executar os testes"
fi
echo ""
print_success "Setup concluído com sucesso! 🚀"