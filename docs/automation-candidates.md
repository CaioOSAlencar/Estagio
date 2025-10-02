# Critérios de Seleção para Automação

**Autor**: Caio Oliveira Silva Alencar  
**Data**: Outubro 2025  
**Versão**: 1.0

## 📋 Visão Geral

Este documento estabelece os critérios claros para determinar quais testes devem ser automatizados e quais devem permanecer manuais, baseado nas melhores práticas de QA e na análise do projeto ServeRest.

---

## ✅ **CRITÉRIOS PARA AUTOMAÇÃO**

### 1. **Estabilidade e Repetitividade**
- **✅ AUTOMATIZAR:** Testes que executam sempre da mesma forma
- **✅ AUTOMATIZAR:** Funcionalidades estáveis com poucas mudanças
- **✅ AUTOMATIZAR:** Casos de teste bem definidos e determinísticos

### 2. **Criticidade do Negócio**
- **✅ AUTOMATIZAR:** Funcionalidades críticas (login, compras)
- **✅ AUTOMATIZAR:** Fluxos principais do usuário (happy paths)
- **✅ AUTOMATIZAR:** Validações de segurança essenciais

### 3. **Frequência de Execução**
- **✅ AUTOMATIZAR:** Testes de regressão executados frequentemente
- **✅ AUTOMATIZAR:** Smoke tests diários
- **✅ AUTOMATIZAR:** Validações de build/deploy

### 4. **ROI (Return of Investment)**
- **✅ AUTOMATIZAR:** Testes que economizam tempo significativo
- **✅ AUTOMATIZAR:** Casos que reduzem erros humanos
- **✅ AUTOMATIZAR:** Testes com alta taxa de reutilização

---

## ❌ **CRITÉRIOS PARA MANTER MANUAL**

### 1. **Exploração e Descoberta**
- **❌ MANUAL:** Testes exploratórios
- **❌ MANUAL:** Validação de usabilidade/UX
- **❌ MANUAL:** Descoberta de novos cenários de erro

### 2. **Complexidade vs Benefício**
- **❌ MANUAL:** Testes muito complexos para automatizar
- **❌ MANUAL:** Casos edge muito específicos
- **❌ MANUAL:** Validações que mudam constantemente

### 3. **Interação Humana Necessária**
- **❌ MANUAL:** Validações visuais/estéticas
- **❌ MANUAL:** Testes de acessibilidade
- **❌ MANUAL:** Cenários que requerem julgamento humano

---

## 📊 **MATRIZ DE PRIORIZAÇÃO**

### **Prioridade 1 - Automatizar Primeiro**
| Teste | Criticidade | Estabilidade | Frequência | ROI |
|-------|-------------|--------------|------------|-----|
| Login com credenciais válidas | 🔴 Alta | 🟢 Alta | 🔴 Diário | 🟢 Alto |
| Cadastro de usuário | 🔴 Alta | 🟢 Alta | 🟡 Médio | 🟢 Alto |
| CRUD de produtos (admin) | 🔴 Alta | 🟢 Alta | 🟡 Médio | 🟢 Alto |
| Fluxo de compra completo | 🔴 Alta | 🟢 Alta | 🟡 Médio | 🟢 Alto |

### **Prioridade 2 - Automatizar Posteriormente**  
| Teste | Criticidade | Estabilidade | Frequência | ROI |
|-------|-------------|--------------|------------|-----|
| Validações de campos obrigatórios | 🟡 Média | 🟢 Alta | 🟡 Médio | 🟡 Médio |
| Testes de limite (boundary) | 🟡 Média | 🟢 Alta | 🔵 Baixo | 🟡 Médio |
| Gerenciamento de carrinho | 🟡 Média | 🟢 Alta | 🟡 Médio | 🟡 Médio |

### **Manter Manual**
| Teste | Motivo |
|-------|--------|
| Testes exploratórios | Requer criatividade humana |
| Validações de mensagens específicas | Podem mudar frequentemente |
| Cenários de erro muito específicos | ROI baixo para automação |

---

## 🤖 **TESTES SELECIONADOS PARA AUTOMAÇÃO**

### **MÓDULO: AUTENTICAÇÃO**
```gherkin
✅ Cenário: Login com credenciais válidas
✅ Cenário: Login com credenciais inválidas  
✅ Cenário: Login com campos obrigatórios vazios
✅ Cenário: Validação de expiração de token
❌ Cenário: Teste de diferentes provedores de email (exploratório)
```

### **MÓDULO: USUÁRIOS**
```gherkin
✅ Cenário: Cadastrar usuário com dados válidos
✅ Cenário: Cadastrar usuário com email duplicado
✅ Cenário: Atualizar usuário existente
✅ Cenário: Deletar usuário sem carrinho
✅ Cenário: Tentar deletar usuário com carrinho
✅ Cenário: Listar usuários
❌ Cenário: Validação de formatos específicos de email (manual)
```

### **MÓDULO: PRODUTOS**
```gherkin
✅ Cenário: Admin cadastra produto válido
✅ Cenário: Admin atualiza produto existente
✅ Cenário: Admin deleta produto sem vínculos
✅ Cenário: Usuário comum tenta cadastrar produto (403)
✅ Cenário: Cadastrar produto com nome duplicado
✅ Cenário: Listar produtos
❌ Cenário: Validações de conteúdo da descrição (manual)
```

### **MÓDULO: CARRINHO**
```gherkin
✅ Cenário: Adicionar produto válido ao carrinho
✅ Cenário: Tentar adicionar quantidade maior que estoque
✅ Cenário: Finalizar compra com sucesso
✅ Cenário: Cancelar compra
✅ Cenário: Verificar carrinho atual
❌ Cenário: Comportamentos em condições de rede instável (manual)
```

---

## 🛠️ **IMPLEMENTAÇÃO DA AUTOMAÇÃO**

### **Estrutura de Testes Automatizados**
```
automation/
├── robot-framework/
│   ├── tests/
│   │   ├── auth/           # Testes de autenticação
│   │   ├── users/          # Testes de usuários
│   │   ├── products/       # Testes de produtos
│   │   └── cart/           # Testes de carrinho
│   ├── resources/
│   │   ├── keywords/       # Keywords customizadas
│   │   ├── variables/      # Variáveis globais
│   │   └── libraries/      # Bibliotecas customizadas
│   └── results/           # Relatórios de execução
```

### **Ferramentas e Bibliotecas**
- **Robot Framework:** Framework principal
- **RequestsLibrary:** Para chamadas HTTP/REST
- **Collections:** Para manipulação de dados
- **OperatingSystem:** Para operações do sistema
- **DateTime:** Para validações de tempo

### **Padrões de Implementação**
1. **Page Object Model adaptado** para APIs (Service Object)
2. **Data-driven testing** para cenários com múltiplos dados
3. **Keywords reutilizáveis** para ações comuns
4. **Setup/Teardown** consistentes para preparação/limpeza

---

## 📈 **MÉTRICAS DE AUTOMAÇÃO**

### **Metas do Projeto**
- **Cobertura:** 70% dos testes críticos automatizados
- **Execução:** Suite completa em < 10 minutos
- **Manutenção:** < 20% do tempo gasto em manutenção
- **Estabilidade:** < 5% de falsos positivos

### **KPIs a Acompanhar**
1. **% de testes automatizados** por módulo
2. **Tempo de execução** da suite automatizada
3. **Taxa de sucesso** dos testes automatizados
4. **Tempo economizado** vs execução manual
5. **Bugs encontrados** por automação vs manual

---

## 🔄 **PROCESSO DE REVISÃO**

### **Revisão Mensal**
- Avaliar eficácia dos testes automatizados
- Identificar novos candidatos à automação
- Otimizar testes existentes
- Atualizar critérios baseados em aprendizados

### **Critérios de Reavaliação**
- **Promover para automação:** Testes manuais executados > 5x/mês
- **Manter manual:** Testes automatizados com > 30% falsos positivos
- **Descontinuar:** Testes que não encontram bugs há > 6 meses

---

## 📋 **CHECKLIST DE IMPLEMENTAÇÃO**

### **Antes de Automatizar:**
- [ ] Teste é estável e bem documentado?
- [ ] Será executado frequentemente?
- [ ] ROI justifica o esforço?
- [ ] Dados de teste estão disponíveis?
- [ ] Ambiente é confiável?

### **Durante a Implementação:**
- [ ] Keywords são reutilizáveis?
- [ ] Dados são parametrizáveis?
- [ ] Logs são informativos?
- [ ] Cleanup é realizado?
- [ ] Documentação está atualizada?

### **Após Implementação:**
- [ ] Teste passou em múltiplas execuções?
- [ ] Falsos positivos foram eliminados?
- [ ] Tempo de execução é aceitável?
- [ ] Manutenção é simples?
- [ ] Equipe foi treinada?

---

## 🎯 **ROADMAP DE AUTOMAÇÃO**

### **Sprint 1 (Semana 1-2)**
- Setup do ambiente Robot Framework
- Automação módulo de Autenticação
- Keywords base e estrutura de dados

### **Sprint 2 (Semana 3-4)**  
- Automação módulo de Usuários
- Implementação de data-driven tests
- Configuração de relatórios

### **Sprint 3 (Semana 5-6)**
- Automação módulo de Produtos
- Testes de integração entre módulos
- Otimização de performance

### **Sprint 4 (Semana 7-8)**
- Automação módulo de Carrinho
- Suite completa de regressão
- Integração com CI/CD