import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/analytics_service.dart';

import 'viewmodels/app_navigation_viewmodel.dart';
import 'viewmodels/publication_viewmodel.dart';
import 'theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {

  // Bắt buộc khi gọi async trước runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PublicationViewModel()),
        ChangeNotifierProvider(create: (_) => AppNavigationViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JournalAI',
        theme: buildAppTheme(),
        navigatorObservers: [
            AnalyticsService.getObserver(),
          ],
        home: const AuthGate(),
      ),
    );
  }
}
