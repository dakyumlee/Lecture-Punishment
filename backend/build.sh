#!/bin/bash
set -e
echo "Building backend..."
./mvnw clean package -DskipTests
