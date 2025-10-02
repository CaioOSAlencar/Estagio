# Plano de Testes Detalhado - ServeRest API

## 📋 Informações Gerais

| **Campo** | **Valor** |
|-----------|-----------|
| **Projeto** | Challenge ServeRest - Testes API |
| **Versão** | 2.0 (Baseado nos feedbacks dos instrutores) |
| **Responsável** | Caio Oliveira Silva Alencar |
| **Data** | Outubro 2025 |
| **Ambiente** | https://serverest.dev |
| **Ferramenta Manual** | Postman + Newman |
| **Ferramenta Automação** | Robot Framework |

---

## 🎯 Objetivos do Teste

### Objetivo Principal
Validar a funcionalidade completa da API ServeRest, com foco especial em:
- **Regras de negócio** detalhadas e específicas
- **Testes de limite (boundary testing)** abrangentes  
- **Documentação clara** de todas as execuções
- **Cobertura de cenários críticos** e edge cases

### Objetivos Específicos
1. ✅ Verificar conformidade com especificações da API
2. ✅ Validar regras de negócio identificadas
3. ✅ Testar limites e comportamentos extremos
4. ✅ Garantir segurança e autorização
5. ✅ Preparar suite automatizada para regressão

---

## 📊 Escopo de Testes

### **Funcionalidades Incluídas**
- 🔐 **Autenticação e Login**
- 👤 **Gerenciamento de Usuários** (CRUD completo)
- 🛒 **Gerenciamento de Produtos** (CRUD completo) 
- 🛍️ **Carrinho de Compras** (Operações completas)

### **Funcionalidades Excluídas**
- ❌ Testes de interface (front-end)
- ❌ Testes de performance detalhados
- ❌ Testes de carga/stress
- ❌ Funcionalidades não documentadas

---

## 🧪 Tipos de Teste

### **1. Testes Funcionais**
- Casos de sucesso (happy path)
- Casos de erro esperados
- Validação de dados de entrada/saída
- Fluxos de integração

### **2. Testes de Limite (Boundary)**
- Valores mínimos e máximos
- Limites de campos de texto
- Valores monetários extremos
- Timeouts e expiração

### **3. Testes de Segurança**
- Autenticação e autorização
- Validação de tokens JWT
- Controle de acesso por perfil
- Injeção básica de dados

### **4. Testes de Integração**
- Fluxos end-to-end
- Consistência entre módulos
- Estado da aplicação

---

## 📝 Casos de Teste Detalhados

## 🔐 **MÓDULO: AUTENTICAÇÃO**

### **CT-001: Login com Credenciais Válidas**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Funcional |
| **Automação** | ✅ Sim |

**Pré-condições:**
- Usuário deve estar cadastrado no sistema
- API deve estar disponível

**Passos:**
1. Enviar POST para `/login`
2. Body: `{"email": "usuario@exemplo.com", "password": "123456"}`
3. Verificar resposta

**Resultado Esperado:**
- Status: 200 OK
- Body contém: `message` e `authorization`
- Token JWT válido no campo `authorization`
- Token inicia com "Bearer "

**Dados de Teste:**
```json
{
  "email": "atreus@exemplo.com",
  "password": "123456"
}
```

---

### **CT-002: Login com Credenciais Inválidas**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Funcional |
| **Automação** | ✅ Sim |

**Variações:**
- Email válido + senha inválida
- Email inválido + senha válida  
- Ambos inválidos
- Usuário inexistente

**Resultado Esperado:**
- Status: 401 Unauthorized
- Message: "Email e/ou senha inválidos"

---

### **CT-003: Validação de Campos Obrigatórios**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Média |
| **Tipo** | Boundary |
| **Automação** | ✅ Sim |

**Cenários de Teste:**
1. **Email vazio**: `{"email": "", "password": "123456"}`
2. **Password vazio**: `{"email": "test@test.com", "password": ""}`
3. **Ambos vazios**: `{}`
4. **JSON malformado**

**Resultado Esperado:**
- Status: 400 Bad Request
- Mensagens específicas para cada campo

---

### **CT-004: Expiração de Token (Boundary)**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Boundary |
| **Automação** | ✅ Sim |

**Cenários:**
1. **Token válido (< 600s)**: Usar imediatamente
2. **Token no limite (≈ 600s)**: Aguardar 599s
3. **Token expirado (> 600s)**: Aguardar 601s

**Resultado Esperado:**
- < 600s: Acesso permitido
- > 600s: Status 401 "Token expirado"

---

## 👤 **MÓDULO: USUÁRIOS**

### **CT-005: Cadastrar Usuário com Dados Válidos**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Funcional |
| **Automação** | ✅ Sim |

**Dados de Teste:**
```json
{
  "nome": "João Silva",
  "email": "joao@exemplo.com",
  "password": "123456",
  "administrador": "false"
}
```

**Resultado Esperado:**
- Status: 201 Created
- Response contém `_id` do usuário criado
- Message: "Cadastro realizado com sucesso"

---

### **CT-006: Email Duplicado**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Funcional |
| **Automação** | ✅ Sim |

**Passos:**
1. Cadastrar usuário com email único
2. Tentar cadastrar outro usuário com mesmo email

**Resultado Esperado:**
- Status: 400 Bad Request
- Message: "Este email já está sendo usado"

---

### **CT-007: Boundary Testing - Campos de Usuário**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Média |
| **Tipo** | Boundary |
| **Automação** | ⚠️ Parcial |

**Cenários:**

**Nome:**
- 1 caractere: `"A"`
- 50 caracteres: `"A" * 50`
- 51 caracteres: `"A" * 51` (pode falhar)
- String vazia: `""`

**Email:**
- Formato válido: `"test@domain.com"`
- Sem @: `"testdomain.com"`
- Sem domínio: `"test@"`
- Caracteres especiais: `"test+1@domain-test.com"`

**Password:**
- 1 caractere: `"1"`
- String muito longa: `"1" * 1000`

---

### **CT-008: Atualização por ID Inexistente**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Média |
| **Tipo** | Funcional |
| **Automação** | ✅ Sim |

**Cenário:**
1. Fazer PUT `/usuarios/{id_inexistente}` com dados válidos

**Resultado Esperado:**
- Status: 201 Created (não 200!)
- Novo usuário é criado
- Response contém novo `_id`

---

### **CT-009: Exclusão de Usuário com Carrinho**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Funcional |
| **Automação** | ✅ Sim |

**Setup:**
1. Criar usuário
2. Fazer login
3. Adicionar produto ao carrinho
4. Tentar excluir usuário

**Resultado Esperado:**
- Status: 400 Bad Request
- Message: "Não é permitido excluir usuário com carrinho cadastrado"
- Response contém `idCarrinho`

---

## 🛒 **MÓDULO: PRODUTOS**

### **CT-010: Admin Cadastra Produto Válido**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Funcional |
| **Automação** | ✅ Sim |

**Pré-condições:**
- Token de usuário administrador

**Dados de Teste:**
```json
{
  "nome": "Notebook Dell",
  "preco": 2500,
  "descricao": "Notebook para desenvolvimento",
  "quantidade": 10
}
```

**Resultado Esperado:**
- Status: 201 Created
- Response contém `_id` do produto

---

### **CT-011: Usuário Comum Tenta Cadastrar Produto**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Segurança |
| **Automação** | ✅ Sim |

**Cenário:**
1. Login como usuário comum (administrador: "false")
2. Tentar POST `/produtos`

**Resultado Esperado:**
- Status: 403 Forbidden
- Message sobre falta de permissão

---

### **CT-012: Boundary Testing - Dados de Produto**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Média |
| **Tipo** | Boundary |
| **Automação** | ⚠️ Parcial |

**Preço:**
- Zero: `0`
- Mínimo: `0.01`
- Negativo: `-1`
- Muito grande: `999999999`

**Quantidade:**
- Zero: `0`
- Um: `1`
- Máximo inteiro: `2147483647`

---

### **CT-013: Nome de Produto Duplicado**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Funcional |
| **Automação** | ✅ Sim |

**Passos:**
1. Admin cadastra produto com nome "Produto A"
2. Admin tenta cadastrar outro produto com nome "Produto A"

**Resultado Esperado:**
- Status: 400 Bad Request
- Message sobre nome já utilizado

---

## 🛍️ **MÓDULO: CARRINHO**

### **CT-014: Adicionar Produto Válido ao Carrinho**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Funcional |
| **Automação** | ✅ Sim |

**Pré-condições:**
- Usuário logado
- Produto existente com estoque > 0

**Dados de Teste:**
```json
{
  "produtos": [
    {
      "idProduto": "{produto_id}",
      "quantidade": 2
    }
  ]
}
```

**Resultado Esperado:**
- Status: 201 Created
- Carrinho criado com produtos
- Estoque é reservado (não reduzido ainda)

---

### **CT-015: Quantidade Maior que Estoque**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Boundary |
| **Automação** | ✅ Sim |

**Cenários:**
- Produto tem estoque 5, tentar adicionar 6
- Produto tem estoque 0, tentar adicionar 1

**Resultado Esperado:**
- Status: 400 Bad Request
- Message sobre estoque insuficiente

---

### **CT-016: Finalizar Compra**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Integração |
| **Automação** | ✅ Sim |

**Fluxo:**
1. Adicionar produtos ao carrinho
2. Verificar estoque inicial
3. Finalizar compra (DELETE `/carrinhos/concluir-compra`)
4. Verificar estoque após finalização

**Validações:**
- Status: 200 OK
- Estoque foi reduzido
- Carrinho foi removido

---

### **CT-017: Cancelar Compra**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Integração |
| **Automação** | ✅ Sim |

**Fluxo:**
1. Adicionar produtos ao carrinho
2. Verificar estoque inicial  
3. Cancelar compra (DELETE `/carrinhos/cancelar-compra`)
4. Verificar estoque após cancelamento

**Validações:**
- Status: 200 OK
- Estoque foi reabastecido
- Carrinho foi removido

---

## 📋 **CASOS DE TESTE DE INTEGRAÇÃO**

### **CT-018: Fluxo de Compra Completo**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Crítica |
| **Tipo** | End-to-End |
| **Automação** | ✅ Sim |

**Fluxo Completo:**
1. Cadastrar usuário comum
2. Admin cadastra produtos
3. Usuário faz login
4. Usuário busca produtos
5. Adiciona produtos ao carrinho
6. Finaliza compra
7. Verificar todas as alterações de estado

**Validações Múltiplas:**
- Cada passo retorna sucesso
- Estados são mantidos corretamente
- Não há vazamentos de dados

---

### **CT-019: Tentativas de Acesso Não Autorizado**
| Campo | Valor |
|-------|--------|
| **Prioridade** | Alta |
| **Tipo** | Segurança |
| **Automação** | ✅ Sim |

**Cenários:**
1. Acessar endpoints sem token
2. Usar token expirado
3. Usar token de usuário comum em operações admin
4. Tentar manipular dados de outros usuários

---

## 📊 Estratégia de Execução

### **Rodadas de Teste**

#### **Smoke Tests (Diário)**
- CT-001: Login válido
- CT-005: Cadastrar usuário
- CT-010: Cadastrar produto (admin)
- CT-014: Adicionar ao carrinho

#### **Regression Tests (Semanal)**
- Todos os casos automatizados
- Validação de funcionalidades críticas
- Testes de integração

#### **Boundary Tests (Quinzenal)**
- Todos os CT com tipo "Boundary"
- Casos extremos e limites
- Validação de robustez

#### **Manual Exploratory (Mensal)**
- Cenários não cobertos pela automação
- Novos fluxos descobertos
- Validação de usabilidade da API

---

## 🎯 Critérios de Aceitação

### **Critérios de Sucesso**
- ✅ 100% dos testes críticos passando
- ✅ ≥ 95% dos testes funcionais passando
- ✅ ≥ 90% dos boundary tests passando
- ✅ 0 falhas de segurança críticas

### **Critérios de Qualidade**
- ✅ Tempo de resposta < 2s (95% das requisições)
- ✅ Mensagens de erro claras e consistentes
- ✅ Documentação de execução completa
- ✅ Evidências organizadas

---

## 📈 Métricas e Relatórios

### **Métricas de Execução**
- Taxa de sucesso por módulo
- Tempo médio de execução
- Cobertura de casos de teste
- Bugs encontrados por severidade

### **Relatórios**
- **Diário:** Status dos smoke tests
- **Semanal:** Relatório de regressão completo
- **Mensal:** Análise de tendências e melhorias

---

## 🔧 Ambiente e Ferramentas

### **Ambiente de Teste**
- **URL Base:** `https://serverest.dev`
- **Backup:** Ambiente local Docker (se necessário)

### **Ferramentas**
- **Manual:** Postman + Newman CLI
- **Automação:** Robot Framework + RequestsLibrary
- **CI/CD:** GitHub Actions (futuro)
- **Relatórios:** Robot Framework Reports + Allure

### **Dados de Teste**
- Usuários pré-cadastrados para cenários específicos
- Produtos de teste com diferentes características
- Massa de dados para boundary tests

---

## 📅 Cronograma

| Semana | Atividade | Entregável |
|--------|-----------|------------|
| 1 | Execução manual completa | Evidências + bugs |
| 2 | Implementação automação (Auth + Users) | Testes automatizados |
| 3 | Implementação automação (Products + Cart) | Suite completa |
| 4 | Integração CI/CD + Documentação final | Pipeline automatizado |

---

## ✅ Checklist de Execução

### **Antes da Execução**
- [ ] Ambiente está disponível?
- [ ] Dados de teste preparados?
- [ ] Ferramentas configuradas?
- [ ] Casos de teste revisados?

### **Durante a Execução**
- [ ] Evidências sendo coletadas?
- [ ] Bugs sendo documentados?
- [ ] Tempo sendo registrado?
- [ ] Critérios sendo verificados?

### **Após a Execução**
- [ ] Resultados analisados?
- [ ] Relatório gerado?
- [ ] Bugs reportados?
- [ ] Lições aprendidas documentadas?