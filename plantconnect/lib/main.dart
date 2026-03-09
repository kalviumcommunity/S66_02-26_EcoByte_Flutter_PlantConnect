import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'providers/counter_provider.dart';
import 'providers/plant_favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'themes/app_themes.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stateless_stateful_demo.dart';
import 'screens/navigation_demo_home_screen.dart';
import 'screens/second_screen.dart';
import 'screens/responsive_layout.dart';
import 'screens/scrollable_views.dart';
import 'screens/user_input_form.dart';
import 'screens/state_management_demo.dart';
import 'screens/asset_demo_screen.dart';
import 'screens/animations_demo.dart';
import 'screens/rotate_logo_demo.dart';
import 'screens/firestore_demo_screen.dart';
import 'screens/notifications_demo_screen.dart';
import 'screens/map_screen.dart';
import 'screens/crud_screen.dart';
import 'screens/provider_demo_screen.dart';
import 'screens/form_validation_screen.dart';
import 'screens/bottom_nav_demo_screen.dart';
import 'screens/theme_demo_screen.dart';
import 'screens/async_states_demo_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Firebase has been successfully initialized!');
  
  // Initialize notifications
  await NotificationService().initialize();
  
  // Load saved theme before runApp so the correct theme is applied from the start
  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => FavoritePlantsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch rebuilds MaterialApp when ThemeProvider notifies
    final themeMode = context.watch<ThemeProvider>().mode;

    return MaterialApp(
      title: 'PlantConnect',
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
      routes: {
        '/stateless': (_) => const StatelessStatefulDemo(),
        '/navigation_demo': (_) => const NavigationDemoHomeScreen(),
        '/navigation_demo_second': (_) => const SecondScreen(),
        '/responsive_layout': (_) => const ResponsiveLayout(),
        '/scrollable_views': (_) => const ScrollableViews(),
        '/user_input_form': (_) => const UserInputForm(),
        '/state_management_demo': (_) => const StateManagementDemo(),
        '/assets_demo': (_) => const AssetDemoScreen(),
        '/animations_demo': (_) => const AnimationsDemoScreen(),
        '/rotate_demo': (_) => const RotateLogoDemo(),
        '/firestore_demo': (_) => const FirestoreDemoScreen(),
        '/notifications_demo': (_) => const NotificationsDemoScreen(),
        '/map': (_) => const MapScreen(),
        '/crud': (_) => const CrudScreen(),
        '/provider_demo': (_) => const ProviderDemoScreen(),
        '/form_validation': (_) => const FormValidationScreen(),
        '/bottom_nav': (_) => const BottomNavDemoScreen(),
        '/theme_demo': (_) => const ThemeDemoScreen(),
        '/async_states': (_) => const AsyncStatesDemoScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show professional splash screen while waiting for Firebase session check
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // User is logged in → show home screen
        if (snapshot.hasData && snapshot.data != null) {
          print('✓ User is logged in: ${snapshot.data?.email}');
          return const HomeScreen();
        }

        // No user logged in → show authentication screen
        print('✗ No user logged in, showing auth screen');
        return const AuthScreen();
      },
    );
  }
}
