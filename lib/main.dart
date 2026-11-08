import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/quiz_provider.dart';

// Catatan: Import layar ini sementara di-comment.
// Nanti akan kita buka (uncomment) setelah file layarnya selesai dibuat.
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const WanaQApp(),
    ),
  );
}

// Konfigurasi GoRouter dengan Placeholder (Layar Sementara)
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) => const ResultScreen(),
    ),
  ],
);

class WanaQApp extends StatelessWidget {
  const WanaQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WanaQ UTS PM',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: ThemeMode.system, 
      
      // Tema Terang (Minimalis Clean)
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF3C5A00), // Hijau Gelap
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3C5A00),
          secondary: Color(0xFF5C2B03), // Cokelat
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
      ),
      
      // Tema Gelap (Minimalis Clean)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFDBEE75), // Hijau Kekuningan (terang untuk kontras)
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFDBEE75),
          secondary: Color(0xFF5C2B03),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
    );
  }
}