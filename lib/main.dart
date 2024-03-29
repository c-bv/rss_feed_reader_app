import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rss_feed_reader_app/src/config/firebase_options.dart';
import 'package:rss_feed_reader_app/src/providers/feed_provider.dart';
import 'package:rss_feed_reader_app/src/providers/settings_provider.dart';
import 'package:rss_feed_reader_app/src/screens/home_screen.dart';
import 'package:rss_feed_reader_app/src/screens/sign_in_screen.dart';
import 'package:rss_feed_reader_app/src/services/auth_service.dart';
import 'package:rss_feed_reader_app/src/theme/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => FeedProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settings.getThemeMode(), //
            home: AnimatedSplashScreen(
              splash: const FlutterLogo(size: 100),
              duration: 100,
              nextScreen: StreamBuilder<User?>(
                stream: _authService.authStateChanges,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (_authService.isUserLoggedIn &&
                        _authService.isEmailVerified) {
                      return const HomeScreen();
                    } else {
                      return const SignInScreen();
                    }
                  }
                },
              ),
              splashTransition: SplashTransition.fadeTransition,
              backgroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
