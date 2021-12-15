import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signinAnous() async {
    try {
      UserCredential userCredentials = await _auth.signInAnonymously();
      return userCredentials;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
