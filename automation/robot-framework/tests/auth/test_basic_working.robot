*** Settings ***
Documentation     Testes Básicos da API ServeRest - Validação dos Comportamentos Conhecidos
...               Foca apenas nos comportamentos que conseguimos validar com segurança
Resource          ../../resources/keywords/common_keywords.robot
Suite Setup       Setup Test Suite  
Suite Teardown    Teardown Test Suite
Test Setup        Setup Test Case
Test Teardown     Teardown Test Case
Test Tags         auth    api    working

*** Test Cases ***
CT-001: Disponibilidade da API - Endpoint Público
    [Documentation]    Valida que a API está disponível e o endpoint /usuarios funciona
    [Tags]    smoke    availability
    
    ${response}=    GET On Session    serverest    /usuarios
    ...    expected_status=any
    
    Should Be Equal As Numbers    ${response.status_code}    200
    
    ${json_data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_data}    usuarios
    Dictionary Should Contain Key    ${json_data}    quantidade
    
    ${usuarios}=    Get From Dictionary    ${json_data}    usuarios
    ${quantidade}=    Get From Dictionary    ${json_data}    quantidade
    
    Should Be True    isinstance($usuarios, list)
    Should Be True    isinstance($quantidade, int)
    Should Be True    ${quantidade} >= 0
    
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
    [Documentation]    Cadastra usuário e testa login - fluxo realista
    [Tags]    positive    integration    complete_flow
    
    # Step 1: Cadastrar usuário único
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S_%f
    ${email}=    Set Variable    login_${timestamp}@robottest.com
    ${password}=    Set Variable    minhasenha123
    ${nome}=    Set Variable    Usuario Login ${timestamp}
    
    ${cadastro_payload}=    Create Dictionary
    ...    nome=${nome}
    ...    email=${email}
    ...    password=${password}
    ...    administrador=false
    
    ${cadastro_response}=    POST On Session    serverest    /usuarios
    ...    json=${cadastro_payload}    expected_status=201
    
    ${user_id}=    Get From Dictionary    ${cadastro_response.json()}    _id
    
    # Step 2: Fazer login com usuário criado
    ${login_payload}=    Create Dictionary
    ...    email=${email}
    ...    password=${password}
    
    ${login_response}=    POST On Session    serverest    /login
    ...    json=${login_payload}    expected_status=any
    
    Should Be Equal As Numbers    ${login_response.status_code}    200
    
    ${login_json}=    Set Variable    ${login_response.json()}
    Dictionary Should Contain Key    ${login_json}    message
    Dictionary Should Contain Key    ${login_json}    authorization
    
    ${message}=    Get From Dictionary    ${login_json}    message
    Should Be Equal    ${message}    Login realizado com sucesso
    
    ${token}=    Get From Dictionary    ${login_json}    authorization
    Should Start With    ${token}    Bearer${SPACE}
    
    # Step 3: Usar token em endpoint que aceita autenticação (opcional)
    ${headers}=    Create Dictionary    Authorization=${token}
    ${verify_response}=    GET On Session    serverest    /usuarios
    ...    headers=${headers}    expected_status=200
    
    Log    ✅ CT-003 PASSED: Complete flow working (register → login → token usage)

CT-004: Validação de Email Duplicado
    [Documentation]    Testa que não é possível cadastrar email duplicado
    [Tags]    negative    validation    business_rules
    
    # Cadastrar usuário inicial
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S_%f
    ${email}=    Set Variable    duplicado_${timestamp}@robottest.com
    
    ${payload1}=    Create Dictionary
    ...    nome=Primeiro Usuario
    ...    email=${email}
    ...    password=senha123
    ...    administrador=false
    
    ${response1}=    POST On Session    serverest    /usuarios
    ...    json=${payload1}    expected_status=201
    
    # Tentar cadastrar com mesmo email
    ${payload2}=    Create Dictionary
    ...    nome=Segundo Usuario
    ...    email=${email}
    ...    password=outrasenha
    ...    administrador=false
    
    ${response2}=    POST On Session    serverest    /usuarios
    ...    json=${payload2}    expected_status=any
    
    Should Be Equal As Numbers    ${response2.status_code}    400
    
    ${json_data}=    Set Variable    ${response2.json()}
    Dictionary Should Contain Key    ${json_data}    message
    ${message}=    Get From Dictionary    ${json_data}    message
    Should Be Equal    ${message}    Este email já está sendo usado
    
    Log    ✅ CT-004 PASSED: Duplicate email correctly rejected

CT-005: Campos Obrigatórios no Cadastro
    [Documentation]    Valida que campos obrigatórios são validados
    [Tags]    negative    validation    boundary
    
    # Test 1: Nome vazio
    ${response1}=    POST On Session    serverest    /usuarios
    ...    json={"email": "test1@test.com", "password": "123", "administrador": false}
    ...    expected_status=any
    
    Should Be Equal As Numbers    ${response1.status_code}    400
    
    # Test 2: Email vazio  
    ${response2}=    POST On Session    serverest    /usuarios
    ...    json={"nome": "Test", "password": "123", "administrador": false}
    ...    expected_status=any
    
    Should Be Equal As Numbers    ${response2.status_code}    400
    
    # Test 3: Password vazio
    ${response3}=    POST On Session    serverest    /usuarios
    ...    json={"nome": "Test", "email": "test3@test.com", "administrador": false}
    ...    expected_status=any
    
    Should Be Equal As Numbers    ${response3.status_code}    400
    
    Log    ✅ CT-005 PASSED: Required field validations working

CT-006: Login com Credenciais Inexistentes
    [Documentation]    Valida comportamento para credenciais que não existem
    [Tags]    negative    security
    
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S_%f
    ${fake_email}=    Set Variable    nao_existe_${timestamp}@robottest.com
    
    ${login_payload}=    Create Dictionary
    ...    email=${fake_email}
    ...    password=senhaqualquer
    
    ${response}=    POST On Session    serverest    /login
    ...    json=${login_payload}    expected_status=any
    
    # API retorna 401 para credenciais inválidas
    Should Be Equal As Numbers    ${response.status_code}    401
    
    ${json_data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_data}    message
    ${message}=    Get From Dictionary    ${json_data}    message
    Should Be Equal    ${message}    Email e/ou senha inválidos
    
    Log    ✅ CT-006 PASSED: Invalid credentials correctly rejected with 401

CT-007: Busca de Usuários com Filtros
    [Documentation]    Testa funcionalidade de busca/filtro na API
    [Tags]    positive    search    query_params
    
    # Buscar usuários com query específica
    ${params}=    Create Dictionary    nome=Admin
    ${response}=    GET On Session    serverest    /usuarios
    ...    params=${params}    expected_status=200
    
    ${json_data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_data}    usuarios
    Dictionary Should Contain Key    ${json_data}    quantidade
    
    ${usuarios}=    Get From Dictionary    ${json_data}    usuarios
    ${quantidade}=    Get From Dictionary    ${json_data}    quantidade
    
    # Validar estrutura da resposta
    Should Be True    isinstance($usuarios, list)
    Should Be True    isinstance($quantidade, int)
    Should Be True    ${quantidade} >= 0
    
    # Se encontrou usuários, validar estrutura de um item
    IF    ${quantidade} > 0
        ${primeiro_usuario}=    Get From List    ${usuarios}    0
        Dictionary Should Contain Key    ${primeiro_usuario}    _id
        Dictionary Should Contain Key    ${primeiro_usuario}    nome
        Dictionary Should Contain Key    ${primeiro_usuario}    email
        Dictionary Should Contain Key    ${primeiro_usuario}    administrador
        
        ${nome_encontrado}=    Get From Dictionary    ${primeiro_usuario}    nome
        Should Contain    ${nome_encontrado}    Admin    case_insensitive=True
    END
    
    Log    ✅ CT-007 PASSED: User search functionality working, found ${quantidade} matches

*** Keywords ***
Generate Unique Email
    [Arguments]    ${prefix}=test
    [Documentation]    Gera email único com timestamp para evitar conflitos
    
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S_%f
    ${unique_email}=    Set Variable    ${prefix}_${timestamp}@robottest.com
    RETURN    ${unique_email}