# Execução dos Testes Automatizados - ServeRest

**Autor**: Caio Oliveira Silva Alencar  
**Data**: Outubro 2025

## 📋 Pré-requisitos

### Ferramentas Necessárias
- **Python 3.8+** instalado
- **Robot Framework** e bibliotecas
- **Git** para controle de versão

### Instalação das Dependências
```bash
# Instalar Robot Framework e bibliotecas
pip install robotframework
pip install robotframework-requests  
pip install robotframework-jsonlibrary

# Verificar instalação
robot --version
```

---

## 🚀 Como Executar os Testes

### Execução Básica
```bash
# Navegar para o diretório do projeto
cd "e:\programação\estagio\Estagio\automation\robot-framework"

# Executar todos os testes
robot tests/

# Executar suite específica
robot tests/auth/test_auth.robot
robot tests/cart/test_cart_boundary.robot
```

### Execução com Filtros
```bash
# Executar apenas testes críticos
robot --include critical tests/

# Executar apenas testes de boundary
robot --include boundary tests/

# Executar testes de um módulo específico
robot --include auth tests/

# Executar smoke tests
robot --include smoke tests/
```

### Execução com Configurações Personalizadas
```bash
# Definir ambiente de teste
robot --variable BASE_URL:http://localhost:3000 tests/

# Salvar resultados em diretório específico
robot --outputdir results tests/

# Executar com log detalhado
robot --loglevel DEBUG tests/

# Executar em paralelo (com pabot)
pabot --processes 4 tests/
```

---

## 📊 Relatórios e Resultados

### Arquivos Gerados
- **output.xml**: Dados detalhados da execução
- **log.html**: Log interativo da execução  
- **report.html**: Relatório resumido dos resultados

### Visualização dos Resultados
```bash
# Abrir relatório no navegador (Windows)
start report.html

# Ou navegar manualmente para o arquivo report.html
```

### Estrutura de Resultados
```
results/
├── output.xml          # Dados XML da execução
├── log.html           # Log detalhado interativo
├── report.html        # Relatório visual dos resultados
├── screenshots/       # Evidências (se configurado)
└── test-evidence/     # Logs adicionais
```

---

## 🎯 Cenários de Execução

### 1. Smoke Tests (Execução Rápida)
```bash
# Testes essenciais - ~2 minutos
robot --include smoke --outputdir results/smoke tests/
```

**Inclui:**
- Login básico
- CRUD essencial de usuários
- CRUD essencial de produtos
- Adição básica ao carrinho

### 2. Regression Tests (Suite Completa)
```bash
# Todos os testes - ~15 minutos
robot --outputdir results/regression tests/
```

**Inclui:**
- Todos os testes funcionais
- Todos os boundary tests
- Testes de integração
- Validações de segurança

### 3. Boundary Tests (Testes de Limite)
```bash
# Apenas boundary testing - ~5 minutos
robot --include boundary --outputdir results/boundary tests/
```

**Inclui:**
- Validações de campos
- Testes de limite de estoque
- Boundary de autenticação
- Valores extremos

### 4. Integration Tests (Fluxos E2E)
```bash
# Testes de integração - ~8 minutos
robot --include integration --outputdir results/integration tests/
```

**Inclui:**
- Fluxos completos de compra
- Integração entre módulos
- Cenários de negócio complexos

---

## 🔧 Configurações Avançadas

### Variáveis de Ambiente
Criar arquivo `variables.py` personalizado:
```python
# custom_variables.py
BASE_URL = "https://meu-ambiente.com"
TIMEOUT = 30
DEBUG_MODE = True
```

Usar nas execuções:
```bash
robot --variablefile custom_variables.py tests/
```

### Execução Paralela
```bash
# Instalar pabot
pip install robotframework-pabot

# Executar em paralelo
pabot --processes 4 --outputdir results/parallel tests/
```

### Integração CI/CD
```bash
# Comando para CI/CD (Jenkins, GitHub Actions, etc.)
robot --outputdir results --output output.xml --log log.html --report report.html --loglevel INFO tests/
```

---

## 📈 Métricas e Monitoramento

### Análise de Resultados
```bash
# Comando para estatísticas
robot --dryrun --output stats.xml tests/
```

### KPIs Importantes
- **Taxa de Sucesso**: > 95% esperada
- **Tempo de Execução**: Suite completa < 20 minutos
- **Cobertura**: > 80% dos casos de teste críticos

### Falhas Comuns e Soluções

#### 1. Erro de Conexão
```
Error: Connection refused
```
**Solução**: Verificar se API está disponível
```bash
curl https://serverest.dev/usuarios
```

#### 2. Token Expirado
```
Error: 401 Unauthorized
```  
**Solução**: Verificar configuração de timeout nos testes

#### 3. Dados de Teste Conflitantes
```
Error: Email já existe
```
**Solução**: Usar dados únicos baseados em timestamp

---

## 📋 Checklist de Execução

### Antes da Execução
- [ ] API ServeRest está disponível
- [ ] Dependências estão instaladas  
- [ ] Diretório de resultados existe
- [ ] Não há testes executando em paralelo

### Durante a Execução
- [ ] Monitorar logs em tempo real
- [ ] Verificar se não há timeouts excessivos
- [ ] Observar padrões de falha

### Após a Execução
- [ ] Analisar relatório gerado
- [ ] Verificar taxa de sucesso
- [ ] Documentar falhas encontradas
- [ ] Arquivar resultados com timestamp

---

## 🔄 Integração com Processo Manual

### Fluxo Recomendado
1. **Executar Smoke Tests** automatizados
2. **Executar testes manuais** específicos
3. **Executar Regression** automatizada
4. **Validar resultados** combinados
5. **Gerar relatório** consolidado

### Complemento aos Testes Manuais
- Automação **não substitui** exploração manual
- Usar automação para **regressão** e **smoke**
- Manter testes manuais para **novos cenários**
- **Documentar descobertas** para futura automação

---

## 📞 Suporte e Troubleshooting

### Logs Detalhados
```bash
# Máximo detalhe para debug
robot --loglevel TRACE --console verbose tests/auth/test_auth.robot
```

### Execução de Teste Único
```bash
# Executar apenas um teste específico
robot --test "CT-001: Login com Credenciais Válidas" tests/auth/test_auth.robot
```

### Modo Debug
```bash
# Parar na primeira falha para análise
robot --exitonfailure tests/
```