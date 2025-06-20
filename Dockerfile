FROM openjdk:17-jdk-slim

WORKDIR /app

# Instalar curl para health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copiar archivos de Maven
COPY pom.xml .
COPY src ./src

# Instalar Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Compilar aplicación
RUN mvn clean package -DskipTests

# Exponer puerto
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3\
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Comando de inicio
CMD ["java", "-jar", "target/vault-demo-1.0.0.jar"]