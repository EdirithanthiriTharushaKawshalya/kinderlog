import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as developer;
import 'firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> tryInitialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      developer.log('KinderLog: Firebase initialized successfully.');
    } catch (e) {
      _isInitialized = false;
      developer.log('KinderLog: Firebase initialization failed. Falling back to Mock Demo Database. Error: $e');
    }
  }
}
