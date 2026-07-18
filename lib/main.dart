import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/crashlytics_service.dart';
import 'services/messaging_service.dart';
import 'services/remote_config_service.dart';
import 'services/openalex_config.dart';
import 'services/analytics_service.dart';
import 'viewmodels/app_navigation_viewmodel.dart';
import 'viewmodels/publication_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'theme/app_theme.dart';
import 'screens/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('=== MAIN START ===');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _appReady = false;
  final OpenAlexConfig _openAlexConfig = OpenAlexConfig();
  final AuthViewModel _authViewModel = AuthViewModel();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Khởi tạo Firebase (Auth, Analytics, FCM, Remote Config, Crashlytics).
  Future<void> _bootstrap() async {
    try {
      await _openAlexConfig.load();
    } catch (_) {}

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 20));
      try {
        CrashlyticsService.init();
      } catch (_) {}
      try {
        MessagingService.init();
      } catch (_) {}
      try {
        await RemoteConfigService.init();
      } catch (_) {}
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }

    await _authViewModel.bootstrap();

    if (mounted) setState(() => _appReady = true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _openAlexConfig),
        ChangeNotifierProvider(
          create: (_) => PublicationViewModel(config: _openAlexConfig),
        ),
        ChangeNotifierProvider(create: (_) => AppNavigationViewModel()),
        ChangeNotifierProvider.value(value: _authViewModel),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JournalAI',
        theme: buildAppTheme(),
        navigatorObservers: [AnalyticsService.getObserver()],
        home: !_appReady
            ? const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Initializing...'),
                    ],
                  ),
                ),
              )
            : const AuthGate(),
      ),
    );
  }
}
