FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY backend/pom.xml .
COPY backend/src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
RUN apk add --no-cache \
    tesseract-ocr \
    tesseract-ocr-data-kor \
    tesseract-ocr-data-eng

ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata

WORKDIR /app
COPY --from=build /app/target/*.jar application.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "application.jar"]
