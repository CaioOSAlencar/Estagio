*** Settings ***
Documentation     Testes de Carrinho da API ServeRest - Boundary Testing
...               Foco em testes de limite, especialmente validação de estoque
Resource          ../../resources/keywords/common_keywords.robot
Suite Setup       Setup Suite Carrinho
Suite Teardown    Teardown Suite Carrinho  
Test Setup        Setup Test Case
Test Teardown     Teardown Test Case
Test Tags         cart    boundary    critical

*** Variables ***
${PRODUTO_ID}         ${EMPTY}
${PRODUTO_ESTOQUE_5}  ${EMPTY}
${PRODUTO_ESTOQUE_0}  ${EMPTY}
${PRODUTO_ESTOQUE_1}  ${EMPTY}

*** Test Cases ***
CT-015: Boundary Testing - Validação de Estoque no Carrinho
    [Documentation]    Testa limites de estoque ao adicionar produtos no carrinho
    [Tags]    boundary    stock    critical
    
    Log    🧪 Starting comprehensive boundary testing for cart stock validation
    
    # Cenário 1: Quantidade = Estoque (deve passar)
    Log    📋 Scenario 1: Quantity = Stock (should pass)
    ${response_valid}=    Adicionar Produto Ao Carrinho    ${PRODUTO_ESTOQUE_5}    5
    Validar Response Status    ${response_valid}    201
    Validar Response Message    ${response_valid}    Cadastro realizado com sucesso
    
    # Limpar carrinho
    Cancelar Compra
    
    # Cenário 2: Quantidade = Estoque + 1 (deve falhar)  
    Log    📋 Scenario 2: Quantity = Stock + 1 (should fail)
    ${response_over}=    Adicionar Produto Ao Carrinho    ${PRODUTO_ESTOQUE_5}    6
    Validar Response Status    ${response_over}    400
    
    # Verificar que nenhum carrinho foi criado
    ${carrinho_response}=    Obter Carrinho Atual
    Should Be Equal As Numbers    ${carrinho_response.status_code}    200
    ${carrinhos}=    Get From Dictionary    ${carrinho_response.json()}    carrinhos
    Should Be Empty    ${carrinhos}
    
    # Cenário 3: Quantidade muito maior que estoque (deve falhar)
    Log    📋 Scenario 3: Quantity >> Stock (should fail)
    ${response_way_over}=    Adicionar Produto Ao Carrinho    ${PRODUTO_ESTOQUE_5}    100
    Validar Response Status    ${response_way_over}    400
    
    # Cenário 4: Produto sem estoque (deve falhar)
    Log    📋 Scenario 4: Zero stock product (should fail)
    ${response_no_stock}=    Adicionar Produto Ao Carrinho    ${PRODUTO_ESTOQUE_0}    1
    Validar Response Status    ${response_no_stock}    400
    
    # Cenário 5: Limite mínimo válido (estoque=1, quantidade=1)
    Log    📋 Scenario 5: Minimum valid limit (stock=1, qty=1)
    ${response_min_valid}=    Adicionar Produto Ao Carrinho    ${PRODUTO_ESTOQUE_1}    1
    Validar Response Status    ${response_min_valid}    201
    
    Log    ✅ CT-015 PASSED: All boundary scenarios validated correctly

CT-016: Integração - Fluxo Completo de Compra com Validação de Estoque
    [Documentation]    Testa fluxo completo: add carrinho → verificar estoque → finalizar → validar redução
    [Tags]    integration    stock    workflow
    
    Log    🛒 Testing complete purchase flow with stock validation
    
    # Arrange - Verificar estoque inicial
    ${estoque_inicial}=    Obter Estoque Produto    ${PRODUTO_ESTOQUE_5}
    Log    Initial stock: ${estoque_inicial}
    
    # Act - Adicionar ao carrinho
    ${response_add}=    Adicionar Produto Ao Carrinho    ${PRODUTO_ESTOQUE_5}    2
    Validar Response Status    ${response_add}    201
    
    # Verificar que estoque não foi alterado ainda (apenas reservado)
    ${estoque_apos_add}=    Obter Estoque Produto    ${PRODUTO_ESTOQUE_5}
    Should Be Equal As Numbers    ${estoque_apos_add}    ${estoque_inicial}
    
    # Finalizar compra
    ${response_finish}=    Finalizar Compra
    Validar Response Status    ${response_finish}    200
    
    # Verificar que estoque foi reduzido
    ${estoque_final}=    Obter Estoque Produto    ${PRODUTO_ESTOQUE_5}
    ${estoque_esperado}=    Evaluate    ${estoque_inicial} - 2
    Should Be Equal As Numbers    ${estoque_final}    ${estoque_esperado}
    
    Log    ✅ CT-016 PASSED: Purchase flow and stock reduction working correctly

CT-017: Integração - Cancelamento de Compra com Reabastecimento
    [Documentation]    Testa cancelamento de compra e reabastecimento do estoque
    [Tags]    integration    cancel    stock
    
    Log    🔄 Testing purchase cancellation with stock replenishment
    
    # Arrange - Verificar estoque inicial
    ${estoque_inicial}=    Obter Estoque Produto    ${PRODUTO_ESTOQUE_5}
    Log    Initial stock: ${estoque_inicial}
    
    # Act - Adicionar ao carrinho
    ${response_add}=    Adicionar Produto Ao Carrinho    ${PRODUTO_ESTOQUE_5}    3
    Validar Response Status    ${response_add}    201
    
    # Cancelar compra
    ${response_cancel}=    Cancelar Compra
    Validar Response Status    ${response_cancel}    200
    
    # Verificar que estoque permaneceu igual (foi reabastecido)
    ${estoque_apos_cancel}=    Obter Estoque Produto    ${PRODUTO_ESTOQUE_5}
    Should Be Equal As Numbers    ${estoque_apos_cancel}    ${estoque_inicial}
    
    # Verificar que carrinho foi removido
    ${carrinho_response}=    Obter Carrinho Atual
    Should Be Equal As Numbers    ${carrinho_response.status_code}    200
    ${carrinhos}=    Get From Dictionary    ${carrinho_response.json()}    carrinhos
    Should Be Empty    ${carrinhos}
    
    Log    ✅ CT-017 PASSED: Cancellation and stock replenishment working correctly

CT-018: Data-Driven - Múltiplos Cenários de Boundary
    [Documentation]    Testa múltiplos cenários de boundary usando template
    [Tags]    boundary    data-driven    template
    [Template]    Testar Boundary Estoque
    
    # stock    quantity    expected_status    description
    5          4           201                Below limit (valid)
    5          5           201                Exact limit (valid)  
    5          6           400                Above limit (invalid)
    5          10          400                Way above limit (invalid)
    0          1           400                Zero stock (invalid)
    1          1           201                Minimum valid
    1          2           400                Above minimum (invalid)

*** Keywords ***
Setup Suite Carrinho
    [Documentation]    Configuração inicial da suite de carrinho
    
    # Setup básico
    Setup Test Suite
    
    # Fazer login como usuários necessários
    ${admin_token}=    Fazer Login Admin
    ${user_token}=     Fazer Login Usuario Regular
    
    # Criar produtos para testes de boundary
    Log    Creating products for boundary testing...
    
    ${nome_produto_5}=     Generate Unique Product Name    Produto Estoque 5
    ${produto_estoque_5}=  Cadastrar Produto    ${nome_produto_5}    100    Produto com 5 unidades    5
    Set Suite Variable    ${PRODUTO_ESTOQUE_5}    ${produto_estoque_5}
    
    ${nome_produto_0}=     Generate Unique Product Name    Produto Estoque 0  
    ${produto_estoque_0}=  Cadastrar Produto    ${nome_produto_0}    150    Produto sem estoque    0
    Set Suite Variable    ${PRODUTO_ESTOQUE_0}    ${produto_estoque_0}
    
    ${nome_produto_1}=     Generate Unique Product Name    Produto Estoque 1
    ${produto_estoque_1}=  Cadastrar Produto    ${nome_produto_1}    200    Produto com 1 unidade    1  
    Set Suite Variable    ${PRODUTO_ESTOQUE_1}    ${produto_estoque_1}
    
    Log    Products created successfully for boundary testing

Teardown Suite Carrinho
    [Documentation]    Limpeza após suite de carrinho
    
    # Limpar carrinho se houver
    Run Keyword And Ignore Error    Cancelar Compra
    
    # Deletar produtos de teste
    Run Keyword And Ignore Error    Deletar Produto Por ID    ${PRODUTO_ESTOQUE_5}
    Run Keyword And Ignore Error    Deletar Produto Por ID    ${PRODUTO_ESTOQUE_0}  
    Run Keyword And Ignore Error    Deletar Produto Por ID    ${PRODUTO_ESTOQUE_1}
    
    # Teardown básico
    Teardown Test Suite

Testar Boundary Estoque
    [Arguments]    ${stock}    ${quantity}    ${expected_status}    ${description}
    [Documentation]    Template para testar diferentes cenários de boundary de estoque
    
    Log    🧪 Testing: ${description} (Stock: ${stock}, Qty: ${quantity})
    
    # Determinar qual produto usar baseado no estoque
    ${produto_id}=    Set Variable If
    ...    ${stock} == 5     ${PRODUTO_ESTOQUE_5}
    ...    ${stock} == 0     ${PRODUTO_ESTOQUE_0}
    ...    ${stock} == 1     ${PRODUTO_ESTOQUE_1}
    ...    ${PRODUTO_ESTOQUE_5}
    
    # Executar teste
    ${response}=    Adicionar Produto Ao Carrinho    ${produto_id}    ${quantity}
    Validar Response Status    ${response}    ${expected_status}
    
    # Limpar carrinho se foi criado com sucesso
    IF    ${expected_status} == 201
        Run Keyword And Ignore Error    Cancelar Compra
    END
    
    # Validar que nenhum carrinho existe após erro
    IF    ${expected_status} == 400
        ${carrinho_check}=    Obter Carrinho Atual
        Should Be Equal As Numbers    ${carrinho_check.status_code}    200
        ${carrinhos}=    Get From Dictionary    ${carrinho_check.json()}    carrinhos
        Should Be Empty    ${carrinhos}
    END
    
    Log    ✅ ${description}: Status ${response.status_code} as expected