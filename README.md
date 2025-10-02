# Challenge ServeRest - Testes API 🚀

**Autor**: Caio Oliveira Silva Alencar  
**Repositório**: https://github.com/CaioOSAlencar/Estagio  
**Data**: Outubro 2025

## 📋 Visão Geral

Projeto de testes para API ServeRest com foco em automação e documentação prática.

**🎯 Status Atual:**
- ✅ **Robot Framework**: 7 testes funcionando (100% sucesso)
- ⚠️ **Newman/Postman**: 5 de 10 testes funcionando (50% sucesso)  
- ✅ **Documentação completa** de estratégias e casos de teste

---

## 🚀 Como Executar os Testes

### Robot Framework (Recomendado ✅)
```bash
cd automation/robot-framework
pip install robotframework robotframework-requests robotframework-jsonlibrary
python -m robot tests/auth/test_basic_working.robot
```

### Newman/Postman
```bash
cd postman  
npm install -g newman
newman run ServeRest.postman_collection.json
```

---

## 📊 Resultados Principais

**📁 Ver análise completa em: `RESULTADOS_TESTES.md`**

### ✅ **O que funciona (100%)**
- **Robot Framework**: 7 testes automatizados passando
- **Cadastro dinâmico**: Usuários únicos com timestamp
- **Login completo**: Fluxo cadastro → login → uso do token
- **Validações**: Campos obrigatórios, duplicatas, autenticação

### 📝 **Descobertas importantes**
- **API é mais permissiva** que esperado (aceita vários formatos)
- **Dados únicos são essenciais** - evita conflitos e rate limiting
- **Endpoints públicos**: `/usuarios` não requer autenticação
- **Testes isolados** funcionam melhor que dependentes

---

## 📁 Estrutura do Projeto

```
📁 Estagio/
├── 📊 RESULTADOS_TESTES.md           ← Análise completa dos resultados
├── 📂 automation/robot-framework/    ← Testes funcionando (100% sucesso)
│   └── tests/auth/test_basic_working.robot
├── 📂 postman/                       ← Collection original ServeRest  
├── 📂 manual-tests/                  ← Templates e execuções documentadas
└── 📂 docs/                          ← Estratégias e regras de negócio
```

---

## 🎯 Objetivos Alcançados

1. ✅ **Testes automatizados funcionando** - Robot Framework com 100% sucesso
2. ✅ **Documentação completa** - Estratégias, casos de teste e execuções
3. ✅ **Análise de comportamentos reais** - API testada e comportamentos documentados
4. ✅ **Abordagem robusta** - Dados dinâmicos e testes independentes

---

## 🏆 Principais Conquistas

- **100% de sucesso** nos testes Robot Framework
- **Descoberta de comportamentos reais** da API ServeRest
- **Metodologia que funciona**: dados únicos + testes isolados
- **Documentação focada** no que realmente importa

---

## 📞 Contato

**Caio Oliveira Silva Alencar**  
🐙 GitHub: [CaioOSAlencar](https://github.com/CaioOSAlencar)