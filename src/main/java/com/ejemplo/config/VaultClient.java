package com.ejemplo.config;

import com.bettercloud.vault.Vault;
import com.bettercloud.vault.VaultConfig;
import com.bettercloud.vault.VaultException;
import com.bettercloud.vault.response.LogicalResponse;
import org.springframework.stereotype.Component;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.annotation.PostConstruct;
import java.util.Map;
import java.util.HashMap;

@Component
public class VaultClient {

    private static final Logger log = LoggerFactory.getLogger(VaultClient.class);
    private Vault vault;
    private boolean vaultAvailable = false;

    @PostConstruct
    public void init() {
        log.info("🔐 Inicializando cliente de Vault...");

        try {
            String vaultAddr = System.getenv().getOrDefault("VAULT_ADDR", "http://localhost:8200");
            String vaultToken = System.getenv("VAULT_TOKEN");

            if (vaultToken == null || vaultToken.isEmpty()) {
                log.warn("⚠️ VAULT_TOKEN no está configurado. Vault no estará disponible.");
                return;
            }

            log.info("🌐 Conectando a Vault en: {}", vaultAddr);

            final VaultConfig config = new VaultConfig()
                    .address(vaultAddr)
                    .token(vaultToken)
                    .build();

            this.vault = new Vault(config);

            // Verificar conexión
            vault.auth().lookupSelf();
            vaultAvailable = true;
            log.info("✅ Cliente de Vault inicializado correctamente");

        } catch (Exception e) {
            log.warn("⚠️ No se pudo conectar a Vault: {}. Funcionando sin Vault.", e.getMessage());
            vaultAvailable = false;
        }
    }

    public Map<String, String> getSecrets(String path) throws VaultException {
        if (!vaultAvailable) {
            throw new VaultException("Vault no está disponible");
        }

        log.debug("📖 Obteniendo secretos del path: {}", path);

        LogicalResponse response = vault.logical().read(path);

        if (response == null || response.getData() == null) {
            throw new VaultException("No se encontraron secretos en el path: " + path);
        }

        return response.getData();
    }

    public String getSecret(String path, String key) throws VaultException {
        Map<String, String> secrets = getSecrets(path);
        return secrets.get(key);
    }

    public boolean isVaultAvailable() {
        return vaultAvailable;
    }
}