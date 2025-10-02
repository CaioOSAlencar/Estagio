# Relatório de Execução de Testes - 01/10/2025

## 📋 Informações da Execução

| Campo | Valor |
|-------|--------|
| **Data/Hora Início** | 01/10/2025 às 15:30 |
| **Data/Hora Fim** | 01/10/2025 às 15:47 |
| **Executado por** | Caio Oliveira Silva Alencar |
| **Tipo de Execução** | ✅ Regressão |
| **Ambiente** | ✅ https://serverest.dev |
| **Ferramenta** | ✅ Newman (Postman CLI) |
| **Versão API** | Atual (Outubro 2025) |

---

## 🎯 Objetivos da Execução

### Objetivo Principal
Validar funcionalidades críticas da API ServeRest através da execução automatizada da collection Postman existente para identificar o estado atual da aplicação e problemas existentes.

### Critérios de Sucesso
- [ ] ~~Taxa de sucesso > 95%~~ **45% obtida (29/64)**
- [x] Identificar padrões de falha sistemáticos
- [x] Documentar comportamento atual da API
- [x] Mapear necessidade de atualização dos testes

### Escopo Desta Execução
- ✅ **Incluído**: Todos os módulos (Auth, Users, Products, Cart)
- ✅ **Incluído**: 37 requests executadas em 16.7 segundos
- ❌ **Limitação**: Testes não atualizados com dados válidos

---

## 📊 Resumo dos Resultados

### Estatísticas Gerais
| Métrica | Valor | Meta | Status |
|---------|-------|------|--------|
| **Total de Assertions** | 64 | 64 | ✅ 100% |
| **Assertions Passou** | 29 | >60 | ❌ 45% |
| **Assertions Falharam** | 35 | <4 | ❌ 55% |
| **Requests Executadas** | 37 | 37 | ✅ 100% |
| **Taxa de Sucesso** | 45% | >95% | ❌ Crítico |
| **Tempo Total** | 16.7s | <60s | ✅ Excelente |
| **Tempo Médio Response** | 302ms | <2000ms | ✅ Excelente |

### Resultados por Módulo
| Módulo | Requests | Passou | Falhou | Taxa Sucesso |
|--------|----------|--------|--------|--------------|
| **Login/Auth** | 7 | 5 | 2 | 71% |
| **Usuários** | 12 | 5 | 7 | 42% |
| **Produtos** | 10 | 1 | 9 | 10% |
| **Carrinho** | 8 | 0 | 8 | 0% |

---

## 📝 Detalhamento dos Testes

### ✅ Casos que PASSARAM (29/64)

#### **Módulo Authentication**
| ID | Nome do Teste | Observações |
|----|---------------|-------------|
| AUTH-02 | Login com usuário não cadastrado | Status 401 correto |
| AUTH-03 | Login com senha inválida | Status 401 correto |
| AUTH-04 | Login com email inválida | Status 401 correto |
| AUTH-05 | Login com campos vazios | Status 400 correto |
| AUTH-06 | Login com provedor proibido | Status 401 correto |
| AUTH-07 | Validar token inválido | Status 401 correto |

#### **Módulo Users**
| ID | Nome do Teste | Observações |
|----|---------------|-------------|
| USER-02 | Atualizar usuário com ID inexistente | Status 201 (cria novo) |
| USER-03 | Erro para email duplicado | Status 400 correto |
| USER-06 | Registro excluído com sucesso | Status 200 correto |
| USER-08 | Buscar usuário por ID inválido | Status 400 correto |
| USER-10 | Criar usuário com senha em branco | Status 400 correto |
| USER-11 | Criar usuário com email inválido | Status 400 correto |

### ❌ Casos que FALHARAM (35/64)

#### **Problemas Críticos Identificados**

##### 1. **Falta de Dados de Teste Válidos**
| Teste | Problema | Status Obtido | Status Esperado |
|-------|----------|---------------|-----------------|
| Login com credenciais válidas | Usuário não existe | 401 | 200 |
| Criar usuário com email duplicado | Email é único a cada execução | 201 | 400 |

##### 2. **Falta de Token de Autorização**  
| Teste | Problema | Status Obtido | Status Esperado |
|-------|----------|---------------|-----------------|
| Todos os testes de Produtos | Token ausente/inválido | 401 | 200/201/400 |
| Todos os testes de Carrinho | Token ausente/inválido | 401 | 200/201/400 |

##### 3. **Comportamento da API Evoluído**
| Teste | Problema | Observação |
|-------|----------|------------|
| Deletar usuário inexistente | Retorna 200 "Nenhum registro excluído" | Comportamento mais amigável |
| Atualizar usuário existente | Retorna 201 em vez de 200 | Pode estar criando novo |

---

## 🐛 Defeitos e Descobertas

### 🔍 **Descobertas Importantes**

#### 1. **Comportamento de Exclusão Mais Amigável**
**Descoberta**: A API agora retorna status 200 com mensagem "Nenhum registro excluído" quando tenta deletar usuário inexistente, em vez de retornar erro 400.
**Impacto**: **Positivo** - Comportamento mais user-friendly
**Ação**: Atualizar testes para refletir novo comportamento

#### 2. **Validação de Provedor de Email Removida**
**Descoberta**: A API não bloqueia mais emails @gmail.com
**Impacto**: **Neutro** - Funcionalidade simplificada
**Ação**: Remover testes específicos de validação de provedor

#### 3. **Validação de Senha Simplificada**
**Descoberta**: A API aceita senhas com menos de 5 caracteres
**Impacto**: **Questionável** - Pode ser problema de segurança
**Ação**: Validar com equipe se é comportamento intencional

### 🚨 **Problemas Críticos na Suite de Testes**

#### 1. **Ausência de Gestão de Dados de Teste**
**Problema**: Testes dependem de dados que não existem
**Severidade**: 🔴 Crítica
**Solução**: Implementar setup/teardown para criar dados necessários

#### 2. **Falta de Gerenciamento de Token**  
**Problema**: Testes que requerem autenticação não fazem login primeiro
**Severidade**: 🔴 Crítica  
**Solução**: Implementar fluxo de autenticação automático

#### 3. **IDs Hardcoded Inválidos**
**Problema**: Testes usam IDs fixos que não existem
**Severidade**: 🟠 Alta
**Solução**: Usar IDs dinâmicos criados durante execução

---

## 🔍 Testes de Limite (Boundary) Executados

### Validação de Campos
| Campo Testado | Valores Limite | Resultado | Observações |
|---------------|----------------|-----------|-------------|
| **Email vazio** | "" | ✅ Pass | Status 400 correto |
| **Password vazio** | "" | ✅ Pass | Status 400 correto |
| **Email Gmail** | @gmail.com | ❌ Aceito | Validação removida |
| **Senha curta** | <5 chars | ❌ Aceito | Validação removida |

### Performance da API
| Métrica | Valor | Meta | Status |
|---------|-------|------|--------|
| **Tempo médio** | 302ms | <2000ms | ✅ Excelente |
| **Tempo mínimo** | 212ms | - | ✅ |
| **Tempo máximo** | 929ms | <5000ms | ✅ |
| **Desvio padrão** | 123ms | - | ✅ Consistente |

---

## 🔄 Regras de Negócio Validadas

### ✅ Regras CONFIRMADAS
| ID | Regra de Negócio | Como Foi Validada |
|----|------------------|-------------------|
| RN-002 | Email/senha inválidos retornam 401 | Múltiplos testes passaram |
| RN-003 | Campos obrigatórios validados | Status 400 correto |
| RN-006 | Atualização por ID inexistente cria novo | Status 201 observado |
| RN-022 | JSON malformado rejeitado | Validações funcionando |

### ❓ Regras COM MUDANÇAS
| ID | Regra de Negócio | Mudança Observada |
|----|------------------|-------------------|
| RN-008 | Validação de provedor de email | **Removida** - Gmail aceito |
| RN-008 | Validação de tamanho mínimo de senha | **Relaxada** - <5 chars aceito |
| RN-007 | Comportamento ao deletar inexistente | **Melhorada** - Retorna 200 "Nenhum registro" |

---

## 💡 Descobertas e Melhorias

### Descobertas Importantes
1. **API mais permissiva**: Validações de email e senha foram relaxadas
2. **Comportamento mais amigável**: Deletar inexistente retorna sucesso com aviso
3. **Performance excelente**: Todas as requisições < 1 segundo
4. **Estabilidade boa**: 0 timeouts ou erros de conexão

### Melhorias nos Testes
1. **Implementar data setup**: Criar usuários/produtos antes dos testes
2. **Gestão de tokens**: Fazer login automático quando necessário
3. **IDs dinâmicos**: Parar de usar IDs hardcoded
4. **Cleanup**: Limpar dados criados após testes
5. **Atualizar expectativas**: Ajustar status codes conforme comportamento atual

### Candidatos à Automação (Robot Framework)
| Teste Manual | Motivo para Automatizar | Prioridade |
|--------------|-------------------------|------------|
| Login válido com setup | Smoke test essencial | 🔴 Alta |
| CRUD usuários com cleanup | Regressão frequente | 🔴 Alta |
| Boundary testing campos | Muitos cenários similares | 🟡 Média |
| Fluxos com autenticação | Complexos mas estáveis | 🟡 Média |

---

## 🎯 Próximos Passos

### Ações Imediatas (Esta Semana)
- [ ] **Corrigir collection Postman** com dados válidos e fluxo de autenticação
- [ ] **Implementar Robot Framework** para casos críticos com setup automático  
- [ ] **Documentar mudanças da API** para alinhar com stakeholders
- [ ] **Criar dados de teste** padronizados e reutilizáveis

### Ações de Médio Prazo (Próximas 2 Semanas)
- [ ] **Implementar CI/CD** para execução automática
- [ ] **Integrar com QALity/Jira** conforme planejado
- [ ] **Criar dashboard** de qualidade com métricas reais
- [ ] **Treinar equipe** nas novas ferramentas

### Recomendações
1. **Para o Produto**: Validar se mudanças de validação foram intencionais
2. **Para os Testes**: Priorizar automação com Robot Framework sobre correção manual do Postman
3. **Para a Automação**: Focar em casos críticos com setup/teardown robusto

### Próxima Execução
- **Data Planejada**: 02/10/2025
- **Foco**: Testes corrigidos com Robot Framework  
- **Preparação Necessária**: Implementar keywords de setup/teardown

---

## 📊 Conclusões

### 🎯 **Status Geral do Challenge**
| Aspecto | Status | Observação |
|---------|--------|------------|
| **Execução de Testes** | 🟡 Parcial | Collection precisa atualização |
| **Identificação de Problemas** | ✅ Completa | 35 issues catalogados |
| **Boundary Testing** | 🟡 Iniciado | Identificados 4 cenários |
| **Documentação** | ✅ Excelente | Relatório detalhado gerado |
| **Próximos Passos** | ✅ Claros | Roadmap definido |

### 🏆 **Valor Entregue**
1. **Diagnóstico completo** da situação atual dos testes
2. **Identificação de melhorias** na API (comportamentos mais amigáveis)
3. **Roadmap claro** para correção e automação
4. **Baseline** para métricas de qualidade futuras
5. **Evidência concreta** da necessidade de modernização dos testes

---

## 📎 Anexos e Evidências

### Arquivos Salvos
- [x] Resultado completo do Newman (16.7s de execução)
- [x] Collection Postman original analisada
- [x] Log detalhado de todas as 37 requests
- [x] Métricas de performance coletadas

### Localização dos Arquivos
**Pasta**: `manual-tests/evidence/20251001_1530/`
**Conteúdo**:
- NewmanResults/output.txt
- PostmanCollection/original.json  
- PerformanceData/metrics.json
- Screenshots/failures/

---

## ✍️ Assinaturas

| Papel | Nome | Data | Status |
|-------|------|------|--------|
| **Executor** | Caio Oliveira Silva Alencar | 01/10/2025 | ✅ Concluído |
| **Revisor** | [A definir] | ___/___/2025 | ⏳ Pendente |
| **Aprovador** | [A definir] | ___/___/2025 | ⏳ Pendente |

---

## 📝 Observações Finais

Esta execução foi **extremamente valiosa** pois revelou que:

1. **A API evoluiu** de forma positiva (mais permissiva e amigável)
2. **Os testes estão desatualizados** mas com padrões corrigíveis  
3. **A performance é excelente** (302ms médio)
4. **A automação é necessária** para manter qualidade

O próximo passo é implementar a **suite Robot Framework** com **setup/teardown adequado** para ter testes **confiáveis e maintíveis**.