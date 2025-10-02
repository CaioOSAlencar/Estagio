# Template de Caso de Teste Manual

## Informações Gerais

| Campo | Valor |
|-------|--------|
| **ID do Teste** | CT-XXX |
| **Nome** | [Nome descritivo do teste] |
| **Módulo** | [Login/Usuários/Produtos/Carrinho] |
| **Prioridade** | [Alta/Média/Baixa] |
| **Tipo** | [Funcional/Boundary/Segurança/Integração] |
| **Automação** | [Sim/Não/Parcial] |
| **Autor** | [Seu nome] |
| **Data Criação** | [Data] |
| **Última Revisão** | [Data] |

---

## Objetivo do Teste
**Descrição clara do que o teste pretende validar**

---

## Pré-condições
- [ ] Condição 1
- [ ] Condição 2
- [ ] Condição N

---

## Dados de Teste

### Dados de Entrada
```json
{
  "campo1": "valor1",
  "campo2": "valor2"
}
```

### Dados Esperados
```json
{
  "expectedField": "expectedValue"
}
```

---

## Passos de Execução

| Passo | Ação | Resultado Esperado |
|-------|------|--------------------|
| 1 | [Ação detalhada] | [Resultado específico] |
| 2 | [Ação detalhada] | [Resultado específico] |
| N | [Ação detalhada] | [Resultado específico] |

---

## Critérios de Aceitação
- ✅ Critério 1
- ✅ Critério 2
- ✅ Critério N

---

## Resultado da Execução

### Informações da Execução
| Campo | Valor |
|-------|--------|
| **Data Execução** | |
| **Executado por** | |
| **Ambiente** | |
| **Versão API** | |
| **Status** | ✅ Passou / ❌ Falhou / ⚠️ Bloqueado |

### Evidências
- [ ] Screenshot/Print da requisição
- [ ] Screenshot/Print da resposta
- [ ] Log de erro (se aplicável)
- [ ] Arquivo de evidência anexado

### Observações
[Comentários sobre a execução, dificuldades, descobertas, etc.]

---

## Defeitos Encontrados

### Bug #001 (se aplicável)
| Campo | Valor |
|-------|--------|
| **Severidade** | [Crítica/Alta/Média/Baixa] |
| **Descrição** | [Descrição do bug] |
| **Passos para Reproduzir** | [Passos específicos] |
| **Resultado Esperado** | [O que deveria acontecer] |
| **Resultado Atual** | [O que realmente aconteceu] |
| **Evidência** | [Link/arquivo de evidência] |

---

## Casos de Teste Relacionados
- CT-XXX: [Nome do teste relacionado]
- CT-YYY: [Nome do teste relacionado]

---

## Notas de Melhoria
[Sugestões para melhorar o teste, dados, ou processo]