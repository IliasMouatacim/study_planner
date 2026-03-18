// lib/main.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/database_service.dart';
import 'services/pomodoro_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const double minFontScale = 0.8;
  static const double maxFontScale = 1.4;

  bool _darkMode = false;
  Color _primaryColor = AppTheme.primaryColor;
  Color _secondaryColor = AppTheme.secondaryColor;
  Color _appBarColor = AppTheme.primaryColor;
  double _fontScale = 1.0;
  String _cardShape = 'Rounded';
  String _appBarStyle = 'Classic';
  String _appBarShape = 'Rectangle';
  String _uiDensity = 'Comfortable';
  final DatabaseService _db = DatabaseService();

  ThemeProvider() {
    _loadFromStorage();
  }

  bool get darkMode => _darkMode;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get appBarColor => _appBarColor;
  double get fontScale => _fontScale;
  String get cardShape => _cardShape;
  String get appBarStyle => _appBarStyle;
  String get appBarShape => _appBarShape;
  String get uiDensity => _uiDensity;

  void _loadFromStorage() {
    final storedDarkMode =
        _db.getSetting<dynamic>(AppConstants.themeDarkModeKey);
    if (storedDarkMode is bool) {
      _darkMode = storedDarkMode;
    }

    final storedPrimary =
        _db.getSetting<dynamic>(AppConstants.themePrimaryColorKey);
    if (storedPrimary is int) {
      _primaryColor = Color(storedPrimary);
    }

    final storedSecondary =
        _db.getSetting<dynamic>(AppConstants.themeSecondaryColorKey);
    if (storedSecondary is int) {
      _secondaryColor = Color(storedSecondary);
    }

    final storedAppBar =
        _db.getSetting<dynamic>(AppConstants.themeAppBarColorKey);
    if (storedAppBar is int) {
      _appBarColor = Color(storedAppBar);
    }

    final storedScale = _db.getSetting<dynamic>(AppConstants.themeFontScaleKey);
    if (storedScale is num) {
      _fontScale = (storedScale.clamp(minFontScale, maxFontScale)).toDouble();
    }

    final storedCardShape =
        _db.getSetting<dynamic>(AppConstants.themeCardShapeKey);
    if (storedCardShape is String &&
        (storedCardShape == 'Rounded' || storedCardShape == 'Square')) {
      _cardShape = storedCardShape;
    }

    final storedAppBarStyle =
        _db.getSetting<dynamic>(AppConstants.themeAppBarStyleKey);
    if (storedAppBarStyle is String &&
        (storedAppBarStyle == 'Classic' || storedAppBarStyle == 'Modern')) {
      _appBarStyle = storedAppBarStyle;
    }

    final storedAppBarShape =
        _db.getSetting<dynamic>(AppConstants.themeAppBarShapeKey);
    if (storedAppBarShape is String &&
        (storedAppBarShape == 'Rectangle' || storedAppBarShape == 'Pill')) {
      _appBarShape = storedAppBarShape;
    }

    final storedDensity =
        _db.getSetting<dynamic>(AppConstants.themeUiDensityKey);
    if (storedDensity is String &&
        (storedDensity == 'Comfortable' || storedDensity == 'Compact')) {
      _uiDensity = storedDensity;
    }
  }

  void _savePreference(String key, dynamic value) {
    unawaited(_db.saveSetting(key, value));
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    _savePreference(AppConstants.themeDarkModeKey, value);
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    _savePreference(AppConstants.themePrimaryColorKey, color.value);
    notifyListeners();
  }

  void setSecondaryColor(Color color) {
    _secondaryColor = color;
    _savePreference(AppConstants.themeSecondaryColorKey, color.value);
    notifyListeners();
  }

  void setAppBarColor(Color color) {
    _appBarColor = color;
    _savePreference(AppConstants.themeAppBarColorKey, color.value);
    notifyListeners();
  }

  void setFontScale(double scale) {
    if (!scale.isFinite) return;
    _fontScale = (scale.clamp(minFontScale, maxFontScale) as num).toDouble();
    _savePreference(AppConstants.themeFontScaleKey, _fontScale);
    notifyListeners();
  }

  void setCardShape(String shape) {
    _cardShape = shape;
    _savePreference(AppConstants.themeCardShapeKey, shape);
    notifyListeners();
  }

  void setAppBarStyle(String style) {
    _appBarStyle = style;
    _savePreference(AppConstants.themeAppBarStyleKey, style);
    notifyListeners();
  }

  void setAppBarShape(String shape) {
    _appBarShape = shape;
    _savePreference(AppConstants.themeAppBarShapeKey, shape);
    notifyListeners();
  }

  void setUiDensity(String density) {
    _uiDensity = density;
    _savePreference(AppConstants.themeUiDensityKey, density);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local services
  await DatabaseService().init();
  await NotificationService().init();

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      unawaited(DatabaseService().syncWithCloud());
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PomodoroService()),
        Provider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = AppTheme.lightTheme.copyWith(
          colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
            primary: themeProvider.primaryColor,
            secondary: themeProvider.secondaryColor,
          ),
          primaryColor: themeProvider.primaryColor,
          iconTheme: IconThemeData(color: themeProvider.secondaryColor),
          listTileTheme: ListTileThemeData(
            iconColor: themeProvider.secondaryColor,
          ),
          textTheme: AppTheme.lightTheme.textTheme,
          cardTheme: AppTheme.lightTheme.cardTheme.copyWith(
            shape: themeProvider.cardShape == 'Rounded'
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
          ),
          appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
            shape: themeProvider.appBarShape == 'Pill'
                ? const StadiumBorder()
                : null,
            toolbarHeight: 44,
            backgroundColor: themeProvider.appBarColor.withOpacity(
              themeProvider.appBarStyle == 'Classic' ? 0.92 : 0.98,
            ),
            elevation: themeProvider.appBarStyle == 'Classic' ? 0 : 4,
          ),
          visualDensity: themeProvider.uiDensity == 'Compact'
              ? VisualDensity.compact
              : VisualDensity.standard,
        );
        final darkTheme = AppTheme.darkTheme.copyWith(
          colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
            primary: themeProvider.primaryColor,
            secondary: themeProvider.secondaryColor,
          ),
          primaryColor: themeProvider.primaryColor,
          iconTheme: IconThemeData(color: themeProvider.secondaryColor),
          listTileTheme: ListTileThemeData(
            iconColor: themeProvider.secondaryColor,
          ),
          textTheme: AppTheme.darkTheme.textTheme,
          cardTheme: AppTheme.darkTheme.cardTheme.copyWith(
            shape: themeProvider.cardShape == 'Rounded'
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
          ),
          appBarTheme: AppTheme.darkTheme.appBarTheme.copyWith(
            shape: themeProvider.appBarShape == 'Pill'
                ? const StadiumBorder()
                : null,
            toolbarHeight: 44,
            backgroundColor: themeProvider.appBarColor.withOpacity(
              themeProvider.appBarStyle == 'Classic' ? 0.92 : 0.98,
            ),
            elevation: themeProvider.appBarStyle == 'Classic' ? 0 : 4,
          ),
          visualDensity: themeProvider.uiDensity == 'Compact'
              ? VisualDensity.compact
              : VisualDensity.standard,
        );
        return MaterialApp(
          title: 'Study Planner',
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show home screen if user is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Show login screen if user is not logged in
        return const LoginScreen();
      },
    );
  }
}
