// lib/src/screens/auth_screen.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isLogin = true;

  Future<void> signInWithEmail() async {
    try {
      final credential = isLogin
          ? await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            )
          : await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );

      final box = await Hive.openBox('authBox');
      await box.put('uid', credential.user!.uid);

      if (!isLogin) {
        Map<String, dynamic> user = {
          "Email": _emailController.text,
          "Password": _passwordController.text,
        };
        await _firestore
            .collection('Users')
            .doc(_auth.currentUser!.uid)
            .set(user);
        final uid = _auth.currentUser!.uid;

        // Dodaj ćwiczenia z JSON
        final data =
            await rootBundle.loadString('assets/exercises_no_image.json');
        final jsonData = json.decode(data);
        for (final exercise in jsonData['exercises']) {
          final name = exercise['name'];
          final muscleGroup = exercise['muscleGroup'];
          if (name != null && muscleGroup != null && muscleGroup.isNotEmpty) {
            await _firestore
                .collection('Users')
                .doc(uid)
                .collection('exercises')
                .doc(muscleGroup)
                .collection('exercise')
                .add({'name': name});
          }
        }
      }

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final box = await Hive.openBox('authBox');
      await box.put('uid', userCredential.user!.uid);

      if (!isLogin) {
        Map<String, dynamic> user = {
          "Email": _emailController.text,
          "Password": _passwordController.text,
        };
        await _firestore
            .collection('Users')
            .doc(_auth.currentUser!.uid)
            .set(user);
        final uid = _auth.currentUser!.uid;

        // Dodaj ćwiczenia z JSON
        final data =
            await rootBundle.loadString('assets/exercises_no_image.json');
        final jsonData = json.decode(data);
        for (final exercise in jsonData['exercises']) {
          final name = exercise['name'];
          final muscleGroup = exercise['muscleGroup'];
          if (name != null && muscleGroup != null && muscleGroup.isNotEmpty) {
            await _firestore
                .collection('Users')
                .doc(uid)
                .collection('exercises')
                .doc(muscleGroup)
                .collection('exercise')
                .add({'name': name});
          }
        }
      }

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/logo_light.png', height: 250),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Hasło',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
                ),
              ),
              if (!isLogin) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Powtórz hasło',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 255, 225, 155)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 225, 155),
                    foregroundColor: const Color.fromARGB(255, 51, 51, 51)),
                onPressed: signInWithEmail,
                child: Text(isLogin ? 'Zaloguj się' : 'Zarejestruj się'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin
                      ? 'Nie masz konta? Zarejestruj się'
                      : 'Masz już konto? Zaloguj się',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.g_mobiledata,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: signInWithGoogle,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.apple,
                      color: Colors.white,
                      size: 35,
                    ),
                    onPressed: () {}, // Do implementacji Apple Auth
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
