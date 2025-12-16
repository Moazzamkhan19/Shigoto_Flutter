import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shigoto/Model/User_Model.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Single instance

  // ------------------ SIGN UP ------------------
  Future<String> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // 1️⃣ Firebase Auth account
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2️⃣ Create Firestore user
      UserModel newUser = UserModel(
        userId: cred.user!.uid,
        username: username,
        email: email,
        photoBase64: null,
      );

      await _firestore.collection("users").doc(cred.user!.uid).set(newUser.toMap());

      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Signup failed";
    } catch (e) {
      return "Error: $e";
    }
  }

  // ------------------ LOGIN ------------------
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login failed";
    }
  }

  // ------------------ FULL LOGOUT ------------------
  Future<void> fullLogout({bool disconnectGoogle = false}) async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        if (disconnectGoogle) {
          await _googleSignIn.disconnect(); // Fully revoke Google session
        } else {
          await _googleSignIn.signOut(); // Normal Google logout
        }
      }
    } catch (e) {
      print("Google logout error: $e");
    }

    try {
      await _auth.signOut(); // Firebase logout
    } catch (e) {
      print("Firebase logout error: $e");
    }
  }

  // ------------------ GOOGLE SIGN IN ------------------
  Future<String> signInWithGoogle() async {
    try {
      // 1️⃣ Google popup
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Cancelled";

      // 2️⃣ Google Auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3️⃣ Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential cred = await _auth.signInWithCredential(credential);

      // 4️⃣ Save user to Firestore if new
      DocumentSnapshot snap = await _firestore.collection("users").doc(cred.user!.uid).get();

      if (!snap.exists) {
        UserModel user = UserModel(
          userId: cred.user!.uid,
          username: cred.user!.displayName ?? "No Name",
          email: cred.user!.email ?? "",
          photoBase64: null,
        );
        await _firestore.collection("users").doc(cred.user!.uid).set(user.toMap());
      }

      return "Success";
    } catch (e) {
      print("Google sign-in error: $e");
      return "Google login failed";
    }
  }

  // ------------------ SIGN OUT ------------------
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // ------------------ DELETE PROFILE ------------------
  Future<String> deleteProfile({
    required String userId,
    required String email,
    required String password,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return "No user logged in";

      // 1️⃣ Re-authenticate
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);

      // 2️⃣ Delete Firestore profile
      await _firestore.collection("users").doc(userId).delete();

      // 3️⃣ Delete Firebase Auth account
      await user.delete();

      // 4️⃣ Logout from Google if signed in
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      return "Success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "wrong-password":
          return "Wrong password";
        case "user-mismatch":
        case "user-not-found":
          return "User mismatch";
        case "requires-recent-login":
          return "Please log in again to delete account";
        default:
          return e.message ?? "Failed to delete account";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  // ------------------ GET CURRENT USER ------------------
  User? get currentUser => _auth.currentUser;
}


