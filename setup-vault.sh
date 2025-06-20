#!/bin/bash

echo "🔐 Configurando secretos en tu Vault existente..."

# Verificar que las variables estén configuradas
if [ -z "$VAULT_ADDR" ]; then
    export VAULT_ADDR='http://127.0.0.1:8200'
fi

if [ -z "$VAULT_TOKEN" ]; then
    echo "❌ VAULT_TOKEN no está configurado"
    echo "Configura con: export VAULT_TOKEN='tu-token'"
    exit 1
fi

# Verificar conexión
if ! vault status > /dev/null 2>&1; then
    echo "❌ No se puede conectar a Vault"
    exit 1
fi
echo "✅ Conectado a Vault"

# Habilitar motor KV v2 (ignorar error si ya existe)
vault secrets enable -path=myapp kv-v2 2>/dev/null || echo "ℹ️ Motor myapp ya existe"

# Configurar secretos
echo "📝 Configurando secretos de base de datos (H2)..."
vault kv put myapp/database\
    username="sa"\
    password="password"\
    url="jdbc:h2:mem:testdb"\
    driver="org.h2.Driver"

echo "📝 Configurando secretos de APIs..."
vault kv put myapp/api-keys\
    stripe="sk_test_123456789"\
    sendgrid="SG.demo123456789"\
    jwt_secret="super-secret-jwt-key-2024"

# Verificar
echo "✅ Secretos configurados:"
vault kv get myapp/database
vault kv get myapp/api-keys