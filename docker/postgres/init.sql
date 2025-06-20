-- Crear tabla de usuarios para pruebas
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de prueba
INSERT INTO users (name, email) VALUES
    ('Admin User', 'admin@example.com'),
    ('Demo User', 'demo@example.com');

-- Mostrar información
SELECT 'Database initialized successfully' AS status;
SELECT COUNT(*) AS user_count FROM users;