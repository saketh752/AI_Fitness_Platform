# ==========================================
# Multi-Stage Dockerfile for Spring Boot Backend
# ==========================================

# Stage 1: Build JAR
FROM maven:3.9.9-eclipse-temurin-21-alpine AS builder
WORKDIR /app

# Cache dependencies
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
RUN chmod +x ./mvnw
RUN ./mvnw dependency:go-offline -B || true

# Copy source code and package
COPY src ./src
RUN ./mvnw clean package -DskipTests -B

# Stage 2: Production Runtime
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Add unprivileged user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copy executable jar from builder
COPY --from=builder /app/target/*.jar app.jar

ENV PORT=7860
EXPOSE 7860

ENTRYPOINT ["sh", "-c", "java -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Dserver.port=${PORT:-7860} -Djava.security.egd=file:/dev/./urandom -jar app.jar"]

