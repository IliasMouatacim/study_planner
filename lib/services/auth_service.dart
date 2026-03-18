// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la connexion avec Google: $e');
    }
  }

  // Sign in with X (Twitter)
Future<UserCredential?> signInWithTwitter() async {
  try {
    final twitterProvider = TwitterAuthProvider();
    return await _auth.signInWithProvider(twitterProvider);
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  } catch (e) {
    throw Exception('Erreur lors de la connexion avec X: $e');
  }
}


  // Sign out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'invalid-email':
        return 'L\'adresse email est invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'operation-not-allowed':
        return 'Opération non autorisée.';
      case 'requires-recent-login':
        return 'Veuillez vous reconnecter pour effectuer cette action.';
      default:
        return 'Une erreur est survenue: ${e.message}';
    }
  }
}