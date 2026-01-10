import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal1/views/loginscreen.dart';
import 'package:pawpal1/views/mainscreen.dart';
import 'package:pawpal1/myconfig.dart';
import 'package:pawpal1/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String email = "";
  String password = "";

  @override
  void initState() {
    super.initState();
    autologin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFCE9D9),
              Color(0xFFF5D7C2),
              Color(0xFFE9BFA7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // LOGO
              Image.asset(
                'assets/images/pawpal.png',
                scale: 1.2,
              ),

              const SizedBox(height: 20),

              // LOADING INDICATOR
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(Color(0xFFA66A46)),
              ),

              const SizedBox(height: 15),

              // LOADING TEXT
              const Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B5E3C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOGIC UNCHANGED =================

  void autologin() {
    SharedPreferences.getInstance().then((prefs) {
      bool? rememberme = prefs.getBool("rememberme");
      if (rememberme != null && rememberme) {
        email = (prefs.getString("email")) ?? "";
        password = (prefs.getString("password")) ?? "";

        http
            .post(
              Uri.parse("${Myconfig.baseURL}/pawpal/api/login_user.php"),
              body: {"email": email, "password": password},
            )
            .then((response) {
              if (response.statusCode == 200) {
                var jsondata = jsonDecode(response.body);
                if (jsondata['status'] == 'success') {
                  if (!mounted) return;
                  Future.delayed(const Duration(seconds: 5), () {
                    User user = User.fromJson(jsondata['data'][0]);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MainScreen(user: user),
                      ),
                    );
                  });
                } else {
                  if (!mounted) return;
                  Future.delayed(const Duration(seconds: 3), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const LoginScreen()),
                    );
                  });
                }
              } else {
                if (!mounted) return;
                Future.delayed(const Duration(seconds: 3), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoginScreen()),
                  );
                });
              }
            });
      } else {
        if (!mounted) return;
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const LoginScreen()),
          );
        });
      }
    });
  }
}
