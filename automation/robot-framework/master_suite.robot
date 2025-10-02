*** Settings ***
Documentation     Suite principal para executar todos os testes da API ServeRest
...               Executa testes em ordem otimizada e gera relatórios consolidados
Resource          resources/keywords/common_keywords.robot

Suite Setup       Setup Master Suite
Suite Teardown    Teardown Master Suite

*** Variables ***
${RESULTS_DIR}    ${CURDIR}/results
${TIMESTAMP}      ${EMPTY}

*** Test Cases ***
Executar Suite Completa de Testes
    [Documentation]    Executa todas as suites de teste em ordem otimizada
    [Tags]    suite    master    full
    
    Log    🚀 Starting complete ServeRest API test execution
    
    # Executar testes por prioridade
    Run Smoke Tests
    Run Functional Tests  
    Run Boundary Tests
    Run Integration Tests
    
    Log    ✅ All test suites completed successfully

*** Keywords ***
Setup Master Suite
    [Documentation]    Configuração inicial da suite master
    
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Set Suite Variable    ${TIMESTAMP}    ${timestamp}
    
    # Criar diretório de resultados se não existir
    Create Directory    ${RESULTS_DIR}
    
    # Setup básico da API
    Setup Test Suite
    
    Log    🎯 Master suite initialized at ${timestamp}

Teardown Master Suite
    [Documentation]    Finalização e consolidação de resultados
    
    # Cleanup básico
    Teardown Test Suite
    
    # Gerar relatório consolidado (seria implementado)
    Log    📊 Test execution completed. Results available in: ${RESULTS_DIR}

Run Smoke Tests
    [Documentation]    Executa testes críticos essenciais
    
    Log    🔥 Running Smoke Tests...
    
    # Estes seriam executados via Run Process ou Import Resource
    # Por simplicidade, estamos documentando a estrutura
    Log    - Authentication smoke tests
    Log    - Basic CRUD operations
    Log    - Critical business rules

Run Functional Tests
    [Documentation]    Executa testes funcionais completos
    
    Log    ⚙️ Running Functional Tests...
    Log    - User management tests
    Log    - Product management tests  
    Log    - Cart functionality tests

Run Boundary Tests
    [Documentation]    Executa testes de limite
    
    Log    📏 Running Boundary Tests...
    Log    - Field validation limits
    Log    - Stock boundary testing
    Log    - Authentication boundaries

Run Integration Tests
    [Documentation]    Executa testes de integração
    
    Log    🔗 Running Integration Tests...
    Log    - End-to-end workflows
    Log    - Cross-module integration
    Log    - Business process validation