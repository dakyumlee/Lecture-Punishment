FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app

RUN apt-get update && \
    apt-get install -y tesseract-ocr tesseract-ocr-kor tesseract-ocr-eng && \
    rm -rf /var/lib/apt/lists/*

RUN echo "=== Finding tessdata ===" && \
    find /usr -name "tessdata" -type d 2>/dev/null && \
    echo "=== Listing kor.traineddata ===" && \
    find /usr -name "kor.traineddata" 2>/dev/null && \
    echo "=== Creating symlink ===" && \
    REAL_PATH=$(find /usr/share -name "tessdata" -type d | head -1) && \
    ln -s "$REAL_PATH" /usr/share/tessdata || true && \
    ls -la /usr/share/tessdata/ || true

ENV TESSDATA_PREFIX=/usr/share/tessdata

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
