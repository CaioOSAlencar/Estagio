# Regras de Negócio - ServeRest API

**Autor**: Caio Oliveira Silva Alencar  
**Data**: Outubro 2025  
**Versão**: 1.0

## 📋 Introdução

Este documento detalha as regras de negócio identificadas na API ServeRest, organizadas por módulo. O foco está em regras que impactam diretamente os testes e validações necessárias.

---

## 🔐 **MÓDULO: AUTENTICAÇÃO**

### RN-001: Duração do Token
- **Regra:** Token JWT válido por exatamente 600 segundos (10 minutos)
- **Comportamento:** Após expiração, retorna HTTP 401
- **Testes Necessários:**
  - ✅ Uso de token dentro do prazo (< 600s)
  - ✅ Uso de token expirado (> 600s)
  - ✅ Boundary: exatamente 600s

### RN-002: Validação de Credenciais
- **Regra:** Email e senha devem corresponder a usuário cadastrado
- **Comportamento:** Falha retorna HTTP 401 com mensagem "Email e/ou senha inválidos"
- **Testes Necessários:**
  - ✅ Email válido + senha inválida
  - ✅ Email inválido + senha válida
  - ✅ Ambos inválidos
  - ✅ Usuario inexistente

### RN-003: Campos Obrigatórios
- **Regra:** Email e password são obrigatórios
- **Comportamento:** Campos vazios retornam HTTP 400 com detalhes específicos
- **Testes Necessários:**
  - ✅ Email vazio
  - ✅ Password vazio
  - ✅ Ambos vazios
  - ✅ JSON malformado

---

## 👤 **MÓDULO: USUÁRIOS**

### RN-004: Unicidade de Email
- **Regra:** Cada email pode estar associado a apenas um usuário
- **Comportamento:** Tentativa de duplicação retorna HTTP 400
- **Testes Necessários:**
  - ✅ Cadastro com email existente
  - ✅ Atualização para email existente
  - ✅ Case sensitivity do email
  - ✅ Emails com espaços

### RN-005: Administrador Flag
- **Regra:** Campo "administrador" aceita apenas "true" ou "false" (string)
- **Comportamento:** Determina permissões do usuário
- **Testes Necessários:**
  - ✅ Valores válidos: "true", "false"  
  - ✅ Valores inválidos: true (boolean), "sim", "não", null
  - ✅ Boundary: case sensitivity

### RN-006: Atualização por ID Inexistente
- **Regra:** PUT com ID inexistente cria novo usuário (HTTP 201)
- **Comportamento:** Sistema trata como cadastro novo
- **Testes Necessários:**
  - ✅ ID totalmente inexistente
  - ✅ ID com formato inválido
  - ✅ Verificação do novo ID gerado

### RN-007: Exclusão com Carrinho
- **Regra:** Usuários com carrinho ativo não podem ser excluídos
- **Comportamento:** HTTP 400 com ID do carrinho
- **Testes Necessários:**
  - ✅ Exclusão com carrinho ativo
  - ✅ Exclusão após finalizar compra
  - ✅ Exclusão após cancelar carrinho

### RN-008: Campos Obrigatórios de Usuário
- **Regra:** nome, email, password e administrador são obrigatórios
- **Comportamento:** HTTP 400 com detalhes dos campos faltantes
- **Testes de Limite:**
  - ✅ Nome: 1 char, 50 chars, 51+ chars
  - ✅ Email: formatos válidos/inválidos
  - ✅ Password: comprimentos mínimo/máximo

---

## 🛒 **MÓDULO: PRODUTOS**

### RN-009: Permissão de Administrador
- **Regra:** Apenas administradores podem criar, editar e excluir produtos
- **Comportamento:** Usuários comuns recebem HTTP 403
- **Testes Necessários:**
  - ✅ CRUD com token de admin
  - ✅ CRUD com token de usuário comum
  - ✅ CRUD sem token

### RN-010: Unicidade do Nome do Produto
- **Regra:** Nomes de produtos devem ser únicos no sistema
- **Comportamento:** Duplicação retorna HTTP 400
- **Testes Necessários:**
  - ✅ Cadastro com nome duplicado
  - ✅ Atualização para nome existente
  - ✅ Case sensitivity

### RN-011: Validação de Dados do Produto
- **Regra:** nome, preco, descricao e quantidade são obrigatórios
- **Comportamento:** HTTP 400 para campos faltantes ou inválidos
- **Testes de Limite:**
  - ✅ Preço: 0, 0.01, negativo, muito grande
  - ✅ Quantidade: 0, 1, máximo inteiro
  - ✅ Nome/Descrição: strings vazias, muito longas

### RN-012: Exclusão de Produto em Carrinho
- **Regra:** Produtos que estão em carrinho não podem ser excluídos
- **Comportamento:** HTTP 400 com informações do carrinho
- **Testes Necessários:**
  - ✅ Exclusão com produto no carrinho
  - ✅ Exclusão após remover do carrinho
  - ✅ Exclusão após finalizar compra

---

## 🛍️ **MÓDULO: CARRINHO**

### RN-013: Um Carrinho por Usuário
- **Regra:** Cada usuário pode ter no máximo um carrinho ativo
- **Comportamento:** Novo carrinho sobrescreve o anterior
- **Testes Necessários:**
  - ✅ Criação de segundo carrinho
  - ✅ Verificação de sobrescrita
  - ✅ Estado do carrinho anterior

### RN-014: Validação de Estoque
- **Regra:** Não é possível adicionar quantidade maior que estoque disponível
- **Comportamento:** HTTP 400 com mensagem específica
- **Testes de Limite:**
  - ✅ Quantidade = estoque
  - ✅ Quantidade = estoque + 1
  - ✅ Quantidade muito maior que estoque
  - ✅ Estoque = 0

### RN-015: Autenticação Obrigatória
- **Regra:** Todas as operações de carrinho requerem token válido
- **Comportamento:** HTTP 401 para token inválido/expirado
- **Testes Necessários:**
  - ✅ Operações sem token
  - ✅ Token inválido
  - ✅ Token expirado

### RN-016: Finalização de Compra
- **Regra:** Finalizar compra reduz estoque e remove carrinho
- **Comportamento:** HTTP 200 com mensagem de sucesso
- **Testes Necessários:**
  - ✅ Verificação de redução de estoque
  - ✅ Remoção do carrinho
  - ✅ Impossibilidade de finalizar carrinho vazio

### RN-017: Cancelamento de Compra
- **Regra:** Cancelar compra reabastece estoque e remove carrinho
- **Comportamento:** HTTP 200 com reabastecimento
- **Testes Necessários:**
  - ✅ Verificação de reabastecimento
  - ✅ Remoção do carrinho
  - ✅ Cancelamento de carrinho inexistente

### RN-018: Validação de Produtos
- **Regra:** Produtos adicionados ao carrinho devem existir
- **Comportamento:** HTTP 400 para produtos inexistentes
- **Testes Necessários:**
  - ✅ Produto inexistente
  - ✅ ID de produto inválido
  - ✅ Produto excluído após adição ao carrinho

---

## 🔍 **REGRAS TRANSVERSAIS**

### RN-019: Formato de Resposta
- **Regra:** Todas as respostas seguem padrão JSON
- **Comportamento:** Content-Type: application/json
- **Validações:**
  - ✅ Estrutura JSON válida
  - ✅ Headers corretos
  - ✅ Encoding UTF-8

### RN-020: Códigos de Status HTTP
- **Regra:** Uso padronizado de status codes
- **Padrões:**
  - 200: Sucesso
  - 201: Criação
  - 400: Erro de validação
  - 401: Não autenticado
  - 403: Não autorizado
  - 404: Não encontrado

### RN-021: Rate Limiting (Implícito)
- **Regra:** Sistema pode ter limitações de taxa
- **Comportamento:** Possível HTTP 429 em excesso de requisições
- **Testes Necessários:**
  - ✅ Múltiplas requisições simultâneas
  - ✅ Comportamento sob carga

### RN-022: Validação de JSON
- **Regra:** Payloads devem ser JSON válidos
- **Comportamento:** HTTP 400 para JSON malformado
- **Testes Necessários:**
  - ✅ JSON inválido
  - ✅ Campos extras não documentados
  - ✅ Tipos de dados incorretos

---

## 📊 **MATRIZ DE PRIORIZAÇÃO**

| Regra | Criticidade | Complexidade | Automação |
|-------|-------------|--------------|-----------|
| RN-001 | Alta | Baixa | ✅ Sim |
| RN-002 | Alta | Baixa | ✅ Sim |
| RN-004 | Alta | Média | ✅ Sim |
| RN-007 | Alta | Alta | ✅ Sim |
| RN-009 | Alta | Média | ✅ Sim |
| RN-013 | Média | Alta | ✅ Sim |
| RN-014 | Alta | Alta | ✅ Sim |
| RN-016 | Alta | Alta | ✅ Sim |
| RN-017 | Alta | Alta | ✅ Sim |

## 🎯 **CENÁRIOS DE TESTE DERIVADOS**

### Fluxos de Integração Críticos:
1. **Fluxo de Compra Completo**
   - Login → Buscar produtos → Adicionar ao carrinho → Finalizar compra
   
2. **Fluxo de Administração**
   - Login admin → Cadastrar produto → Gerenciar estoque → Monitorar vendas

3. **Fluxos de Erro**
   - Tentativas de acesso não autorizado
   - Operações com dados inválidos
   - Recuperação de erros temporários