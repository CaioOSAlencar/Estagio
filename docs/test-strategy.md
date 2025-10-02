# Estratégia de Testes - ServeRest API

**Autor**: Caio Oliveira Silva Alencar  
**Data**: Outubro 2025  
**Versão**: 1.0

## 1. Visão Geral

Esta estratégia de testes foi desenvolvida considerando os feedbacks dos instrutores, com foco especial em:
- **Regras de negócio** mais detalhadas
- **Testes de limite (boundary testing)**
- **Documentação clara das execuções**

## 2. Escopo de Testes

### 2.1 Funcionalidades Cobertas

#### 🔐 **Autenticação e Login**
- **Regras de Negócio:**
  - Token JWT válido por 600 segundos (10 minutos)
  - Autenticação necessária para operações protegidas
  - Validação de formato de email
  - Controle de provedores de email permitidos

#### 👤 **Gerenciamento de Usuários**
- **Regras de Negócio:**
  - Email deve ser único no sistema
  - Campo "administrador" define permissões
  - Usuários com carrinho não podem ser excluídos
  - Atualização por ID inexistente cria novo usuário

#### 🛒 **Gerenciamento de Produtos**
- **Regras de Negócio:**
  - Nome do produto deve ser único
  - Apenas administradores podem gerenciar produtos
  - Controle de estoque obrigatório
  - Produtos em carrinho não podem ser excluídos

#### 🛍️ **Carrinho de Compras**
- **Regras de Negócio:**
  - Um usuário pode ter apenas um carrinho
  - Verificação de estoque antes da adição
  - Finalização de compra reduz estoque
  - Cancelamento reabastece estoque

## 3. Tipos de Teste

### 3.1 Testes Funcionais
- ✅ Casos de sucesso (happy path)
- ✅ Casos de erro esperados
- ✅ Validação de regras de negócio
- ✅ Fluxos de integração entre módulos

### 3.2 Testes de Limite (Boundary Testing)
- **Campos de Texto:**
  - Nome: 1 caracter, 50 caracteres, 51 caracteres
  - Email: Formatos válidos e inválidos
  - Senha: Comprimento mínimo/máximo

- **Valores Numéricos:**
  - Preço: 0.01, valores negativos, muito grandes
  - Quantidade: 0, 1, valores máximos de estoque

- **Limites de Sistema:**
  - Timeout de token (599s, 600s, 601s)
  - Número máximo de produtos no carrinho
  - Tamanho máximo de payload

### 3.3 Testes de Segurança
- Validação de token JWT
- Autorização por perfil (admin vs usuário comum)
- Injeção de código em campos
- Acesso não autorizado a endpoints

### 3.4 Testes de Performance (Básico)
- Tempo de resposta dos endpoints
- Comportamento com múltiplas requisições simultâneas
- Validação de timeouts

## 4. Critérios de Aceitação

### 4.1 Critérios Funcionais
- ✅ Todos os endpoints respondem conforme documentação
- ✅ Regras de negócio são respeitadas
- ✅ Mensagens de erro são claras e consistentes
- ✅ Estados da aplicação são mantidos corretamente

### 4.2 Critérios de Qualidade
- ✅ Tempo de resposta < 2 segundos (95% das requisições)
- ✅ Status codes HTTP apropriados
- ✅ Estrutura JSON consistente
- ✅ Validações de entrada funcionando

## 5. Ambientes de Teste

### 5.1 Ambiente Local
- **URL Base:** `http://localhost:3000`
- **Uso:** Desenvolvimento e testes iniciais

### 5.2 Ambiente Oficial
- **URL Base:** `https://serverest.dev`
- **Uso:** Testes de integração e validação final

### 5.3 Ambiente AWS (Extra)
- **URL Base:** A definir após deploy
- **Uso:** Simulação de ambiente produtivo

## 6. Dados de Teste

### 6.1 Usuários de Teste
```json
{
  "admin_user": {
    "nome": "Administrador Teste",
    "email": "admin@exemplo.com",
    "password": "123456",
    "administrador": "true"
  },
  "regular_user": {
    "nome": "Usuario Regular",
    "email": "user@exemplo.com", 
    "password": "123456",
    "administrador": "false"
  }
}
```

### 6.2 Produtos de Teste
```json
{
  "produto_valido": {
    "nome": "Produto Teste",
    "preco": 100,
    "descricao": "Descrição do produto teste",
    "quantidade": 50
  },
  "produto_boundary": {
    "nome": "A",
    "preco": 0.01,
    "descricao": "",
    "quantidade": 1
  }
}
```

## 7. Ferramentas

### 7.1 Testes Manuais
- **Postman:** Execução de casos de teste
- **Newman:** Execução automatizada das collections
- **Jira + QALity:** Gestão e rastreamento

### 7.2 Testes Automatizados
- **Robot Framework:** Framework principal
- **RequestsLibrary:** Biblioteca para APIs REST
- **DatabaseLibrary:** Validações de dados (se necessário)

## 8. Estratégia de Execução

### 8.1 Rodadas de Teste
1. **Smoke Tests:** Funcionalidades críticas
2. **Regression Tests:** Suite completa
3. **Boundary Tests:** Testes de limite específicos
4. **Integration Tests:** Fluxos end-to-end

### 8.2 Frequência
- **Diário:** Smoke tests automatizados
- **Semanal:** Regression completa
- **Por demanda:** Testes específicos após mudanças

## 9. Critérios de Automação

### 9.1 Candidatos Prioritários
- ✅ Testes repetitivos e estáveis
- ✅ Casos de sucesso principais
- ✅ Validações de regras de negócio críticas
- ✅ Testes de regressão

### 9.2 Mantidos Manuais
- ❌ Testes exploratórios
- ❌ Validações visuais/UX
- ❌ Casos edge muito específicos
- ❌ Testes que requerem interação humana

## 10. Métricas e KPIs

### 10.1 Cobertura de Testes
- % de endpoints cobertos
- % de regras de negócio validadas
- % de cenários de erro testados

### 10.2 Qualidade de Execução
- Taxa de sucesso dos testes
- Tempo médio de execução
- Número de bugs encontrados por severidade

### 10.3 Automação
- % de testes automatizados
- Tempo economizado vs testes manuais
- Estabilidade dos testes automatizados