FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY backend/pom.xml .
COPY backend/src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine

RUN apk add --no-cache \
    tesseract-ocr \
    wget

RUN mkdir -p /usr/share/tessdata && \
    cd /usr/share/tessdata && \
    wget https://github.com/tesseract-ocr/tessdata/raw/main/kor.traineddata && \
    wget https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata

ENV TESSDATA_PREFIX=/usr/share/tessdata

WORKDIR /app
COPY --from=build /app/target/*.jar application.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "application.jar"]
