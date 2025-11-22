#!/bin/bash
cd frontend/lib/services
sed -i '' 's|/auth/|/api/auth/|g' api_service.dart
sed -i '' 's|/students/|/api/students/|g' api_service.dart
sed -i '' 's|/quizzes/|/api/quizzes/|g' api_service.dart
sed -i '' 's|/bosses/|/api/bosses/|g' api_service.dart
sed -i '' 's|/worksheets/|/api/worksheets/|g' api_service.dart
sed -i '' 's|/shop/|/api/shop/|g' api_service.dart
sed -i '' 's|/admin/|/api/admin/|g' api_service.dart
sed -i '' 's|/groups/|/api/groups/|g' api_service.dart
sed -i '' 's|/excel/|/api/excel/|g' api_service.dart
sed -i '' 's|/grading/|/api/grading/|g' api_service.dart
sed -i '' 's|/game/|/api/game/|g' api_service.dart
sed -i '' 's|/ocr/|/api/ocr/|g' api_service.dart
sed -i '' 's|/dungeons/|/api/dungeons/|g' api_service.dart
sed -i '' 's|/instructor|/api/instructor|g' api_service.dart
sed -i '' 's|/mental-recovery/|/api/mental-recovery/|g' api_service.dart
sed -i '' 's|/quiz/|/api/quiz/|g' api_service.dart
sed -i '' 's|/multiverse/|/api/multiverse/|g' api_service.dart
sed -i '' 's|/mental-breaker/|/api/mental-breaker/|g' api_service.dart
sed -i '' 's|/build-maker/|/api/build-maker/|g' api_service.dart
