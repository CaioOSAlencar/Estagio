# Registro de Execução de Testes - Template

## 📋 Informações da Execução

| Campo | Valor |
|-------|--------|
| **Data/Hora Início** | ___/___/2025 às __:__ |
| **Data/Hora Fim** | ___/___/2025 às __:__ |
| **Executado por**: Caio Oliveira Silva Alencar |
| **Tipo de Execução** | ⬜ Smoke ⬜ Regressão ⬜ Boundary ⬜ Exploratório |
| **Ambiente** | ⬜ https://serverest.dev ⬜ Local ⬜ AWS |
| **Ferramenta** | ⬜ Postman ⬜ Newman ⬜ Robot Framework |
| **Versão API** | [Verificar na documentação] |

---

## 🎯 Objetivos da Execução

### Objetivo Principal
[Descrever o que se pretende validar nesta rodada de testes]

### Critérios de Sucesso
- [ ] Critério 1
- [ ] Critério 2
- [ ] Critério N

### Escopo Desta Execução
- ✅ **Incluído**: [Módulos/funcionalidades testadas]
- ❌ **Excluído**: [O que não foi testado nesta rodada]

---

## 📊 Resumo dos Resultados

### Estatísticas Gerais
| Métrica | Valor | Meta | Status |
|---------|-------|------|--------|
| **Total de Casos** | ___ | ___ | ⬜ ✅ ⬜ ❌ |
| **Casos Passou** | ___ | ___ | ⬜ ✅ ⬜ ❌ |
| **Casos Falharam** | ___ | ___ | ⬜ ✅ ⬜ ❌ |
| **Casos Bloqueados** | ___ | ___ | ⬜ ✅ ⬜ ❌ |
| **Taxa de Sucesso** | ___% | >95% | ⬜ ✅ ⬜ ❌ |
| **Tempo Total** | ___ min | <60min | ⬜ ✅ ⬜ ❌ |

### Resultados por Módulo
| Módulo | Total | Passou | Falhou | Bloqueado | Taxa Sucesso |
|--------|-------|--------|--------|-----------|--------------|
| **Login/Auth** | ___ | ___ | ___ | ___ | ___% |
| **Usuários** | ___ | ___ | ___ | ___ | ___% |
| **Produtos** | ___ | ___ | ___ | ___ | ___% |
| **Carrinho** | ___ | ___ | ___ | ___ | ___% |

---

## 📝 Detalhamento dos Testes

### ✅ Casos que PASSARAM
| ID | Nome do Teste | Observações |
|----|---------------|-------------|
| CT-001 | Login com credenciais válidas | [Comentários] |
| CT-XXX | [Nome] | [Comentários] |

### ❌ Casos que FALHARAM
| ID | Nome do Teste | Motivo da Falha | Bug ID | Severidade |
|----|---------------|-----------------|--------|------------|
| CT-XXX | [Nome] | [Descrição] | BUG-001 | 🔴 Alta |
| CT-YYY | [Nome] | [Descrição] | BUG-002 | 🟡 Média |

### ⚠️ Casos BLOQUEADOS
| ID | Nome do Teste | Motivo do Bloqueio | Ação Necessária |
|----|---------------|--------------------|------------------|
| CT-XXX | [Nome] | [Descrição] | [O que fazer] |

---

## 🐛 Defeitos Encontrados

### Bug #001 - [Título do Bug]
| Campo | Valor |
|-------|--------|
| **Severidade** | 🔴 Crítica / 🟠 Alta / 🟡 Média / 🔵 Baixa |
| **Prioridade** | 🔴 Urgente / 🟠 Alta / 🟡 Média / 🔵 Baixa |
| **Módulo** | [Login/Usuários/Produtos/Carrinho] |
| **Ambiente** | [URL do ambiente] |

**Descrição:**
[Descrição clara do problema encontrado]

**Passos para Reproduzir:**
1. [Passo 1]
2. [Passo 2]  
3. [Passo N]

**Resultado Esperado:**
[O que deveria acontecer]

**Resultado Atual:**
[O que realmente aconteceu]

**Evidências:**
- [ ] Screenshot/Print anexado
- [ ] Log de erro coletado
- [ ] Request/Response salvos
- [ ] Vídeo da reprodução (se aplicável)

**Impacto no Negócio:**
[Como este bug afeta o usuário final]

---

## 🔍 Testes de Limite (Boundary) Executados

### Validação de Campos
| Campo Testado | Valores Limite | Resultado | Observações |
|---------------|----------------|-----------|-------------|
| **Email** | a@b.c | ✅ Pass | Aceito corretamente |
| **Email** | emailsem@ | ❌ Fail | Erro adequado |
| **Nome** | "A" | ✅ Pass | Mínimo aceito |
| **Nome** | "A"*51 | ❌ Fail | Limite respeitado |
| **Preço** | 0.01 | ✅ Pass | Valor mínimo |
| **Preço** | -1 | ❌ Fail | Negativo rejeitado |

### Validação de Estoque
| Estoque Produto | Qtd Testada | Status Esperado | Resultado | OK? |
|-----------------|-------------|-----------------|-----------|-----|
| 5 | 4 | 201 Created | 201 | ✅ |
| 5 | 5 | 201 Created | 201 | ✅ |
| 5 | 6 | 400 Bad Request | 400 | ✅ |
| 0 | 1 | 400 Bad Request | 400 | ✅ |

---

## 🔄 Regras de Negócio Validadas

### ✅ Regras CONFIRMADAS
| ID | Regra de Negócio | Como Foi Validada |
|----|------------------|-------------------|
| RN-001 | Token expira em 600s | [Método usado] |
| RN-004 | Email único no sistema | [Como testado] |
| RN-014 | Validação de estoque | [Cenários testados] |

### ❌ Regras COM PROBLEMAS
| ID | Regra de Negócio | Problema Encontrado | Bug Relacionado |
|----|------------------|---------------------|-----------------|
| RN-XXX | [Regra] | [Problema] | BUG-XXX |

---

## 📈 Análise de Performance

### Tempos de Resposta
| Endpoint | Tempo Médio | Meta | Status |
|----------|-------------|------|--------|
| POST /login | ___ms | <2000ms | ⬜ ✅ ⬜ ❌ |
| GET /usuarios | ___ms | <1000ms | ⬜ ✅ ⬜ ❌ |
| POST /produtos | ___ms | <2000ms | ⬜ ✅ ⬜ ❌ |
| POST /carrinhos | ___ms | <2000ms | ⬜ ✅ ⬜ ❌ |

### Observações de Performance
[Comentários sobre lentidão, timeouts, etc.]

---

## 💡 Descobertas e Melhorias

### Descobertas Importantes
1. **[Descoberta 1]**: [Descrição e impacto]
2. **[Descoberta 2]**: [Descrição e impacto]

### Melhorias nos Testes
1. **[Melhoria 1]**: [O que pode ser otimizado]
2. **[Melhoria 2]**: [Nova abordagem sugerida]

### Candidatos à Automação
| Teste Manual | Motivo para Automatizar | Prioridade |
|--------------|-------------------------|------------|
| CT-XXX | [Motivo] | 🔴 Alta |
| CT-YYY | [Motivo] | 🟡 Média |

---

## 🎯 Próximos Passos

### Ações Imediatas
- [ ] [Ação 1 - Responsável - Prazo]
- [ ] [Ação 2 - Responsável - Prazo]

### Recomendações
1. **Para o Produto**: [Sugestões de melhoria]
2. **Para os Testes**: [Otimizações no processo]  
3. **Para a Automação**: [Próximos testes a automatizar]

### Próxima Execução
- **Data Planejada**: ___/___/2025
- **Foco**: [O que priorizar na próxima rodada]
- **Preparação Necessária**: [O que precisa estar pronto]

---

## 📎 Anexos e Evidências

### Arquivos Salvos
- [ ] Collection do Postman atualizada
- [ ] Screenshots das falhas
- [ ] Logs de erro detalhados
- [ ] Dados de teste utilizados
- [ ] Relatórios da ferramenta

### Localização dos Arquivos
**Pasta**: `manual-tests/evidence/YYYYMMDD_HHMM/`
**Conteúdo**:
- Screenshots/
- Logs/
- PostmanResults/
- TestData/

---

## ✍️ Assinaturas

| Papel | Nome | Data | Assinatura |
|-------|------|------|------------|
| **Executor** | Caio Oliveira Silva Alencar | ___/___/2025 | |
| **Revisor** | [Nome do Revisor] | ___/___/2025 | |
| **Aprovador** | [Nome do Aprovador] | ___/___/2025 | |

---

## 📝 Observações Finais
[Comentários gerais, contexto da execução, fatores externos que podem ter influenciado, etc.]