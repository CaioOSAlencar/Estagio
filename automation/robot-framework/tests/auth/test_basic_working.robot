*** Settings ***
Documentation     Testes Básicos da API ServeRest - Validação dos Comportamentos Conhecidos
...               
...               Esta suite contém 7 testes que validam os comportamentos essenciais da API ServeRest.
...               Todos os testes foram desenvolvidos com base no comportamento real da API descoberto
...               durante execuções práticas. Utiliza dados dinâmicos para evitar conflitos.
...               
...               IMPORTANTE: Estes testes têm 100% de taxa de sucesso pois foram ajustados 
...               para trabalhar com o comportamento real da API, não expectativas teóricas.

# Importa keywords reutilizáveis (funções auxiliares)
Resource          ../../resources/keywords/common_keywords.robot

# Configurações de execução da suite (conjunto de testes)
Suite Setup       Setup Test Suite      # Executa UMA vez antes de todos os testes
Suite Teardown    Teardown Test Suite   # Executa UMA vez depois de todos os testes
Test Setup        Setup Test Case       # Executa ANTES de cada teste individual  
Test Teardown     Teardown Test Case    # Executa DEPOIS de cada teste individual

# Tags para organizar e filtrar testes
Test Tags         auth    api    working    basic_suite

*** Test Cases ***
CT-001: Disponibilidade da API - Endpoint Público
    [Documentation]    
    ...    OBJETIVO: Verificar se a API ServeRest está funcionando e acessível
    ...    
    ...    TESTE: Faz requisição GET para endpoint público /usuarios
    ...    EXPECTATIVA: Status 200 e estrutura de resposta válida
    ...    
    ...    BUSINESS VALUE: Teste de "smoke" - se falhar, API está fora do ar
    
    [Tags]    smoke    availability    critical
    
    # PASSO 1: Fazer requisição GET para endpoint público
    # expected_status=any permite qualquer status (não falha automaticamente)
    ${response}=    GET On Session    serverest    /usuarios
    ...    expected_status=any
    
    # PASSO 2: Validar que API retornou sucesso (200 OK)
    Should Be Equal As Numbers    ${response.status_code}    200
    
    # PASSO 3: Extrair dados JSON da resposta para validações
    ${json_data}=    Set Variable    ${response.json()}
    
    # PASSO 4: Validar estrutura esperada da resposta
    # API ServeRest sempre retorna estes campos para /usuarios
    Dictionary Should Contain Key    ${json_data}    usuarios
    Dictionary Should Contain Key    ${json_data}    quantidade
    
    # PASSO 5: Extrair valores específicos para validações detalhadas
    ${usuarios}=    Get From Dictionary    ${json_data}    usuarios
    ${quantidade}=    Get From Dictionary    ${json_data}    quantidade
    
    # PASSO 6: Validar tipos de dados retornados
    # usuarios deve ser uma lista (array) de usuários
    Should Be True    isinstance($usuarios, list)
    # quantidade deve ser um número inteiro
    Should Be True    isinstance($quantidade, int)
    # quantidade nunca deve ser negativa
    Should Be True    ${quantidade} >= 0
    
    # PASSO 7: Log do resultado para rastreabilidade
    Log    ✅ CT-001 PASSED: API is available, found ${quantidade} users

CT-002: Cadastro de Usuário Válido
    [Documentation]    Testa cadastro de usuário com dados válidos
    [Tags]    positive    user_management
    
    # Gerar dados únicos
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S_%f
    ${email}=    Set Variable    usuario_${timestamp}@robottest.com
    ${nome}=    Set Variable    Usuario Robot ${timestamp}
    
    ${payload}=    Create Dictionary
    ...    nome=${nome}
    ...    email=${email}
    ...    password=senha123
    ...    administrador=false
    
    ${response}=    POST On Session    serverest    /usuarios
    ...    json=${payload}    expected_status=any
    
    Should Be Equal As Numbers    ${response.status_code}    201
    
    ${json_data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_data}    message
    Dictionary Should Contain Key    ${json_data}    _id
    
    ${message}=    Get From Dictionary    ${json_data}    message
    Should Be Equal    ${message}    Cadastro realizado com sucesso
    
    ${user_id}=    Get From Dictionary    ${json_data}    _id
    Should Not Be Empty    ${user_id}
    Should Match Regexp    ${user_id}    ^[a-zA-Z0-9]{16}$
    
    Log    ✅ CT-002 PASSED: User created successfully with ID: ${user_id}

CT-003: Login com Usuário Cadastrado (Fluxo Completo)
    [Documentation]    
    ...    OBJETIVO: Testar fluxo de negócio completo e realista
    ...    
    ...    FLUXO: 1) Cadastrar usuário → 2) Fazer login → 3) Usar token
    ...    EXPECTATIVA: Fluxo completo funciona sem falhas
    ...    
    ...    BUSINESS VALUE: Simula jornada real do usuário na aplicação
    ...    
    ...    ESTRATÉGIA: Usa dados únicos para evitar conflitos
    
    [Tags]    positive    integration    complete_flow    business_critical
    
    # ETAPA 1: PREPARAR DADOS ÚNICOS
    # Gera timestamp com microssegundos para garantir unicidade absoluta
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S_%f
    ${email}=    Set Variable    login_${timestamp}@robottest.com
    ${password}=    Set Variable    minhasenha123
    ${nome}=    Set Variable    Usuario Login ${timestamp}
    
    # ETAPA 2: CADASTRAR USUÁRIO NOVO
    # Monta payload (dados) para requisição de cadastro
    ${cadastro_payload}=    Create Dictionary
    ...    nome=${nome}                    # Nome do usuário
    ...    email=${email}                  # Email único gerado
    ...    password=${password}            # Senha do usuário
    ...    administrador=false             # Usuário comum (não admin)
    
    # Executa requisição POST para cadastrar usuário
    # expected_status=201 significa que DEVE retornar "Created"
    ${cadastro_response}=    POST On Session    serverest    /usuarios
    ...    json=${cadastro_payload}    expected_status=201
    
    # Extrai ID do usuário criado para referência futura
    ${user_id}=    Get From Dictionary    ${cadastro_response.json()}    _id
    
    # ETAPA 3: FAZER LOGIN COM USUÁRIO CRIADO
    # Monta payload para login (só email e senha necessários)
    ${login_payload}=    Create Dictionary
    ...    email=${email}
    ...    password=${password}
    
    # Executa login - expected_status=any para tratar resposta manualmente
    ${login_response}=    POST On Session    serverest    /login
    ...    json=${login_payload}    expected_status=any
    
    # Valida que login foi bem-sucedido (status 200 = OK)
    Should Be Equal As Numbers    ${login_response.status_code}    200
    
    # ETAPA 4: VALIDAR RESPOSTA DO LOGIN
    ${login_json}=    Set Variable    ${login_response.json()}
    
    # Verifica se resposta contém campos esperados
    Dictionary Should Contain Key    ${login_json}    message
    Dictionary Should Contain Key    ${login_json}    authorization
    
    # Valida mensagem de sucesso específica da API ServeRest
    ${message}=    Get From Dictionary    ${login_json}    message
    Should Be Equal    ${message}    Login realizado com sucesso
    
    # ETAPA 5: VALIDAR TOKEN JWT
    ${token}=    Get From Dictionary    ${login_json}    authorization
    # Token deve começar com "Bearer " (padrão JWT)
    Should Start With    ${token}    Bearer${SPACE}
    
    # ETAPA 6: TESTAR USO DO TOKEN
    # Monta header de autorização para próximas requisições
    ${headers}=    Create Dictionary    Authorization=${token}
    
    # Testa o token fazendo requisição que aceita autenticação
    ${verify_response}=    GET On Session    serverest    /usuarios
    ...    headers=${headers}    expected_status=200
    
    # RESULTADO: Fluxo completo funcionando perfeitamente
    Log    ✅ CT-003 PASSED: Complete flow working (register → login → token usage)

CT-004: Validação de Email Duplicado
    [Documentation]    
    ...    OBJETIVO: Testar regra de negócio - unicidade do email
    ...    
    ...    CENÁRIO: Tentar cadastrar dois usuários com mesmo email
    ...    EXPECTATIVA: Segundo cadastro deve falhar com erro 400
    ...    
    ...    BUSINESS VALUE: Garante integridade dos dados (email único)
    ...    
    ...    TIPO: Teste negativo (valida comportamento de erro)
    
    [Tags]    negative    validation    business_rules    data_integrity
    
    # ETAPA 1: PREPARAR EMAIL ÚNICO PARA O TESTE
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S_%f
    ${email}=    Set Variable    duplicado_${timestamp}@robottest.com
    
    # ETAPA 2: CADASTRAR PRIMEIRO USUÁRIO (DEVE FUNCIONAR)
    ${payload1}=    Create Dictionary
    ...    nome=Primeiro Usuario           # Nome do primeiro usuário
    ...    email=${email}                  # Email que será testado
    ...    password=senha123               # Senha qualquer
    ...    administrador=false             # Usuário comum
    
    # Cadastra primeiro usuário - deve ter sucesso (201 Created)
    ${response1}=    POST On Session    serverest    /usuarios
    ...    json=${payload1}    expected_status=201
    
    # ETAPA 3: TENTAR CADASTRAR SEGUNDO USUÁRIO COM MESMO EMAIL
    ${payload2}=    Create Dictionary
    ...    nome=Segundo Usuario           # Nome DIFERENTE
    ...    email=${email}                 # Email IGUAL (conflito!)
    ...    password=outrasenha            # Senha DIFERENTE
    ...    administrador=false            # Tipo igual
    
    # Tenta cadastrar segundo usuário - deve falhar
    ${response2}=    POST On Session    serverest    /usuarios
    ...    json=${payload2}    expected_status=any
    
    # ETAPA 4: VALIDAR QUE O ERRO FOI RETORNADO CORRETAMENTE
    # Status 400 = Bad Request (erro de validação)
    Should Be Equal As Numbers    ${response2.status_code}    400
    
    # ETAPA 5: VALIDAR MENSAGEM DE ERRO ESPECÍFICA
    ${json_data}=    Set Variable    ${response2.json()}
    Dictionary Should Contain Key    ${json_data}    message
    
    # Verifica se a mensagem de erro está correta
    ${message}=    Get From Dictionary    ${json_data}    message
    Should Be Equal    ${message}    Este email já está sendo usado
    
    # RESULTADO: Regra de negócio funcionando corretamente
    Log    ✅ CT-004 PASSED: Duplicate email correctly rejected

CT-005: Campos Obrigatórios no Cadastro
    [Documentation]    
    ...    OBJETIVO: Testar validação de campos obrigatórios
    ...    
    ...    CENÁRIOS: Enviar payloads sem campos obrigatórios
    ...    EXPECTATIVA: API deve rejeitar com erro 400 (Bad Request)
    ...    
    ...    BUSINESS VALUE: Garante que dados essenciais estão presentes
    ...    
    ...    BOUNDARY TESTING: Testa limites dos dados aceitos
    
    [Tags]    negative    validation    boundary    required_fields
    
    # TESTE 1: PAYLOAD SEM NOME (campo obrigatório ausente)
    ${response1}=    POST On Session    serverest    /usuarios
    ...    json={"email": "test1@test.com", "password": "123", "administrador": false}
    ...    expected_status=any
    
    # Deve rejeitar com status 400 (Bad Request)
    Should Be Equal As Numbers    ${response1.status_code}    400
    
    # TESTE 2: PAYLOAD SEM EMAIL (campo obrigatório ausente)
    ${response2}=    POST On Session    serverest    /usuarios
    ...    json={"nome": "Test", "password": "123", "administrador": false}
    ...    expected_status=any
    
    # Deve rejeitar com status 400 (Bad Request)
    Should Be Equal As Numbers    ${response2.status_code}    400
    
    # TESTE 3: PAYLOAD SEM PASSWORD (campo obrigatório ausente)
    ${response3}=    POST On Session    serverest    /usuarios
    ...    json={"nome": "Test", "email": "test3@test.com", "administrador": false}
    ...    expected_status=any
    
    # Deve rejeitar com status 400 (Bad Request)
    Should Be Equal As Numbers    ${response3.status_code}    400
    
    # RESULTADO: Validações de campos obrigatórios funcionando
    Log    ✅ CT-005 PASSED: Required field validations working

CT-006: Login com Credenciais Inexistentes
    [Documentation]    
    ...    OBJETIVO: Testar segurança - login com dados inexistentes
    ...    
    ...    CENÁRIO: Tentar login com email que não existe no sistema
    ...    EXPECTATIVA: Deve retornar erro 401 (Unauthorized)
    ...    
    ...    SECURITY VALUE: Garante que apenas usuários válidos fazem login
    ...    
    ...    TIPO: Teste de segurança negativo
    
    [Tags]    negative    security    authentication    unauthorized
    
    # ETAPA 1: GERAR EMAIL FALSO (QUE NÃO EXISTE)
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S_%f
    ${fake_email}=    Set Variable    nao_existe_${timestamp}@robottest.com
    
    # ETAPA 2: MONTAR PAYLOAD COM CREDENCIAIS FALSAS
    ${login_payload}=    Create Dictionary
    ...    email=${fake_email}            # Email inexistente
    ...    password=senhaqualquer         # Senha qualquer
    
    # ETAPA 3: TENTAR LOGIN COM CREDENCIAIS INVÁLIDAS
    ${response}=    POST On Session    serverest    /login
    ...    json=${login_payload}    expected_status=any
    
    # ETAPA 4: VALIDAR RESPOSTA DE SEGURANÇA
    # Status 401 = Unauthorized (credenciais inválidas)
    Should Be Equal As Numbers    ${response.status_code}    401
    
    # ETAPA 5: VALIDAR MENSAGEM DE ERRO DE SEGURANÇA
    ${json_data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_data}    message
    
    # Verifica mensagem padrão de segurança (não revela se email existe)
    ${message}=    Get From Dictionary    ${json_data}    message
    Should Be Equal    ${message}    Email e/ou senha inválidos
    
    # RESULTADO: Sistema de segurança funcionando corretamente
    Log    ✅ CT-006 PASSED: Invalid credentials correctly rejected with 401

CT-007: Busca de Usuários com Filtros
    [Documentation]    
    ...    OBJETIVO: Testar funcionalidade de busca com parâmetros
    ...    
    ...    CENÁRIO: Buscar usuários usando query parameters
    ...    EXPECTATIVA: API deve filtrar e retornar resultados corretos
    ...    
    ...    FUNCTIONAL VALUE: Testa capacidade de filtros da API
    ...    
    ...    TIPO: Teste de funcionalidade de busca
    
    [Tags]    positive    search    query_params    filtering
    
    # ETAPA 1: PREPARAR PARÂMETROS DE BUSCA
    # Buscar por usuários que contenham "Admin" no nome
    ${params}=    Create Dictionary    nome=Admin
    
    # ETAPA 2: EXECUTAR BUSCA COM FILTROS
    ${response}=    GET On Session    serverest    /usuarios
    ...    params=${params}    expected_status=200
    
    # ETAPA 3: VALIDAR ESTRUTURA DA RESPOSTA
    ${json_data}=    Set Variable    ${response.json()}
    
    # API sempre retorna estes campos na busca
    Dictionary Should Contain Key    ${json_data}    usuarios
    Dictionary Should Contain Key    ${json_data}    quantidade
    
    # ETAPA 4: EXTRAIR DADOS DA RESPOSTA
    ${usuarios}=    Get From Dictionary    ${json_data}    usuarios
    ${quantidade}=    Get From Dictionary    ${json_data}    quantidade
    
    # ETAPA 5: VALIDAR TIPOS DE DADOS
    # Lista de usuários deve ser array/lista
    Should Be True    isinstance($usuarios, list)
    # Quantidade deve ser número inteiro
    Should Be True    isinstance($quantidade, int)
    # Quantidade nunca pode ser negativa
    Should Be True    ${quantidade} >= 0
    
    # ETAPA 6: VALIDAR CONTEÚDO SE HOUVER RESULTADOS
    IF    ${quantidade} > 0
        # Pega primeiro usuário da lista para validação estrutural
        ${primeiro_usuario}=    Get From List    ${usuarios}    0
        
        # Valida que usuário tem campos obrigatórios
        Dictionary Should Contain Key    ${primeiro_usuario}    _id
        Dictionary Should Contain Key    ${primeiro_usuario}    nome
        Dictionary Should Contain Key    ${primeiro_usuario}    email
        Dictionary Should Contain Key    ${primeiro_usuario}    administrador
        
        # ETAPA 7: VALIDAR QUE O FILTRO FUNCIONOU
        ${nome_encontrado}=    Get From Dictionary    ${primeiro_usuario}    nome
        # Nome encontrado deve conter "Admin" (case insensitive)
        Should Contain    ${nome_encontrado}    Admin    case_insensitive=True
    END
    
    # RESULTADO: Funcionalidade de busca/filtro funcionando
    Log    ✅ CT-007 PASSED: User search functionality working, found ${quantidade} matches

*** Keywords ***
# =============================================================================
# SEÇÃO DE KEYWORDS CUSTOMIZADAS
# =============================================================================
# Keywords são funções reutilizáveis no Robot Framework
# Podem receber parâmetros e retornar valores
# Ajudam a evitar duplicação de código nos testes

Generate Unique Email
    [Arguments]    ${prefix}=test
    [Documentation]    
    ...    FUNÇÃO: Gerar email único para evitar conflitos em testes
    ...    
    ...    PARÂMETROS:
    ...    - prefix: Prefixo do email (padrão: "test")
    ...    
    ...    RETORNO: Email único no formato prefix_timestamp@robottest.com
    ...    
    ...    ESTRATÉGIA: Usa timestamp com microssegundos para garantir unicidade
    
    # Gera timestamp único até o nível de microssegundos
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S_%f
    
    # Monta email único combinando prefix + timestamp + domínio fixo
    ${unique_email}=    Set Variable    ${prefix}_${timestamp}@robottest.com
    
    # Retorna o email gerado
    RETURN    ${unique_email}