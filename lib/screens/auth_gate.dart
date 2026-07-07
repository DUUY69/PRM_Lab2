import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';

import 'login_screen.dart';
import 'main_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final auth =
        context.watch<AuthViewModel>();

    return StreamBuilder(
      stream: auth.authStateChanges,

      builder: (context, snapshot) {

        // =====================================================
        // LOADING
        // =====================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        // =====================================================
        // USER LOGGED IN
        // =====================================================

        if (snapshot.hasData) {
          return const MainShell();
        }

        // =====================================================
        // USER NOT LOGGED IN
        // =====================================================

        return const LoginScreen();
      },
    );
  }
}