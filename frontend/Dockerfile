FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# env.dart를 빌드 시 생성
COPY lib/config/env.dart.production lib/config/env.dart

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
