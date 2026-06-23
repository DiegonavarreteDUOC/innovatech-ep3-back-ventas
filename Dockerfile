# ─── Etapa 1: Build con Maven ───────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build

WORKDIR /app

# Copiar pom.xml y descargar dependencias (cache layer)
COPY Springboot-API-REST/pom.xml .
RUN mvn dependency:go-offline -B

# Copiar código fuente y compilar
COPY Springboot-API-REST/src ./src
RUN mvn package -DskipTests -B

# ─── Etapa 2: Imagen final liviana ─────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Crear usuario no-root por seguridad (buena práctica IE1)
RUN addgroup -S spring && adduser -S spring -G spring

# Copiar el JAR compilado
COPY --from=build /app/target/*.jar app.jar

# Usar usuario no-root
USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
