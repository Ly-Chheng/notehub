import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ១. ប្រើប្រាស់ Singleton instance (v7+)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // ២. ទាញយកព័ត៌មាន User បច្ចុប្បន្ន (បើមាន)
  User? get currentUser => _auth.currentUser;

  // ៣. ស្តាប់បម្រែបម្រួលស្ថានភាព Login (លំហូរ Stream សម្រាប់ GetX / UI)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ៤. មុខងារ Login ជាមួយ Gmail (Google Account)
  Future<User?> signInWithGoogle() async {
    try {
      // 🛠️ ដំណោះស្រាយ៖ ត្រូវបញ្ជូន serverClientId (Web Client ID ពី Firebase/Google Cloud)
      // កំណត់សម្គាល់៖ ជំនួស 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com' ដោយ ID ពិតប្រាកដរបស់អ្នក
      await _googleSignIn.initialize(
        // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
        serverClientId: '1234567890-abcdefg.apps.googleusercontent.com',
      );

      // ចាប់ផ្តើមការជ្រើសរើសគណនី Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null; // អ្នកប្រើប្រាស់ចុចបិទវិញ/Cancel

      // ទាញយក authorization ដើម្បីទទួលបាន accessToken
      final GoogleSignInClientAuthorization authorization = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      // ទាញយក ID Token ពី authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // បង្កើត Credential សម្រាប់បញ្ជូនទៅកាន់ Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      // ធ្វើការ Sign-in ចូលទៅក្នុង Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint("❌ Google Sign-In Error: $e");
      return null;
    }
  }

  // ៥. មុខងារចាកចេញពីគណនី (Sign Out)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("❌ Sign-Out Error: $e");
    }
  }
}
