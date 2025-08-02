import 'package:flutter/material.dart';
import 'package:lost_and_found_app/pages/forgot_password_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';
import 'package:lost_and_found_app/pages/auth_checker.dart';
// Ensure this is imported for DateFormat

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with your project URL and Anon Key from .env
  await Supabase.initialize(
    url: dotenv.env[AppConstants.supabaseUrlKey]!,
    anonKey: dotenv.env[AppConstants.supabaseAnonKey]!,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the primary maroon color
    const Color primaryMaroon = Color(0xFF880022); // A deep maroon color

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost and Found App',
      theme: ThemeData(
        primaryColor: primaryMaroon, // Set primary color
        primarySwatch: MaterialColor(primaryMaroon.value, <int, Color>{
          50: primaryMaroon.withOpacity(0.1),
          100: primaryMaroon.withOpacity(0.2),
          200: primaryMaroon.withOpacity(0.3),
          300: primaryMaroon.withOpacity(0.4),
          400: primaryMaroon.withOpacity(0.5),
          500: primaryMaroon.withOpacity(0.6),
          600: primaryMaroon.withOpacity(0.7),
          700: primaryMaroon.withOpacity(0.8),
          800: primaryMaroon.withOpacity(0.9),
          900: primaryMaroon.withOpacity(1.0),
        }),
        scaffoldBackgroundColor: Colors.grey[100], // Light grey background
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryMaroon, // Maroon app bar
          foregroundColor: Colors.white, // White text/icons on app bar
          elevation: 0, // Flat app bar for modern look
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25), // More rounded buttons
            ),
            backgroundColor: primaryMaroon, // Maroon buttons
            foregroundColor: Colors.white, // White text on buttons
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 5, // Add some shadow
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryMaroon, // Maroon text buttons
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // White background for input fields
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          enabledBorder: UnderlineInputBorder( // Underline border for enabled state
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
          focusedBorder: const UnderlineInputBorder( // Thicker underline for focused state
            borderSide: BorderSide(color: primaryMaroon, width: 2.0),
          ),
          errorBorder: const UnderlineInputBorder( // Red underline for error state
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: const UnderlineInputBorder( // Red underline for focused error state
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.grey[700]),
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIconColor: Colors.grey[600],
        ),
        cardTheme: CardThemeData(
          elevation: 5, // More prominent cards
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // More rounded cards
          ),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
        // Add text theme for consistent font styles
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: primaryMaroon),
          headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: primaryMaroon),
          headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: primaryMaroon),
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black87),
          titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black87),
          titleSmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
          bodySmall: TextStyle(fontSize: 12.0, color: Colors.black54),
          labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      home: const AuthChecker(), // Start with AuthChecker
      routes: {
        '/forgot_password': (context) => const ForgotPasswordPage(), // Add route for forgot password
      },
    );
  }
}