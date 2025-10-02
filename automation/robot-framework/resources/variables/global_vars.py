# Variáveis Globais - ServeRest API Tests

# URLs e Endpoints
BASE_URL = "https://serverest.dev"
LOCAL_URL = "http://localhost:3000"

# Timeouts e Delays
DEFAULT_TIMEOUT = 10
REQUEST_DELAY = 0.1
TOKEN_EXPIRE_TIME = 600  # 10 minutos em segundos

# Dados de Teste - Usuários
ADMIN_USER_DATA = {
    "nome": "Admin Teste Automation",
    "email": "admin.automation@teste.com", 
    "password": "senha123",
    "administrador": "true"
}

REGULAR_USER_DATA = {
    "nome": "Usuario Teste Automation",
    "email": "user.automation@teste.com",
    "password": "senha123", 
    "administrador": "false"
}

# Dados de Teste - Produtos
PRODUTO_TESTE_DATA = {
    "nome": "Produto Teste Automation",
    "preco": 100,
    "descricao": "Produto criado automaticamente para testes",
    "quantidade": 50
}

PRODUTO_ESTOQUE_LIMITADO = {
    "nome": "Produto Estoque Limitado",
    "preco": 250,
    "descricao": "Produto para testes de boundary",
    "quantidade": 5
}

PRODUTO_SEM_ESTOQUE = {
    "nome": "Produto Sem Estoque", 
    "preco": 150,
    "descricao": "Produto para testes de estoque zero",
    "quantidade": 0
}

# Boundary Values para Testes
BOUNDARY_VALUES = {
    "email": {
        "min_valid": "a@b.c",
        "max_valid": "a" * 50 + "@domain.com",
        "invalid_no_at": "emailsemArroba.com",
        "invalid_no_domain": "email@",
        "invalid_empty": ""
    },
    "password": {
        "min_length": "1",
        "normal": "senha123",
        "max_length": "a" * 100,
        "empty": ""
    },
    "nome": {
        "min_length": "A",
        "normal": "Nome Teste",
        "max_length": "A" * 50,
        "over_limit": "A" * 51,
        "empty": ""
    },
    "preco": {
        "zero": 0,
        "min_valid": 0.01,
        "normal": 100,
        "negative": -1,
        "very_large": 999999999
    },
    "quantidade": {
        "zero": 0,
        "one": 1,
        "normal": 10,
        "large": 1000000,
        "max_int": 2147483647
    }
}

# Mensagens de Erro Esperadas
ERROR_MESSAGES = {
    "login": {
        "invalid_credentials": "Email e/ou senha inválidos",
        "empty_email": "email é obrigatório", 
        "empty_password": "password é obrigatório"
    },
    "usuario": {
        "email_exists": "Este email já está sendo usado",
        "user_not_found": "Usuário não encontrado",
        "user_with_cart": "Não é permitido excluir usuário com carrinho cadastrado"
    },
    "produto": {
        "name_exists": "Já existe produto com esse nome",
        "unauthorized": "Token de acesso ausente, inválido, expirado ou usuário do token não existe mais",
        "forbidden": "Rota exclusiva para administradores"
    },
    "carrinho": {
        "insufficient_stock": "Produto não possui quantidade suficiente",
        "product_not_found": "Produto não encontrado",
        "empty_cart": "Não foi encontrado carrinho para esse usuário"
    },
    "token": {
        "expired": "Token de acesso ausente, inválido, expirado ou usuário do token não existe mais",
        "invalid": "Token de acesso ausente, inválido, expirado ou usuário do token não existe mais"
    }
}

# Headers Padrão
DEFAULT_HEADERS = {
    "Content-Type": "application/json",
    "Accept": "application/json"
}

# Status Codes Esperados
STATUS_CODES = {
    "success": 200,
    "created": 201,
    "bad_request": 400,
    "unauthorized": 401,
    "forbidden": 403,
    "not_found": 404,
    "internal_error": 500
}

# Configurações de Teste
TEST_CONFIG = {
    "max_retries": 3,
    "retry_delay": 1,
    "parallel_users": 5,
    "cleanup_after_test": True,
    "save_evidence": True
}