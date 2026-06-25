import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    // Verify admin role in Firestore
    final doc =
        await _db.collection('admins').doc(cred.user!.uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      throw Exception('Not an admin account.');
    }
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;
}