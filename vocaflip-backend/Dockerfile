# ===========================================
# Dockerfile cho VocaFlip Backend
# Multi-stage build: Maven build -> JRE runtime
# ===========================================

# Bước 1: Build dự án bằng Maven
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Copy file cấu hình Maven trước để tận dụng Docker layer caching
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw mvnw.cmd ./

# Download dependencies (layer này sẽ được cache nếu pom.xml không đổi)
RUN mvn dependency:go-offline -B

# Copy source code và build
COPY src ./src
RUN mvn clean package -DskipTests

# ===========================================
# Bước 2: Chạy ứng dụng với JRE (image nhẹ hơn)
# ===========================================
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Tạo user không phải root để tăng bảo mật
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy file JAR từ build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port 8080
EXPOSE 8080

# Health check để Render biết app đã sẵn sàng
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Cấu hình JVM cho container (giới hạn memory)
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Chạy ứng dụng
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
