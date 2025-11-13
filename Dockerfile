FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY backend/pom.xml .
COPY backend/src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
RUN apk add --no-cache \
    tesseract-ocr \
    tesseract-ocr-data-kor \
    tesseract-ocr-data-eng \
    fontconfig \
    ttf-dejavu

WORKDIR /app
COPY --from=build /workspace/target/*.jar application.jar
EXPOSE 8080
CMD ["java", "-jar", "application.jar"]
