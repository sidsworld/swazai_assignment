import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swazai_assignment/utils/auth_servise.dart';
import 'package:swazai_assignment/utils/routes.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();

    User? user = FirebaseAuth.instance.currentUser;

    print("User: $user");
    if (user != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => Navigator.of(context)
          .pushNamedAndRemoveUntil(homeRoute, (route) => false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Swazai - Weight Tracker Assignment:',
            ),
            Text(
              'Sign In',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                UserCredential userCredential = await authService.signinAnous();
                print(userCredential.user!.uid);

                Navigator.of(context)
                    .pushNamedAndRemoveUntil(homeRoute, (route) => false);
              },
              child: const Text("Sign In As Anoymus"),
            ),
          ],
        ),
      ),
    );
  }
}
