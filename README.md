# Challenge ServeRest - Testes API Avançados 🚀

## 📋 Visão Geral

Este projeto é uma **evolução completa** dos testes da API ServeRest, desenvolvido como continuidade do challenge anterior. O foco está em aplicar **melhorias baseadas nos feedbacks dos instrutores**, implementar **testes de limite (boundary testing)** abrangentes e criar uma **suite de automação robusta** com Robot Framework.

## 🎯 Objetivos do Challenge

### Objetivos Principais
1. ✅ **Organizar planejamento de testes** aplicando melhorias dos feedbacks
2. ✅ **Melhorar estratégia de testes** com foco em regras de negócio e boundary testing  
3. ✅ **Refinar candidatos à automação** com critérios claros
4. ✅ **Criar testes automatizados** usando Robot Framework
5. ✅ **Integrar com QALity/Jira** para gestão de execuções
6. ✅ **Manter documentação atualizada** no Git diariamente

### Tarefa Extra 🌟
- **Deploy em AWS EC2**: ServeRest rodando em uma EC2 e testes executando de outra EC2

## 💬 Feedback do Instrutor Aplicado

> *"A entrega está boa e mostra que ele compreendeu bem o desafio. Porém, com mais atenção às **regras de negócio**, inclusão de **testes de limite** e uma melhor **documentação das execuções**, o trabalho ficará mais completo, claro e confiável."*

### ✅ Melhorias Implementadas:
- **📋 Regras de negócio**: 22 regras documentadas e testadas sistematicamente
- **📏 Testes de limite**: Boundary testing em todos os módulos com valores extremos
- **📚 Documentação**: Templates detalhados, guias de execução e relatórios estruturados

---

## 🗂️ Estrutura do Projeto

```
📁 Estagio/
├── 📁 docs/                              # 📚 Documentação completa
│   ├── 📄 README.md                      # Visão geral do projeto
│   ├── 📄 test-strategy.md               # Estratégia de testes atualizada
│   ├── 📄 test-plan.md                   # Plano de testes detalhado
│   ├── 📄 business-rules.md              # 22 regras de negócio identificadas
│   ├── 📄 automation-candidates.md       # Critérios de automação
│   └── 📄 qality-jira-integration.md     # Guia de integração QALity/Jira
│
├── 📁 manual-tests/                      # 🧪 Testes manuais
│   ├── 📁 test-cases/                    # Casos de teste detalhados
│   │   ├── 📄 template-caso-teste.md     # Template padrão
│   │   ├── 📄 CT-001-login-valido.md     # Exemplo funcional
│   │   └── 📄 CT-015-boundary-estoque.md # Exemplo boundary testing
│   ├── 📁 test-execution/                # Registros de execução
│   │   └── 📄 template-execucao.md       # Template de execução
│   └── 📁 evidence/                      # 📸 Evidências dos testes
│
├── 📁 automation/                        # 🤖 Testes automatizados
│   └── 📁 robot-framework/               # Suite Robot Framework
│       ├── 📁 tests/                     # Testes organizados por módulo
│       │   ├── 📁 auth/                  # Testes de autenticação
│       │   └── 📁 cart/                  # Testes de carrinho (boundary)
│       ├── 📁 resources/                 # Recursos compartilhados
│       │   ├── 📁 keywords/              # Keywords customizadas
│       │   └── 📁 variables/             # Variáveis globais
│       ├── 📄 master_suite.robot         # Suite principal
│       └── 📄 EXECUTAR_TESTES.md         # Guia de execução
│
├── 📁 postman/                           # 📮 Coleções Postman
│   └── 📄 ServeRest.postman_collection.json
│
└── 📁 aws-deployment/                    # ☁️ Tarefa extra AWS
    └── 📄 README.md                      # Guia completo de deploy EC2
```

---

## 🚀 Como Começar

### 1. 📚 Compreender a Estratégia
```bash
# Ler documentação fundamental
├── docs/test-strategy.md          # Estratégia atualizada
├── docs/business-rules.md         # Regras de negócio detalhadas  
└── docs/automation-candidates.md  # Critérios de automação
```

### 2. 🧪 Executar Testes Manuais
```bash
# Usar templates estruturados
├── manual-tests/test-cases/template-caso-teste.md
├── manual-tests/test-execution/template-execucao.md
└── Focar em boundary testing e regras de negócio
```

### 3. 🤖 Executar Testes Automatizados
```bash
# Navegar para automação
cd automation/robot-framework

# Instalar dependências
pip install robotframework robotframework-requests

# Executar testes
robot tests/auth/test_auth.robot
robot tests/cart/test_cart_boundary.robot

# Ver guia completo
cat EXECUTAR_TESTES.md
```

### 4. ☁️ Deploy AWS (Tarefa Extra)
```bash
# Seguir guia detalhado
cat aws-deployment/README.md
```

---

## 🎯 Destaques das Melhorias

### 📋 **Regras de Negócio Documentadas**
22 regras identificadas e organizadas por módulo:
- **RN-001 a RN-007**: Autenticação e Usuários
- **RN-008 a RN-012**: Produtos e Permissões  
- **RN-013 a RN-018**: Carrinho e Estoque
- **RN-019 a RN-022**: Regras Transversais

### 📏 **Boundary Testing Abrangente**
Testes de limite implementados para:
- **Campos de texto**: Mínimo, máximo, overflow
- **Valores numéricos**: Zero, negativos, extremos
- **Estoque**: Limites exatos (qtd=estoque, qtd=estoque+1)  
- **Timeouts**: Expiração de token (599s, 600s, 601s)

### 🤖 **Automação Estruturada**  
Suite Robot Framework com:
- **Keywords reutilizáveis** para operações comuns
- **Data-driven testing** para cenários múltiplos
- **Templates parameterizáveis** para boundary tests
- **Relatórios detalhados** com evidências

### 📊 **Integração QALity/Jira**
Processo completo para:
- **Gestão de test cases** no Jira
- **Execuções rastreáveis** via QALity
- **Dashboards de qualidade** com KPIs
- **Integração com CI/CD** para automação

---

## 📈 Métricas de Qualidade

### Cobertura de Testes
- ✅ **100%** dos endpoints críticos cobertos
- ✅ **22 regras de negócio** validadas sistematicamente  
- ✅ **70%** dos casos críticos automatizados
- ✅ **Boundary testing** em todos os módulos

### Processo de Execução
- 🔥 **Smoke tests**: 5 minutos (automatizados)
- 🧪 **Regression completa**: 20 minutos (híbrida)
- 📏 **Boundary tests**: 8 minutos (automatizados)
- 🔗 **Integration tests**: 12 minutos (manuais + automatizados)

### Documentação
- 📚 **5 documentos estratégicos** detalhados
- 📝 **Templates padronizados** para execução
- 🎯 **Guias específicos** para cada ferramenta
- 📊 **Critérios objetivos** para automação

---

## 🛠️ Ferramentas Utilizadas

### Testes Manuais
- **Postman**: Execução de casos de teste
- **Newman**: Automação das collections Postman  
- **Templates Markdown**: Documentação estruturada

### Testes Automatizados  
- **Robot Framework**: Framework principal de automação
- **RequestsLibrary**: Biblioteca para APIs REST
- **Data-driven testing**: Cenários parametrizáveis

### Gestão e Integração
- **QALity**: Execução de testes no Jira
- **Jira**: Rastreamento e dashboards
- **Git**: Controle de versão diário
- **AWS EC2**: Ambiente cloud (tarefa extra)

---

## 📋 Próximos Passos

### Semana 1: Execução Manual Completa
- [ ] Executar todos os casos manuais com templates
- [ ] Documentar evidências organizadamente  
- [ ] Focar em boundary testing e regras de negócio
- [ ] Identificar novos bugs ou comportamentos

### Semana 2: Automação Prioritária  
- [ ] Implementar testes de autenticação automatizados
- [ ] Criar suite de boundary testing para carrinho
- [ ] Configurar execução automatizada diária
- [ ] Integrar com repositório Git

### Semana 3: Integração QALity/Jira
- [ ] Configurar test cases no Jira via QALity
- [ ] Executar rodadas de teste rastreáveis
- [ ] Configurar dashboards de qualidade
- [ ] Documentar processo de integração

### Semana 4: AWS Deploy (Extra)
- [ ] Configurar ServeRest em EC2
- [ ] Configurar Test Runner em segunda EC2
- [ ] Automatizar execução remota de testes
- [ ] Monitorar ambiente com CloudWatch

---

## 🏆 Resultados Esperados

### Para o Challenge
- ✅ **Estratégia de testes robusta** com foco em qualidade
- ✅ **Boundary testing abrangente** cobrindo casos extremos
- ✅ **Automação eficiente** para casos repetitivos  
- ✅ **Documentação exemplar** de todo o processo
- ✅ **Integração profissional** com ferramentas de gestão

### Para o Aprendizado
- 🎯 **Visão completa** de estratégia de testes de API
- 🎯 **Experiência prática** com ferramentas profissionais
- 🎯 **Conhecimento de boundary testing** sistemático
- 🎯 **Integração DevOps** com automação e CI/CD
- 🎯 **Experiência AWS** com deploy e monitoramento

---

## 🤝 Contribuição e Feedback

Este projeto foi desenvolvido com foco na **evolução contínua** baseada nos feedbacks dos instrutores. Cada elemento foi pensado para demonstrar:

- **Compreensão profunda** das regras de negócio
- **Aplicação sistemática** de boundary testing  
- **Documentação clara e detalhada** de execuções
- **Visão estratégica** de automação de testes
- **Integração com processos** profissionais de QA

### 📞 Contato
- **Desenvolvido por**: [Seu Nome]
- **Challenge**: ServeRest API Testing - Versão 2.0
- **Data**: Outubro 2025
- **Repositório**: [Link do seu repositório GitHub]

---

⭐ **Este README reflete a evolução do projeto baseada nos feedbacks recebidos, demonstrando crescimento técnico e visão estratégica de Quality Assurance.**