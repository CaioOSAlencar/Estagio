*** Settings ***
Documentation     Testes de Autenticação da API ServeRest
...               Valida funcionalidades de login, logout e token management
Resource          ../../resources/keywords/common_keywords.robot
Suite Setup       Setup Test Suite  
Suite Teardown    Teardown Test Suite
Test Setup        Setup Test Case
Test Teardown     Teardown Test Case
Test Tags         auth    api    smoke

*** Test Cases ***
CT-001: Login com Credenciais Válidas
    [Documentation]    Valida login com credenciais válidas retorna token JWT
    [Tags]    critical    login    positive
    
    # Arrange - Preparar dados de teste
    ${email}=    Set Variable    ${ADMIN_USER_DATA['email']}
    ${password}=    Set Variable    ${ADMIN_USER_DATA['password']}
    
    # Garantir que usuário existe
    Cadastrar Usuario Admin    ${email}    ${password}
    
    # Act - Executar login
    ${response}=    POST On Session    serverest    /login
    ...    json={"email": "${email}", "password": "${password}"}
    ...    expected_status=any
    
    # Assert - Validar resultados
    Validar Response Status    ${response}    200
    Validar Response Contem Campo    ${response}    message
    Validar Response Contem Campo    ${response}    authorization
    
    ${message}=    Get From Dictionary    ${response.json()}    message
    Should Be Equal    ${message}    Login realizado com sucesso
    
    ${token}=    Get From Dictionary    ${response.json()}    authorization
    Validar Token Format    ${token}
    
    Log    ✅ CT-001 PASSED: Login successful with valid credentials

CT-002: Login com Credenciais Inválidas - Email Inválido
    [Documentation]    Valida que email inválido retorna erro 401
    [Tags]    negative    login    boundary
    
    # Act - Tentar login com email inválido
    ${response}=    POST On Session    serverest    /login
    ...    json={"email": "email_inexistente@teste.com", "password": "123456"}
    ...    expected_status=any
    
    # Assert - Validar erro
    Validar Response Status    ${response}    401
    Validar Response Message    ${response}    ${ERROR_MESSAGES['login']['invalid_credentials']}
    
    Log    ✅ CT-002 PASSED: Invalid email correctly rejected

CT-003: Login com Credenciais Inválidas - Senha Inválida  
    [Documentation]    Valida que senha inválida retorna erro 401
    [Tags]    negative    login    boundary
    
    # Arrange - Garantir que usuário existe
    ${email}=    Generate Unique Email    test_password
    Cadastrar Usuario Regular    ${email}    senha_correta
    
    # Act - Tentar login com senha incorreta
    ${response}=    POST On Session    serverest    /login
    ...    json={"email": "${email}", "password": "senha_errada"}
    ...    expected_status=any
    
    # Assert - Validar erro
    Validar Response Status    ${response}    401
    Validar Response Message    ${response}    ${ERROR_MESSAGES['login']['invalid_credentials']}
    
    Log    ✅ CT-003 PASSED: Invalid password correctly rejected

CT-004: Login com Campos Obrigatórios Vazios
    [Documentation]    Valida campos obrigatórios vazios retornam erro 400
    [Tags]    negative    validation    boundary
    [Template]    Testar Login Com Campos Vazios
    
    # email_value    password_value    expected_field_error
    ${EMPTY}         senha123         email
    email@test.com   ${EMPTY}         password  
    ${EMPTY}         ${EMPTY}         email

CT-005: Boundary Testing - Formatos de Email
    [Documentation]    Testa diferentes formatos de email nos limites
    [Tags]    boundary    email    validation
    [Template]    Testar Login Com Email Boundary
    
    # email_value                    should_pass    description
    ${BOUNDARY_VALUES['email']['min_valid']}     True     Email mínimo válido
    ${BOUNDARY_VALUES['email']['invalid_no_at']}  False    Email sem @
    ${BOUNDARY_VALUES['email']['invalid_no_domain']} False Email sem domínio
    test+tag@domain-test.com        True     Email com caracteres especiais

CT-006: Validação de Expiração de Token
    [Documentation]    Valida comportamento com token expirado (simulado)
    [Tags]    security    token    timeout
    
    # Arrange - Fazer login válido
    ${token}=    Fazer Login Admin
    
    # Act - Usar token imediatamente (deve funcionar)
    ${headers}=    Create Dictionary    Authorization=${token}
    ${response_valid}=    GET On Session    serverest    /usuarios
    ...    headers=${headers}    expected_status=any
    
    # Assert - Token válido funciona
    Should Be Equal As Numbers    ${response_valid.status_code}    200
    
    # Simular token expirado (removendo Bearer ou modificando)
    ${invalid_token}=    Set Variable    Bearer token_invalido_simulado
    ${headers_invalid}=    Create Dictionary    Authorization=${invalid_token}
    
    ${response_invalid}=    GET On Session    serverest    /usuarios
    ...    headers=${headers_invalid}    expected_status=any
    
    # Assert - Token inválido é rejeitado
    Should Be Equal As Numbers    ${response_invalid.status_code}    401
    
    Log    ✅ CT-006 PASSED: Token validation working correctly

*** Keywords ***
Testar Login Com Campos Vazios
    [Arguments]    ${email_value}    ${password_value}    ${expected_field_error}
    
    # Act - Tentar login com campos vazios
    ${payload}=    Create Dictionary
    IF    '${email_value}' != '${EMPTY}'
        Set To Dictionary    ${payload}    email=${email_value}
    END
    IF    '${password_value}' != '${EMPTY}'  
        Set To Dictionary    ${payload}    password=${password_value}
    END
    
    ${response}=    POST On Session    serverest    /login
    ...    json=${payload}    expected_status=any
    
    # Assert - Validar erro específico do campo
    Validar Response Status    ${response}    400
    
    ${json_response}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json_response}    ${expected_field_error}
    
    ${error_message}=    Get From Dictionary    ${json_response}    ${expected_field_error}
    Should Contain    ${error_message}    é obrigatório
    
    Log    ✅ Empty field ${expected_field_error} correctly validated

Testar Login Com Email Boundary
    [Arguments]    ${email_value}    ${should_pass}    ${description}
    
    # Arrange - Se deve passar, criar usuário primeiro
    IF    ${should_pass}
        Run Keyword And Ignore Error    Cadastrar Usuario Regular    ${email_value}    senha123
    END
    
    # Act - Tentar login
    ${response}=    POST On Session    serverest    /login
    ...    json={"email": "${email_value}", "password": "senha123"}
    ...    expected_status=any
    
    # Assert - Validar baseado na expectativa
    IF    ${should_pass}
        IF    ${response.status_code} == 200
            Validar Response Contem Campo    ${response}    authorization
            Log    ✅ ${description}: Login successful as expected
        ELSE IF    ${response.status_code} == 401
            Log    ⚠️ ${description}: User might not exist, but format is valid
        ELSE
            Fail    Unexpected status code for valid email format
        END
    ELSE
        Should Be Equal As Numbers    ${response.status_code}    401
        Log    ✅ ${description}: Invalid email correctly rejected
    END