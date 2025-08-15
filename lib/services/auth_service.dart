import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tenant.dart';
import 'onesignal_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get current user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Setup OneSignal after successful login
      await _setupOneSignalForUser();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if password change is required
  static Future<bool> checkPasswordChangeRequired(String uid) async {
    try {
      final tenantQuery =
          await _firestore
              .collection('tenants')
              .where('firebaseUid', isEqualTo: uid)
              .get();

      if (tenantQuery.docs.isNotEmpty) {
        final tenantData = tenantQuery.docs.first.data();
        return !(tenantData['hasChangedPassword'] ?? false);
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check password change requirement: $e');
    }
  }

  // Update password and mark as changed
  static Future<void> updatePassword({required String newPassword}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update password in Firebase Auth
      await user.updatePassword(newPassword);

      // Update tenant record to mark password as changed
      final tenantQuery =
          await _firestore
              .collection('tenants')
              .where('firebaseUid', isEqualTo: user.uid)
              .get();

      if (tenantQuery.docs.isNotEmpty) {
        await tenantQuery.docs.first.reference.update({
          'hasChangedPassword': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Get current tenant info
  static Future<Tenant?> getCurrentTenant() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final tenantQuery =
          await _firestore
              .collection('tenants')
              .where('firebaseUid', isEqualTo: user.uid)
              .get();

      if (tenantQuery.docs.isNotEmpty) {
        final doc = tenantQuery.docs.first;
        return Tenant.fromJson({'id': doc.id, ...doc.data()});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current tenant: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Setup OneSignal for the current user
  static Future<void> _setupOneSignalForUser() async {
    try {
      // Request notification permission and get device ID
      final deviceId = await OneSignalService.requestPermissionAndGetDeviceId();

      if (deviceId != null) {
        // Save device ID to Firestore
        await OneSignalService.saveDeviceIdToFirestore();

        // Set user tags for segmentation
        await OneSignalService.setTenantTags();
      }
    } catch (e) {
      // Don't throw error for OneSignal setup failure
      // Just log it and continue
      print('OneSignal setup failed: $e');
    }
  }

  // Public method to setup OneSignal (can be called from other places)
  static Future<void> setupOneSignalForCurrentUser() async {
    await _setupOneSignalForUser();
  }

  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'requires-recent-login':
        return 'Please log in again to change your password.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Validate password strength
  static bool isPasswordStrong(String password) {
    // At least 8 characters, contains uppercase, lowercase, number, and special character
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return regex.hasMatch(password);
  }

  // Get password strength message
  static String getPasswordStrengthMessage(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!password.contains(RegExp(r'[@$!%*?&]'))) {
      return 'Password must contain at least one special character (@\$!%*?&)';
    }
    return 'Password is strong';
  }
}
