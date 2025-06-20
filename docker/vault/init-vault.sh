#!/bin/bash

export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN='dev-token'

echo "🔐 Inicializando Vault con secretos..."

# Esperar a que Vault esté listo
until vault status >/dev/null 2>&1; do
    echo "⏳ Esperando a que Vault esté listo..."
    sleep 2
done

echo "✅ Vault está listo"

# Habilitar motor KV v2
vault secrets enable -path=myapp kv-v2

# Configurar secretos de base de datos
vault kv put myapp/database\
    username="postgres"\
    password="postgres123"\
    url="jdbc:postgresql://postgres:5432/vaultdemo"\
    driver="org.postgresql.Driver"

# Configurar secretos de APIs
vault kv put myapp/api-keys\
    stripe="sk_test_123456789"\
    sendgrid="SG.demo123456789"\
    jwt_secret="super-secret-jwt-key-2024"

echo "✅ Secretos configurados en Vault:"
vault kv get myapp/database
vault kv get myapp/api-keys

echo "🎉 Vault inicializado correctamente"