package com.ejemplo.service;

import com.ejemplo.config.VaultClient;
import com.bettercloud.vault.VaultException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

@Service
public class SecretService {

    private static final Logger log = LoggerFactory.getLogger(SecretService.class);

    @Autowired
    private VaultClient vaultClient;

    public Map<String, String> getAllDatabaseSecrets() {
        try {
            return vaultClient.getSecrets("myapp/data/database");
        } catch (VaultException e) {
            log.error("Error al obtener secretos de BD", e);
            throw new RuntimeException("Error al obtener secretos de BD", e);
        }
    }

    public Map<String, String> getApiSecrets() {
        try {
            return vaultClient.getSecrets("myapp/data/api-keys");
        } catch (VaultException e) {
            log.error("Error al obtener secretos de API", e);
            throw new RuntimeException("Error al obtener secretos de API", e);
        }
    }

    public String getDatabasePassword() {
        try {
            return vaultClient.getSecret("myapp/data/database", "password");
        } catch (VaultException e) {
            log.error("Error al obtener password de BD", e);
            throw new RuntimeException("Error al obtener password de BD", e);
        }
    }
}