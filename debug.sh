#!/bin/bash

echo "🔍 Información de Debug para Vault Demo"
echo "========================================"

echo ""
echo "📊 Estado de contenedores:"
docker-compose ps

echo ""
echo "🌐 Puertos en uso:"
netstat -tulpn | grep -E ":(8080|8200|5432)" 2>/dev/null || ss -tulpn | grep -E ":(8080|8200|5432)"

echo ""
echo "📋 Logs recientes de la aplicación:"
echo "-----------------------------------"
docker-compose logs --tail=20 app

echo ""
echo "📋 Logs recientes de Vault:"
echo "---------------------------"
docker-compose logs --tail=10 vault

echo ""
echo "📋 Logs recientes de PostgreSQL:"
echo "-------------------------------"
docker-compose logs --tail=10 postgres

echo ""
echo "🧪 Pruebas de conectividad:"
echo "----------------------------"

# Test Vault
echo -n "Vault (8200): "
if curl -s http://localhost:8200/v1/sys/health > /dev/null; then
    echo "✅ OK"
else
    echo "❌ FAIL"
fi

# Test App
echo -n "App (8080): "
if curl -s http://localhost:8080/actuator/health > /dev/null; then
    echo "✅ OK"
else
    echo "❌ FAIL"
fi

# Test PostgreSQL
echo -n "PostgreSQL (5432): "
if nc -z localhost 5432 2>/dev/null; then
    echo "✅ OK"
else
    echo "❌ FAIL"
fi

echo ""
echo "🔍 Variables de entorno en el contenedor de la app:"
docker-compose exec app env | grep -E "(VAULT|POSTGRES)" 2>/dev/null || echo "❌ Contenedor app no está corriendo"