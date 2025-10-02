# Challenge ServeRest - Testes API 🚀

**Autor**: Caio Oliveira Silva Alencar  
**Repositório**: https://github.com/CaioOSAlencar/Estagio  
**Data**: Outubro 2025

## 📋 Visão Geral

Projeto de testes para API ServeRest com foco em automação e documentação prática.

**🎯 Status Atual:**
- ✅ **Robot Framework**: 11 testes funcionando (100% sucesso)
- ⚠️ **Newman/Postman**: ~15 de 37 requests funcionando (~40% sucesso)  
- ✅ **Documentação completa** de estratégias e casos de teste
- 📊 **Cobertura**: Login, Usuários, Produtos e Carrinho testados

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
- **Robot Framework**: 11 testes automatizados passando
- **Cobertura completa**: Todos os 4 módulos da API (Login, Usuários, Produtos, Carrinho)
- **Validações robustas**: Campos obrigatórios, formatos inválidos, endpoints públicos
- **Abordagem que funciona**: Dados únicos, testes isolados, expectativas realistas

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
│   ├── tests/auth/test_basic_working.robot      ← 7 testes essenciais comentados
│   └── tests/complete/test_serverest_complete.robot ← 11 testes completos
├── 📂 postman/                       ← Collection original ServeRest  
├── 📂 manual-tests/                  ← Templates e execuções documentadas
└── 📂 docs/                          ← Estratégias e regras de negócio
```

### 🎓 **Código Educativo**
- **Comentários detalhados** explicando cada passo dos testes
- **Documentação in-line** para facilitar aprendizado
- **Explicações de sintaxe** Robot Framework
- **Estratégias de teste** documentadas no código

---

## 🎯 Objetivos Alcançados

1. ✅ **Testes automatizados funcionando** - Robot Framework com 100% sucesso
2. ✅ **Documentação completa** - Estratégias, casos de teste e execuções
3. ✅ **Análise de comportamentos reais** - API testada e comportamentos documentados  
4. ✅ **Abordagem robusta** - Dados dinâmicos e testes independentes
5. ✅ **Código educativo** - Comentários detalhados para facilitar aprendizado

---

## 🏆 Principais Conquistas

- **100% de sucesso** nos testes Robot Framework
- **Descoberta de comportamentos reais** da API ServeRest  
- **Metodologia que funciona**: dados únicos + testes isolados
- **Documentação focada** no que realmente importa
- **Código educativo** com comentários detalhados explicando cada etapa

---

## ☁️ Bonus: Execução na AWS

### 🚀 **Setup Distribuído com EC2**
- **EC2-1**: ServeRest rodando na porta 3000
- **EC2-2**: Robot Framework executando testes remotamente
- **Scripts automatizados** para configuração completa
- **Suporte Linux e Windows** Server

### ⚡ **Execução Rápida Linux**
```bash
# Setup ServeRest (EC2-1)
curl -fsSL https://raw.githubusercontent.com/CaioOSAlencar/Estagio/main/scripts/setup-ec2-serverest.sh | bash

# Setup Robot Framework (EC2-2)  
curl -fsSL https://raw.githubusercontent.com/CaioOSAlencar/Estagio/main/scripts/setup-ec2-robot.sh | bash
```

### ⚡ **Execução Rápida Windows**
```powershell
# PowerShell como Administrator

# Setup ServeRest (EC2-1)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/CaioOSAlencar/Estagio/main/scripts/setup-ec2-serverest-windows.ps1" -OutFile "setup-serverest.ps1"
.\setup-serverest.ps1

# Setup Robot Framework (EC2-2)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/CaioOSAlencar/Estagio/main/scripts/setup-ec2-robot-windows.ps1" -OutFile "setup-robot.ps1"
.\setup-robot.ps1
```

### 📚 **Documentação Completa**

| Sistema | Guia Completo | Guia Rápido |
|---------|---------------|-------------|
| **🐧 Linux** | [`docs/AWS_EC2_SETUP.md`](docs/AWS_EC2_SETUP.md) | [`docs/GUIA_RAPIDO_AWS.md`](docs/GUIA_RAPIDO_AWS.md) |
| **🪟 Windows** | [`docs/AWS_EC2_SETUP_WINDOWS.md`](docs/AWS_EC2_SETUP_WINDOWS.md) | [`docs/GUIA_RAPIDO_AWS_WINDOWS.md`](docs/GUIA_RAPIDO_AWS_WINDOWS.md) |

---

## 📞 Contato

**Caio Oliveira Silva Alencar**  
🐙 GitHub: [CaioOSAlencar](https://github.com/CaioOSAlencar)