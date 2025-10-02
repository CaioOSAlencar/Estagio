# CT-015: Boundary Testing - Quantidade Maior que Estoque

## Informações Gerais

| Campo | Valor |
|-------|--------|
| **ID do Teste** | CT-015 |
| **Nome** | Validação de limite de estoque no carrinho |
| **Módulo** | Carrinho |
| **Prioridade** | Alta |
| **Tipo** | Boundary |
| **Automação** | ✅ Sim |
| **Autor** | Caio Olviera Silva Alencar |
| **Data Criação** | 01/10/2025 |
| **Última Revisão** | 01/10/2025 |

---

## Objetivo do Teste
Validar que o sistema impede a adição de produtos ao carrinho quando a quantidade solicitada excede o estoque disponível, testando especificamente os limites (boundary values).

---

## Pré-condições
- [ ] API ServeRest está disponível
- [ ] Usuário admin logado (para cadastrar produto)
- [ ] Usuário comum logado (para teste do carrinho)
- [ ] Produto de teste com quantidade específica cadastrado

---

## Dados de Teste

### Setup - Produto com Estoque Limitado
```json
{
  "nome": "Produto Teste Estoque",
  "preco": 100,
  "descricao": "Produto para teste de limite de estoque",
  "quantidade": 5
}
```

### Cenários de Teste

#### Cenário 1: Quantidade = Estoque (Limite Válido)
```json
{
  "produtos": [
    {
      "idProduto": "{produto_id}",
      "quantidade": 5
    }
  ]
}
```

#### Cenário 2: Quantidade = Estoque + 1 (Limite Inválido)
```json
{
  "produtos": [
    {
      "idProduto": "{produto_id}",
      "quantidade": 6
    }
  ]
}
```

#### Cenário 3: Quantidade Muito Maior que Estoque
```json
{
  "produtos": [
    {
      "idProduto": "{produto_id}",
      "quantidade": 100
    }
  ]
}
```

#### Cenário 4: Produto com Estoque Zero
```json
{
  "produtos": [
    {
      "idProduto": "{produto_zero_id}",
      "quantidade": 1
    }
  ]
}
```

---

## Passos de Execução

### Setup Inicial
| Passo | Ação | Resultado Esperado |
|-------|------|--------------------|
| 1 | Fazer login como administrador | Token admin obtido |
| 2 | Cadastrar produto com quantidade = 5 | Produto criado, ID retornado |
| 3 | Cadastrar produto com quantidade = 0 | Produto sem estoque criado |
| 4 | Fazer login como usuário comum | Token usuário obtido |
| 5 | Verificar se carrinho está vazio | Nenhum carrinho ativo |

### Cenário 1: Quantidade = Estoque (Válido)
| Passo | Ação | Resultado Esperado |
|-------|------|--------------------|
| 6 | POST `/carrinhos` com quantidade = 5 | Status: 201 Created |
| 7 | Verificar resposta | Carrinho criado com sucesso |
| 8 | GET `/carrinhos` para confirmar | Produto no carrinho com qtd 5 |
| 9 | DELETE `/carrinhos/cancelar-compra` | Limpar carrinho |

### Cenário 2: Quantidade = Estoque + 1 (Inválido)
| Passo | Ação | Resultado Esperado |
|-------|------|--------------------|
| 10 | POST `/carrinhos` com quantidade = 6 | Status: 400 Bad Request |
| 11 | Verificar mensagem de erro | Erro sobre estoque insuficiente |
| 12 | GET `/carrinhos` | Nenhum carrinho criado |

### Cenário 3: Quantidade Muito Maior (Inválido)
| Passo | Ação | Resultado Esperado |
|-------|------|--------------------|
| 13 | POST `/carrinhos` com quantidade = 100 | Status: 400 Bad Request |
| 14 | Verificar consistência do erro | Mesma mensagem do cenário 2 |

### Cenário 4: Estoque Zero (Inválido)
| Passo | Ação | Resultado Esperado |
|-------|------|--------------------|
| 15 | POST `/carrinhos` com produto sem estoque | Status: 400 Bad Request |
| 16 | Verificar mensagem específica | Erro sobre produto sem estoque |

---

## Critérios de Aceitação

### Funcionalidade
- ✅ Quantidade ≤ estoque: permitido (201)
- ✅ Quantidade > estoque: negado (400)
- ✅ Estoque = 0: sempre negado (400)

### Consistência
- ✅ Mensagens de erro são claras e específicas
- ✅ Nenhum carrinho é criado em casos de erro
- ✅ Estoque não é alterado durante validação

### Performance
- ✅ Validação ocorre em tempo adequado (< 2s)
- ✅ Múltiplas tentativas não degradam performance

---

## Regras de Negócio Validadas
- **RN-014**: Validação de estoque antes da adição
- **RN-013**: Integridade do carrinho único por usuário
- **RN-015**: Autenticação obrigatória para carrinho

---

## Valores de Boundary Testing

### Tabela de Valores Limite
| Estoque | Quantidade Teste | Resultado Esperado | Observação |
|---------|------------------|-------------------|------------|
| 5 | 4 | ✅ Sucesso | Abaixo do limite |
| 5 | 5 | ✅ Sucesso | **Exato no limite** |
| 5 | 6 | ❌ Erro | **Logo acima do limite** |
| 5 | 10 | ❌ Erro | Muito acima |
| 0 | 0 | ❌ Erro | Quantidade zero |
| 0 | 1 | ❌ Erro | **Estoque zerado** |
| 1 | 1 | ✅ Sucesso | **Limite mínimo válido** |
| 1 | 2 | ❌ Erro | Acima do mínimo |

---

## Resultado da Execução

### Informações da Execução
| Campo | Valor |
|-------|--------|
| **Data Execução** | ___/___/2025 |
| **Executado por** | Caio Oliveira Silva Alencar |
| **Ambiente** | https://serverest.dev |
| **Versão API** | Atual |
| **Status** | ⬜ Passou / ⬜ Falhou / ⬜ Bloqueado |

### Resultados por Cenário
| Cenário | Status | Observações |
|---------|--------|-------------|
| Qtd = Estoque | ⬜ Pass / ⬜ Fail | |
| Qtd = Estoque + 1 | ⬜ Pass / ⬜ Fail | |
| Qtd >> Estoque | ⬜ Pass / ⬜ Fail | |
| Estoque Zero | ⬜ Pass / ⬜ Fail | |

### Evidências Coletadas
- [ ] Prints de cada cenário (request + response)
- [ ] Log das mensagens de erro específicas
- [ ] Evidência de que estoque não foi alterado
- [ ] Tempos de resposta registrados

### Observações
[Preencher após execução - comportamentos inesperados, mensagens diferentes do esperado, etc.]

---

## Defeitos Encontrados

### Bug #001 (exemplo - preencher se encontrado)
| Campo | Valor |
|-------|--------|
| **Severidade** | Alta |
| **Descrição** | Mensagem de erro inconsistente entre cenários |
| **Passos para Reproduzir** | 1. Tentar qtd=6 com estoque=5; 2. Tentar qtd=100 com estoque=5 |
| **Resultado Esperado** | Mesma mensagem padronizada |
| **Resultado Atual** | Mensagens diferentes ou código diferente |
| **Evidência** | [anexar prints] |

---

## Casos de Teste Relacionados
- CT-014: Adicionar produto válido ao carrinho
- CT-016: Finalizar compra (testa redução de estoque)
- CT-017: Cancelar compra (testa reabastecimento)
- CT-011: Validação de dados de produto

---

## Automação - Dados Parametrizados

### Template para Robot Framework
```robot
*** Test Cases ***
Validar Limite de Estoque - Cenários Múltiplos
    [Template]    Testar Adicao Carrinho Com Quantidade
    # estoque    quantidade    status_esperado    deve_criar_carrinho
    5            4             201                True
    5            5             201                True  
    5            6             400                False
    5            100           400                False
    0            1             400                False
    1            1             201                True
    1            2             400                False
```

---

## Notas de Melhoria
- **Automação**: Este teste é excelente para data-driven testing
- **Coverage**: Considerar testar com múltiplos produtos no mesmo carrinho
- **Performance**: Adicionar validação de tempo de resposta para casos de erro
- **Usability**: Documentar as mensagens de erro específicas para cada cenário