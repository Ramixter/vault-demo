#!/bin/bash

echo "🚀 Iniciando Vault Demo Application..."

# Verificar que Vault esté corriendo en el host
echo "🔍 Verificando Vault en el host..."
if curl -s http://localhost:8200/v1/sys/health > /dev/null; then
    echo "✅ Vault está corriendo"
    VAULT_AVAILABLE=true
else
    echo "⚠️ Vault no está corriendo en localhost:8200"
    echo "   La aplicación funcionará con valores por defecto"
    VAULT_AVAILABLE=false
fi

# Limpiar contenedores previos
echo "🧹 Limpiando contenedores previos..."
docker compose down 2>/dev/null

# Elegir método de red
echo "🌐 Selecciona el método de conectividad:"
echo "1) Red del host (recomendado si Vault está corriendo)"
echo "2) Red de Docker (funciona sin Vault)"
read -p "Opción (1 o 2): " NETWORK_CHOICE

if [ "$NETWORK_CHOICE" = "1" ]; then
    echo "🏗️ Usando red del host..."
    # Crear compose temporal con red del host
    cat > compose-temp.yml << EOF
services:
  app:
    build: .
    container_name: vault-demo-app
    network_mode: host
    environment:
      VAULT_ADDR: http://localhost:8200
      VAULT_TOKEN: ${VAULT_TOKEN:-dev-token}
    restart: unless-stopped
EOF
    COMPOSE_FILE="compose-temp.yml"
else
    echo "🏗️ Usando red de Docker..."
    COMPOSE_FILE="compose.yml"
fi

# Construir y levantar aplicación
VAULT_TOKEN=$VAULT_TOKEN docker compose -f $COMPOSE_FILE up --build -d

# Esperar que la aplicación esté lista
echo "⏳ Esperando que la aplicación esté lista..."
for i in {1..30}; do
    if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
        echo "✅ Aplicación lista"
        break
    fi
    echo "   Intento $i/30..."
    sleep 3

    if [ $i -eq 30 ]; then
        echo "❌ La aplicación no respondió"
        echo "📋 Logs de la aplicación:"
        docker compose -f $COMPOSE_FILE logs app | tail -20
        exit 1
    fi
done

echo ""
echo "🧪 Probando aplicación..."

# Probar endpoints
test_endpoint() {
    local endpoint=$1
    local description=$2

    echo "=== $description ==="
    response=$(curl -s "http://localhost:8080$endpoint" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | jq . 2>/dev/null || echo "$response"
    else
        echo "❌ Error al conectar con $endpoint"
    fi
    echo ""
}

test_endpoint "/" "Información General"
test_endpoint "/test-vault" "Prueba de Vault"
test_endpoint "/test-database" "Prueba de Base de Datos"
test_endpoint "/create-test-user" "Crear Usuario de Prueba"

echo "✅ Aplicación lista en: http://localhost:8080"
echo "🗄️ Consola H2: http://localhost:8080/h2-console"
if [ "$VAULT_AVAILABLE" = "true" ]; then
    echo "📊 Tu Vault: http://localhost:8200"
fi
echo ""
echo "📋 Comandos útiles:"
echo "   docker compose -f $COMPOSE_FILE logs app  # Ver logs"
echo "   ./stop.sh                                 # Detener"

# Limpiar archivo temporal si existe
[ -f "compose-temp.yml" ] && rm compose-temp.yml