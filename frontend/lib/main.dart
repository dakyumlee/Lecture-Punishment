import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/game_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: '허태훈의 분노 던전',
        theme: AppTheme.darkTheme,
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
