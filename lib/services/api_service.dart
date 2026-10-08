import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get token for session management
    String? token = await userCredential.user?.getIdToken();

    // Fetch user profile from Firestore
    DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    var userData = userDoc.data() as Map<String, dynamic>? ?? {};

    return {
      'token': token,
      'user': {
        'name': userData['name'] ?? userCredential.user?.displayName ?? 'User',
        'email': userCredential.user?.email,
      }
    };
  }

  // 2. REGISTER
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save initial user profile data to Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    String? token = await userCredential.user?.getIdToken();
    return {
      'token': token,
      'user': {'name': name, 'email': email}
    };
  }

  // 3. GET APPLICATIONS
  static Future<List<dynamic>> getApplications(String token) async {
    User? user = _auth.currentUser;
    if (user == null) return [];

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('applications')
        .get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Attach Firestore document ID
      return data;
    }).toList();
  }

  // 4. ADD APPLICATION
  static Future<void> addApplication(
      String token, Map<String, dynamic> data) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    data['createdAt'] = DateTime.now().toIso8601String();
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('applications')
        .add(data);
  }

  // 5. UPDATE APPLICATION
  static Future<void> updateApplication(
      String token, String id, Map<String, dynamic> data) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('applications')
        .doc(id)
        .update(data);
  }

  // 6. GET PROFILE
  static Future<Map<String, dynamic>> getProfile(String token) async {
    User? user = _auth.currentUser;
    if (user == null) return {};

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();
    return doc.data() as Map<String, dynamic>? ?? {};
  }

  // 7. UPDATE PROFILE
  static Future<Map<String, dynamic>> updateProfile(
      String token, Map<String, dynamic> data) async {
    User? user = _auth.currentUser;
    if (user == null) return {};

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
    return data;
  }

  // 8. LOGOUT — ends the Firebase session so auth state does not leak between
  // users. Firebase persists the session on-device, so this is required to
  // actually sign out (clearing local state alone is not enough).
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // --- Session helpers -----------------------------------------------------

  /// True when Firebase currently holds an authenticated user.
  static bool get isSignedIn => _auth.currentUser != null;

  /// The uid of the signed-in user, or null when signed out.
  static String? get currentUserId => _auth.currentUser?.uid;

  /// A fresh ID token for the signed-in user, or null when signed out.
  static Future<String?> currentIdToken() =>
      _auth.currentUser?.getIdToken() ?? Future<String?>.value(null);
}
