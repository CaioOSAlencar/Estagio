*** Settings ***
Documentation     Biblioteca de recursos para testes da API ServeRest
...               Contém keywords reutilizáveis e configurações globais
Library           RequestsLibrary
Library           Collections
Library           OperatingSystem
Library           DateTime
Variables         ../variables/global_vars.py

*** Variables ***
${BASE_URL}           https://serverest.dev
${TIMEOUT}            10
${ADMIN_USER}         ${EMPTY}
${ADMIN_TOKEN}        ${EMPTY}
${REGULAR_USER}       ${EMPTY}
${REGULAR_TOKEN}      ${EMPTY}

*** Keywords ***
# ==============================================================================
# SETUP E TEARDOWN KEYWORDS
# ==============================================================================

Setup Test Suite
    [Documentation]    Configuração inicial para a suite de testes
    Create Session    serverest    ${BASE_URL}    timeout=${TIMEOUT}
    Log    Session created for ${BASE_URL}

Teardown Test Suite  
    [Documentation]    Limpeza após a suite de testes
    Delete All Sessions
    Log    All sessions deleted

Setup Test Case
    [Documentation]    Configuração para cada caso de teste
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Set Test Variable    ${TEST_TIMESTAMP}    ${timestamp}
    Log    Test started at ${timestamp}

Teardown Test Case
    [Documentation]    Limpeza após cada caso de teste  
    Run Keyword If Test Failed    Log Response Details
    Log    Test completed

# ==============================================================================
# AUTHENTICATION KEYWORDS
# ==============================================================================

Fazer Login
    [Arguments]    ${email}    ${password}
    [Documentation]    Realiza login e retorna o token de autorização
    
    ${payload}=    Create Dictionary    
    ...    email=${email}    
    ...    password=${password}
    
    ${response}=    POST On Session    serverest    /login    
    ...    json=${payload}    expected_status=any
    
    Log    Login request for ${email}: Status ${response.status_code}
    
    IF    ${response.status_code} == 200
        ${token}=    Get From Dictionary    ${response.json()}    authorization
        Log    Token obtained successfully
        RETURN    ${token}
    ELSE
        Log    Login failed: ${response.json()}
        Fail    Login failed with status ${response.status_code}
    END

Fazer Login Admin
    [Documentation]    Faz login com usuário administrador padrão
    
    # Primeiro, cadastra um usuário admin se necessário
    ${admin_email}=    Set Variable    admin@teste.com
    ${admin_password}=    Set Variable    123456
    
    # Tenta fazer login primeiro
    ${login_result}=    Run Keyword And Return Status    
    ...    ${token}=    Fazer Login    ${admin_email}    ${admin_password}
    
    IF    not ${login_result}
        # Se login falhou, cadastra o usuário admin
        Log    Admin user not found, creating...
        Cadastrar Usuario Admin    ${admin_email}    ${admin_password}
        ${token}=    Fazer Login    ${admin_email}    ${admin_password}
    END
    
    Set Suite Variable    ${ADMIN_TOKEN}    ${token}
    Set Suite Variable    ${ADMIN_USER}    ${admin_email}
    Log    Admin logged in successfully
    RETURN    ${token}

Fazer Login Usuario Regular
    [Documentation]    Faz login com usuário regular padrão
    
    ${user_email}=    Set Variable    user@teste.com  
    ${user_password}=    Set Variable    123456
    
    # Tenta fazer login primeiro
    ${login_result}=    Run Keyword And Return Status
    ...    ${token}=    Fazer Login    ${user_email}    ${user_password}
    
    IF    not ${login_result}
        # Se login falhou, cadastra o usuário
        Log    Regular user not found, creating...
        Cadastrar Usuario Regular    ${user_email}    ${user_password}
        ${token}=    Fazer Login    ${user_email}    ${user_password}
    END
    
    Set Suite Variable    ${REGULAR_TOKEN}    ${token}
    Set Suite Variable    ${REGULAR_USER}    ${user_email}
    Log    Regular user logged in successfully
    RETURN    ${token}

Validar Token Expirado
    [Arguments]    ${token}    ${endpoint}=/carrinhos
    [Documentation]    Valida que um token expirado retorna 401
    
    ${headers}=    Create Dictionary    Authorization=${token}
    
    ${response}=    GET On Session    serverest    ${endpoint}
    ...    headers=${headers}    expected_status=401
    
    Should Be Equal As Numbers    ${response.status_code}    401
    ${message}=    Get From Dictionary    ${response.json()}    message
    Should Contain    ${message}    token
    Log    Token expiration validated successfully

# ==============================================================================  
# USER MANAGEMENT KEYWORDS
# ==============================================================================

Cadastrar Usuario Admin
    [Arguments]    ${email}    ${password}    ${nome}=Admin Teste
    [Documentation]    Cadastra um novo usuário administrador
    
    ${payload}=    Create Dictionary
    ...    nome=${nome}
    ...    email=${email}  
    ...    password=${password}
    ...    administrador=true
    
    ${response}=    POST On Session    serverest    /usuarios
    ...    json=${payload}    expected_status=any
    
    IF    ${response.status_code} == 201
        ${user_id}=    Get From Dictionary    ${response.json()}    _id
        Log    Admin user created with ID: ${user_id}
        RETURN    ${user_id}
    ELSE IF    ${response.status_code} == 400
        Log    User already exists or validation error
        RETURN    ${EMPTY}
    ELSE
        Fail    Failed to create admin user: ${response.status_code}
    END

Cadastrar Usuario Regular
    [Arguments]    ${email}    ${password}    ${nome}=Usuario Teste
    [Documentation]    Cadastra um novo usuário regular
    
    ${payload}=    Create Dictionary
    ...    nome=${nome}
    ...    email=${email}
    ...    password=${password}  
    ...    administrador=false
    
    ${response}=    POST On Session    serverest    /usuarios
    ...    json=${payload}    expected_status=any
    
    IF    ${response.status_code} == 201
        ${user_id}=    Get From Dictionary    ${response.json()}    _id
        Log    Regular user created with ID: ${user_id}
        RETURN    ${user_id}
    ELSE IF    ${response.status_code} == 400
        Log    User already exists or validation error
        RETURN    ${EMPTY}
    ELSE
        Fail    Failed to create regular user: ${response.status_code}
    END

Buscar Usuario Por Email
    [Arguments]    ${email}
    [Documentation]    Busca usuário pelo email
    
    ${params}=    Create Dictionary    email=${email}
    ${response}=    GET On Session    serverest    /usuarios
    ...    params=${params}    expected_status=200
    
    ${usuarios}=    Get From Dictionary    ${response.json()}    usuarios
    ${quantidade}=    Get From Dictionary    ${response.json()}    quantidade
    
    IF    ${quantidade} > 0
        ${usuario}=    Get From List    ${usuarios}    0
        RETURN    ${usuario}
    ELSE
        RETURN    ${None}
    END

Deletar Usuario Por ID
    [Arguments]    ${user_id}    ${token}=${ADMIN_TOKEN}
    [Documentation]    Deleta usuário pelo ID (requer token admin)
    
    ${headers}=    Create Dictionary    Authorization=${token}
    
    ${response}=    DELETE On Session    serverest    /usuarios/${user_id}
    ...    headers=${headers}    expected_status=any
    
    Log    Delete user ${user_id}: Status ${response.status_code}
    RETURN    ${response.status_code}

# ==============================================================================
# PRODUCT MANAGEMENT KEYWORDS  
# ==============================================================================

Cadastrar Produto
    [Arguments]    ${nome}    ${preco}    ${descricao}    ${quantidade}    ${token}=${ADMIN_TOKEN}
    [Documentation]    Cadastra um novo produto (requer token admin)
    
    ${payload}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${preco}
    ...    descricao=${descricao}
    ...    quantidade=${quantidade}
    
    ${headers}=    Create Dictionary    Authorization=${token}
    
    ${response}=    POST On Session    serverest    /produtos
    ...    json=${payload}    headers=${headers}    expected_status=any
    
    IF    ${response.status_code} == 201
        ${produto_id}=    Get From Dictionary    ${response.json()}    _id
        Log    Product created with ID: ${produto_id}
        RETURN    ${produto_id}
    ELSE
        Log    Failed to create product: ${response.json()}
        Fail    Product creation failed with status ${response.status_code}
    END

Buscar Produto Por Nome
    [Arguments]    ${nome}
    [Documentation]    Busca produto pelo nome
    
    ${params}=    Create Dictionary    nome=${nome}
    ${response}=    GET On Session    serverest    /produtos
    ...    params=${params}    expected_status=200
    
    ${produtos}=    Get From Dictionary    ${response.json()}    produtos
    ${quantidade}=    Get From Dictionary    ${response.json()}    quantidade
    
    IF    ${quantidade} > 0
        ${produto}=    Get From List    ${produtos}    0
        RETURN    ${produto}
    ELSE
        RETURN    ${None}
    END

Deletar Produto Por ID
    [Arguments]    ${produto_id}    ${token}=${ADMIN_TOKEN}
    [Documentation]    Deleta produto pelo ID (requer token admin)
    
    ${headers}=    Create Dictionary    Authorization=${token}
    
    ${response}=    DELETE On Session    serverest    /produtos/${produto_id}
    ...    headers=${headers}    expected_status=any
    
    Log    Delete product ${produto_id}: Status ${response.status_code}
    RETURN    ${response.status_code}

Obter Estoque Produto
    [Arguments]    ${produto_id}
    [Documentation]    Obtém a quantidade em estoque de um produto
    
    ${response}=    GET On Session    serverest    /produtos/${produto_id}
    ...    expected_status=200
    
    ${produto}=    Set Variable    ${response.json()}
    ${estoque}=    Get From Dictionary    ${produto}    quantidade
    RETURN    ${estoque}

# ==============================================================================
# CART MANAGEMENT KEYWORDS
# ==============================================================================

Adicionar Produto Ao Carrinho
    [Arguments]    ${produto_id}    ${quantidade}    ${token}=${REGULAR_TOKEN}
    [Documentation]    Adiciona produto ao carrinho do usuário
    
    ${produtos_list}=    Create List
    ${produto_item}=    Create Dictionary
    ...    idProduto=${produto_id}
    ...    quantidade=${quantidade}
    
    Append To List    ${produtos_list}    ${produto_item}
    
    ${payload}=    Create Dictionary    produtos=${produtos_list}
    ${headers}=    Create Dictionary    Authorization=${token}
    
    ${response}=    POST On Session    serverest    /carrinhos
    ...    json=${payload}    headers=${headers}    expected_status=any
    
    Log    Add to cart: Product ${produto_id}, Qty ${quantidade}, Status ${response.status_code}
    RETURN    ${response}

Obter Carrinho Atual
    [Arguments]    ${token}=${REGULAR_TOKEN}
    [Documentation]    Obtém o carrinho atual do usuário
    
    ${headers}=    Create Dictionary    Authorization=${token}
    
    ${response}=    GET On Session    serverest    /carrinhos
    ...    headers=${headers}    expected_status=any
    
    RETURN    ${response}

Finalizar Compra
    [Arguments]    ${token}=${REGULAR_TOKEN}
    [Documentation]    Finaliza a compra do carrinho atual
    
    ${headers}=    Create Dictionary    Authorization=${token}
    
    ${response}=    DELETE On Session    serverest    /carrinhos/concluir-compra
    ...    headers=${headers}    expected_status=any
    
    Log    Purchase completed: Status ${response.status_code}
    RETURN    ${response}

Cancelar Compra
    [Arguments]    ${token}=${REGULAR_TOKEN}
    [Documentation]    Cancela a compra do carrinho atual
    
    ${headers}=    Create Dictionary    Authorization=${token}
    
    ${response}=    DELETE On Session    serverest    /carrinhos/cancelar-compra
    ...    headers=${headers}    expected_status=any
    
    Log    Purchase cancelled: Status ${response.status_code}
    RETURN    ${response}

# ==============================================================================
# VALIDATION KEYWORDS
# ==============================================================================

Validar Response Status
    [Arguments]    ${response}    ${expected_status}
    [Documentation]    Valida o status code da resposta
    
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}
    Log    Status code ${response.status_code} matches expected ${expected_status}

Validar Response Contem Campo
    [Arguments]    ${response}    ${campo}
    [Documentation]    Valida que a resposta contém um campo específico
    
    ${json_data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_data}    ${campo}
    Log    Response contains required field: ${campo}

Validar Response Message
    [Arguments]    ${response}    ${expected_message}
    [Documentation]    Valida a mensagem na resposta
    
    ${json_data}=    Set Variable    ${response.json()}
    ${message}=    Get From Dictionary    ${json_data}    message
    Should Be Equal    ${message}    ${expected_message}
    Log    Message validated: ${message}

Validar Token Format
    [Arguments]    ${token}
    [Documentation]    Valida o formato do token JWT
    
    Should Start With    ${token}    Bearer ${SPACE}
    ${jwt_part}=    Split String    ${token}    ${SPACE}
    ${jwt}=    Get From List    ${jwt_part}    1
    Should Not Be Empty    ${jwt}
    Log    Token format is valid: Bearer + JWT

# ==============================================================================
# UTILITY KEYWORDS
# ==============================================================================

Generate Unique Email
    [Arguments]    ${prefix}=test
    [Documentation]    Gera um email único baseado no timestamp
    
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${unique_email}=    Set Variable    ${prefix}_${timestamp}@teste.com
    RETURN    ${unique_email}

Generate Unique Product Name
    [Arguments]    ${prefix}=Produto
    [Documentation]    Gera um nome único para produto
    
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${unique_name}=    Set Variable    ${prefix} ${timestamp}
    RETURN    ${unique_name}

Log Response Details
    [Documentation]    Log detalhado da resposta para debug
    
    ${response}=    Get Variable Value    ${response}    ${None}
    IF    ${response} != ${None}
        Log    Response Status: ${response.status_code}
        Log    Response Headers: ${response.headers}
        Log    Response Body: ${response.text}
    END

Wait For Condition
    [Arguments]    ${keyword}    ${timeout}=30s    ${retry_interval}=1s
    [Documentation]    Executa keyword até que seja bem-sucedida ou timeout
    
    ${end_time}=    Add Time To Date    ${CURDIR}    ${timeout}
    
    WHILE    True
        ${status}=    Run Keyword And Return Status    ${keyword}
        IF    ${status}
            BREAK
        END
        
        ${current_time}=    Get Current Date
        IF    "${current_time}" > "${end_time}"
            Fail    Timeout waiting for condition
        END
        
        Sleep    ${retry_interval}
    END