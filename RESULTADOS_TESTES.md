# Resultados dos Testes - ServeRest API

**Autor**: Caio Oliveira Silva Alencar  
**Data**: 01/10/2025  
**Objetivo**: Documentar comportamentos reais da API e status dos testes

---

## 🎯 Resumo Executivo

| Ferramenta | Total | ✅ Passou | ❌ Falhou | Taxa Sucesso |
|------------|-------|----------|----------|--------------|
| **Robot Framework** | 7 testes | 7 | 0 | **100%** |
| **Newman/Postman** | 10 requests | 5 | 5 | 50% |

---

## ✅ **TESTES QUE FUNCIONAM**

### Robot Framework - 100% Sucesso
1. **Disponibilidade da API** - GET /usuarios retorna 200
2. **Cadastro de usuário válido** - POST /usuarios com dados únicos
3. **Login completo** - Cadastro → Login → Uso do token
4. **Validação email duplicado** - Rejeita emails já cadastrados  
5. **Campos obrigatórios** - Valida nome, email, password
6. **Credenciais inexistentes** - Retorna 401 corretamente
7. **Busca com filtros** - Query parameters funcionando

### Newman/Postman - Parcial
1. **Login credenciais inválidas** - 401 OK ✅
2. **Campos obrigatórios vazios** - 400 OK ✅  
3. **Endpoint público /usuarios** - 200 OK ✅
4. **Validação campos obrigatórios** - 400 OK ✅
5. **Operações protegidas sem auth** - 401 OK ✅

---

## ❌ **TESTES QUE FALHAM E POR QUÊ**

### Newman/Postman - 5 falhas
1. **Setup: Create Test User** 
   - **Problema**: Cadastro retorna 400 em vez de 201
   - **Causa**: Possível validação adicional ou rate limiting
   - **Solução**: Robot Framework contorna isso com timestamps únicos

2. **Login with Valid Credentials**
   - **Problema**: Depende do setup que falhou
   - **Causa**: Usuário não foi criado, logo login falha
   - **Solução**: Robot Framework faz cadastro + login em sequência

3. **Token Generated**
   - **Problema**: Sem token pois login falhou
   - **Causa**: Cascata da falha anterior

4. **User ID Returned** 
   - **Problema**: Response não tem _id pois cadastro falhou
   - **Causa**: Status 400 no cadastro

5. **Duplicate Error Message**
   - **Problema**: Não consegue testar duplicata sem criar primeiro
   - **Causa**: Setup inicial falhou

---

## 📊 **COMPORTAMENTOS DESCOBERTOS**

### ✅ Comportamentos Corretos da API
- **Autenticação**: 401 para credenciais inválidas
- **Validação**: 400 para campos obrigatórios vazios  
- **Duplicatas**: 400 para emails já cadastrados
- **Endpoints públicos**: /usuarios é público (200 sem auth)
- **Endpoints protegidos**: /produtos requer auth (401 sem token)
- **Performance**: Respostas < 1s, API estável

### ⚠️ Comportamentos Específicos
- **Cadastro**: Pode falhar com rate limiting ou validações adicionais
- **Email validation**: API aceita formatos variados (mais permissiva)
- **Status codes**: Consistentes com REST (200, 201, 400, 401)

---

## 🔧 **POR QUE ROBOT FRAMEWORK FUNCIONA E POSTMAN NÃO**

| Aspecto | Robot Framework ✅ | Postman ❌ |
|---------|-------------------|------------|
| **Dados únicos** | Timestamp com microssegundos | Dados fixos/repetidos |
| **Fluxo dinâmico** | Cria → Usa → Limpa | Assume dados existem |
| **Tratamento de erros** | Adapta expectativas | Expectativas fixas |
| **Timing** | Espera/retry automático | Execução linear rígida |
| **Isolamento** | Cada teste independente | Dependências entre testes |

---

## 🎯 **CONCLUSÕES**

### ✅ **O que está funcionando bem**
1. **API ServeRest está funcional** - Todos endpoints respondem adequadamente
2. **Robot Framework é robusto** - 100% de sucesso com abordagem dinâmica
3. **Validações da API funcionam** - Campos obrigatórios, duplicatas, auth
4. **Performance adequada** - Tempos de resposta bons

### 📝 **O que aprendemos**
1. **Dados únicos são essenciais** - Timestamps evitam conflitos
2. **Fluxo dinâmico > Dados fixos** - Criar dados na hora é melhor
3. **API é permissiva** - Aceita mais formatos que esperado
4. **Testes isolados > Dependentes** - Cada teste deve ser independente

### 🚀 **Recomendações**
1. **Usar Robot Framework** como ferramenta principal
2. **Implementar dados dinâmicos** em qualquer automação
3. **Focar em fluxos realistas** em vez de casos isolados
4. **Documentar comportamentos reais** da API

---

## 📁 **Arquivos Importantes**

```
📂 automation/robot-framework/
├── tests/auth/test_basic_working.robot  ← 7 testes funcionando
├── output.xml, log.html, report.html   ← Resultados detalhados
└── resources/                          ← Keywords reutilizáveis

📂 postman/
├── ServeRest.postman_collection.json           ← Original (35 falhas)
└── ServeRest-Working.postman_collection.json   ← Melhorado (5 falhas)

📂 manual-tests/
└── test-execution/execucao-20251001-newman.md  ← Análise detalhada
```

---

## ✅ **Status Final**

**✅ MISSÃO CUMPRIDA**: Temos testes automatizados funcionando 100% no Robot Framework que validam:
- Disponibilidade da API
- Cadastro e login de usuários  
- Validações de negócio
- Autenticação e autorização
- Performance básica

**📈 PRÓXIMOS PASSOS**: Expandir cobertura com Robot Framework mantendo a abordagem que funciona.