import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'analytics_service.dart';

class AuthService {

  // =====================================================
  // FIREBASE AUTH INSTANCE
  // =====================================================

  final FirebaseAuth _firebaseAuth =
      FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn =
      GoogleSignIn();

  // =====================================================
  // CURRENT USER
  // =====================================================

  User? get currentUser =>
      _firebaseAuth.currentUser;

  // =====================================================
  // AUTH STATE STREAM
  // =====================================================

  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // =====================================================
  // GOOGLE SIGN IN
  // =====================================================

  Future<UserCredential> signInWithGoogle() async {

    // Mở popup chọn tài khoản Google
    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn();

    // User bấm Cancel
    if (googleUser == null) {
      throw Exception(
        'Google Sign In cancelled',
      );
    }

    // Lấy token Google
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Tạo Firebase Credential
    final credential =
        GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential =
          await _firebaseAuth.signInWithCredential(
        credential,
      );

      await AnalyticsService.logLogin();

      return userCredential;
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> signOut() async {

    await AnalyticsService.logLogout();

    await _googleSignIn.signOut();

    await _firebaseAuth.signOut();
  }
}