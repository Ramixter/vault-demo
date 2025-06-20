package com.ejemplo.controller;

import com.ejemplo.entity.User;
import com.ejemplo.service.SecretService;
import com.ejemplo.config.VaultClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import javax.sql.DataSource;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

@RestController
public class TestController {

    private static final Logger log = LoggerFactory.getLogger(TestController.class);

    @Autowired
    private SecretService secretService;

    @Autowired
    private DataSource dataSource;

    @Autowired
    private VaultClient vaultClient;

    @PersistenceContext
    private EntityManager entityManager;

    @GetMapping("/")
    public Map<String, Object> home() {
        return Map.of(
            "message", "🔐 Vault Demo Application",
            "status", "running",
            "vault_status", vaultClient.isVaultAvailable() ? "✅ conectado" : "⚠️ desconectado",
            "endpoints", Map.of(
                "vault_test", "/test-vault",
                "database_test", "/test-database",
                "create_user", "/create-test-user",
                "health", "/actuator/health"
            )
        );
    }

    @GetMapping("/test-vault")
    public Map<String, Object> testVault() {
        log.info("🧪 Iniciando prueba de Vault...");

        Map<String, Object> response = new HashMap<>();

        try {
            response.put("vault_available", vaultClient.isVaultAvailable());

            Map<String, String> dbSecrets = secretService.getAllDatabaseSecrets();
            Map<String, String> apiSecrets = secretService.getApiSecrets();

            response.put("status", "✅ success");
            response.put("message", vaultClient.isVaultAvailable() ?
                "Vault funcionando correctamente" :
                "Usando configuración por defecto (Vault no disponible)");
            response.put("database_secrets", Map.of(
                "configured", dbSecrets.containsKey("username"),
                "count", dbSecrets.size(),
                "url", dbSecrets.get("url"),
                "username", dbSecrets.get("username"),
                "source", vaultClient.isVaultAvailable() ? "vault" : "default"
            ));
            response.put("api_secrets", Map.of(
                "configured", apiSecrets.containsKey("jwt_secret"),
                "count", apiSecrets.size(),
                "source", vaultClient.isVaultAvailable() ? "vault" : "default"
            ));

            log.info("✅ Prueba completada");

        } catch (Exception e) {
            log.error("❌ Error en prueba", e);
            response.put("status", "❌ error");
            response.put("message", "Error: " + e.getMessage());
        }

        return response;
    }

    @GetMapping("/test-database")
    public Map<String, Object> testDatabase() {
        log.info("🧪 Probando conexión a base de datos...");

        Map<String, Object> response = new HashMap<>();

        try (Connection connection = dataSource.getConnection()) {
            response.put("status", "✅ success");
            response.put("message", "Conexión a BD exitosa");
            response.put("database_info", Map.of(
                "url", connection.getMetaData().getURL(),
                "user", connection.getMetaData().getUserName(),
                "product", connection.getMetaData().getDatabaseProductName(),
                "version", connection.getMetaData().getDatabaseProductVersion()
            ));
            response.put("vault_source", vaultClient.isVaultAvailable() ? "vault" : "default");

            log.info("✅ Conexión a BD exitosa");

        } catch (Exception e) {
            log.error("❌ Error probando conexión a BD", e);
            response.put("status", "❌ error");
            response.put("message", "Error de conexión: " + e.getMessage());
        }

        return response;
    }

    @GetMapping("/create-test-user")
    @Transactional
    public Map<String, Object> createTestUser() {
        log.info("🧪 Creando usuario de prueba...");

        try {
            User user = new User("Test User", "test@example.com");
            entityManager.persist(user);
            entityManager.flush();

            log.info("✅ Usuario creado con ID: {}", user.getId());

            return Map.of(
                "status", "✅ success",
                "message", "Usuario creado exitosamente",
                "user", Map.of(
                    "id", user.getId(),
                    "name", user.getName(),
                    "email", user.getEmail()
                ),
                "vault_source", vaultClient.isVaultAvailable() ? "vault" : "default"
            );

        } catch (Exception e) {
            log.error("❌ Error creando usuario", e);
            return Map.of(
                "status", "❌ error",
                "message", "Error: " + e.getMessage()
            );
        }
    }
}