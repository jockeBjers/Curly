import 'package:curly/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'main_window.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CurlyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = const Size(500, 400);
    win.maxSize = const Size(1200, 2000);
    win.size = const Size(700, 600);
    win.alignment = Alignment.center;
    win.title = "Curly - HTTP Request Tool";
    win.show();
  });
}

class CurlyApp extends StatelessWidget {
  const CurlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Curly - HTTP Request Tool',
      theme: AppTheme.themeData,
      home: const MainWindow(),
    );
  }
}
