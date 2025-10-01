# Challenge ServeRest - Testes Manuais e Automação

## 📋 Visão Geral do Projeto

Este projeto é uma continuidade dos exercícios de teste da API ServeRest, focando em:
- Melhoria do planejamento de testes baseado nos feedbacks dos instrutores
- Implementação de estratégias de testes mais robustas
- Automação de testes usando Robot Framework
- Integração com QALity para execução no Jira

## 🎯 Objetivos do Challenge

1. **Organizar planejamento de testes** aplicando melhorias dos feedbacks
2. **Melhorar estratégia de testes** com foco em regras de negócio e testes de limite
3. **Refinar testes candidatos à automação**
4. **Criar testes automatizados** com Robot Framework
5. **Manter documentação atualizada** no repositório Git
6. **Tarefa extra**: Configurar ServeRest em EC2 e executar testes remotamente

## 📊 Feedback do Instrutor

> "A entrega está boa e mostra que ele compreendeu bem o desafio. Porém, com mais atenção às regras de negócio, inclusão de testes de limite e uma melhor documentação das execuções, o trabalho ficará mais completo, claro e confiável."

### Pontos de Melhoria Identificados:
- ✅ **Regras de negócio**: Maior atenção aos cenários de negócio
- ✅ **Testes de limite**: Inclusão de boundary testing
- ✅ **Documentação**: Melhor documentação das execuções

## 🗂️ Estrutura do Projeto

```
📁 Estagio/
├── 📁 docs/                          # Documentação do projeto
│   ├── 📄 test-strategy.md           # Estratégia de testes
│   ├── 📄 test-plan.md               # Plano de testes detalhado
│   ├── 📄 business-rules.md          # Regras de negócio identificadas
│   └── 📄 automation-candidates.md   # Critérios para automação
├── 📁 manual-tests/                  # Testes manuais
│   ├── 📁 test-cases/                # Casos de teste detalhados
│   ├── 📁 test-execution/            # Registros de execução
│   └── 📁 evidence/                  # Evidências dos testes
├── 📁 automation/                    # Testes automatizados
│   ├── 📁 robot-framework/           # Projeto Robot Framework
│   ├── 📁 resources/                 # Recursos compartilhados
│   ├── 📁 test-data/                 # Dados de teste
│   └── 📁 results/                   # Resultados das execuções
├── 📁 postman/                       # Coleções Postman existentes
└── 📁 aws-deployment/                # Configurações AWS (tarefa extra)
```

## 🚀 Próximos Passos

1. **Análise e Documentação**
   - [ ] Documentar estratégia de testes atualizada
   - [ ] Identificar e documentar regras de negócio
   - [ ] Criar casos de teste com foco em boundary testing

2. **Testes Manuais**
   - [ ] Executar rodada de testes manuais
   - [ ] Documentar evidências de execução
   - [ ] Identificar candidatos à automação

3. **Automação**
   - [ ] Configurar projeto Robot Framework
   - [ ] Implementar testes automatizados prioritários
   - [ ] Configurar pipeline de execução

4. **Integração e Deploy**
   - [ ] Integrar com QALity/Jira
   - [ ] Configurar ambiente AWS (extra)
   - [ ] Automatizar execução remota

## 📚 Recursos

- [ServeRest API Documentation](https://serverest.dev/)
- [Robot Framework Documentation](https://robotframework.org/)
- [Postman Collections](./postman/)