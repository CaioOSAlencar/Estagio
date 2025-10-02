# CT-001: Login com Credenciais Válidas

## Informações Gerais

| Campo | Valor |
|-------|--------|
| **ID do Teste** | CT-001 |
| **Nome** | Login com credenciais válidas |
| **Módulo** | Login |
| **Prioridade** | Alta |
| **Tipo** | Funcional |
| **Automação** | ✅ Sim |
| **Autor** | Caio Oliveira Silva Alencar |
| **Data Criação** | 01/10/2025 |
| **Última Revisão** | 01/10/2025 |

---

## Objetivo do Teste
Validar que um usuário cadastrado consegue realizar login com credenciais válidas e receber um token JWT funcional.

---

## Pré-condições
- [ ] API ServeRest está disponível
- [ ] Usuário de teste está cadastrado no sistema
- [ ] Ferramenta de teste (Postman) configurada

---

## Dados de Teste

### Dados de Entrada
```json
{
  "email": "atreus@exemplo.com",
  "password": "123456"
}
```

### Dados Esperados
```json
{
  "message": "Login realizado com sucesso",
  "authorization": "Bearer eyJ..."
}
```

---

## Passos de Execução

| Passo | Ação | Resultado Esperado |
|-------|------|--------------------|
| 1 | Abrir Postman e selecionar request "Login com credenciais válidas" | Request carregado corretamente |
| 2 | Verificar URL: `{{baseUrl}}/login` | URL está correta |
| 3 | Verificar método: POST | Método está configurado como POST |
| 4 | Verificar headers: Content-Type: application/json | Header configurado |
| 5 | Verificar body com credenciais válidas | JSON está formatado corretamente |
| 6 | Executar request (Send) | Request enviado |
| 7 | Verificar status code da resposta | Status: 200 OK |
| 8 | Verificar estrutura do response | Contém campos "message" e "authorization" |
| 9 | Verificar conteúdo da message | "Login realizado com sucesso" |
| 10 | Verificar formato do token | Inicia com "Bearer " seguido de JWT |
| 11 | Verificar se token foi salvo na variável global | Token armazenado em {{Token}} |

---

## Critérios de Aceitação
- ✅ Status code 200 OK
- ✅ Response contém campo "message" com valor correto
- ✅ Response contém campo "authorization" 
- ✅ Token JWT válido (formato Bearer + JWT)
- ✅ Token é salvo automaticamente nas variáveis globais
- ✅ Tempo de resposta < 2 segundos

---

## Regras de Negócio Validadas
- **RN-001**: Token JWT gerado com validade de 600 segundos
- **RN-002**: Validação correta de credenciais

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

### Evidências Coletadas
- [ ] Print da requisição no Postman
- [ ] Print da resposta com status 200
- [ ] Print do token gerado
- [ ] Print dos testes automáticos passando
- [ ] Log do tempo de resposta

### Observações
[Preencher após execução]

---

## Casos de Teste Relacionados
- CT-002: Login com credenciais inválidas
- CT-003: Validação de campos obrigatórios
- CT-004: Expiração de token

---

## Variações para Testes de Limite

### Dados Limite - Email
- Email mínimo válido: `"a@b.c"`
- Email com caracteres especiais: `"test+tag@domain-test.co.uk"`
- Email com números: `"user123@domain123.com"`

### Dados Limite - Password  
- Password de 1 caractere: `"1"`
- Password muito longa: `"a" * 100`
- Password com caracteres especiais: `"P@ssw0rd!"`

---

## Notas de Automação
Este teste é **candidato prioritário** para automação porque:
- ✅ É executado frequentemente (smoke test)
- ✅ É estável e determinístico  
- ✅ Funcionalidade crítica do sistema
- ✅ Dados de teste são consistentes