FROM ghcr.io/cirruslabs/flutter:stable AS build

ARG BACKEND_URL=https://lecture-punishment-production.up.railway.app

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .

# env.dart 동적 생성 (ARG 사용)
RUN echo "class Env {" > lib/config/env.dart && \
    echo "  static const String apiUrl = '${BACKEND_URL}';" >> lib/config/env.dart && \
    echo "  static const String baseUrl = apiUrl;" >> lib/config/env.dart && \
    echo "}" >> lib/config/env.dart

RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
