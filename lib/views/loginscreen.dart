import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pawpal1/views/mainscreen.dart';
import 'package:pawpal1/myconfig.dart';
import 'package:pawpal1/views/registerscreen.dart';
import 'package:pawpal1/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool passwordvisible = false;
  bool isChecked = false;
  late double height, width;
  late User user;

  @override
  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    if (width > 400) width = 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFFA66A46),
      ),

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: width,
                child: Column(
                  children: [

                    // LOGO
                    Image.asset(
                      'assets/images/pawpal.png',
                      scale: 1.5,
                    ),

                    const SizedBox(height: 12),

                    // EMAIL
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        labelText: 'Email',
                        labelStyle:
                            const TextStyle(color: Color(0xFF8B5E3C)),
                        prefixIcon: const Icon(Icons.email,
                            color: Color(0xFF8B5E3C)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // PASSWORD
                    TextField(
                      controller: passwordController,
                      obscureText: !passwordvisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        labelText: 'Password',
                        labelStyle:
                            const TextStyle(color: Color(0xFF8B5E3C)),
                        prefixIcon: const Icon(Icons.lock,
                            color: Color(0xFF8B5E3C)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordvisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF8B5E3C),
                          ),
                          onPressed: () {
                            setState(() {
                              passwordvisible = !passwordvisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // REMEMBER ME
                    Row(
                      children: [
                        const Text(
                          'Remember Me',
                          style:
                              TextStyle(color: Color(0xFF8B5E3C)),
                        ),
                        Checkbox(
                          value: isChecked,
                          activeColor: const Color(0xFFC97C5D),
                          onChanged: (value) {
                            setState(() {
                              isChecked = value!;
                            });

                            if (isChecked) {
                              if (emailController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty) {
                                prefUpdate(true);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Preferences Saved"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                setState(() {
                                  isChecked = false;
                                });
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Please fill email and password"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              prefUpdate(false);
                              emailController.clear();
                              passwordController.clear();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Preferences Removed"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFC97C5D),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: loginUser,
                        child: const Text('Login'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // REGISTER
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account yet? Register",
                        style: TextStyle(
                          color: Color(0xFF8B5E3C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================== LOGIC (UNCHANGED) ==================

  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all the fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Passwords must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(
            r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
        .hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await http.post(
      Uri.parse("${Myconfig.baseURL}/pawpal/api/login_user.php"),
      body: {'email': email, 'password': password},
    ).then((response) {
      if (response.statusCode == 200) {
        var resarray = jsonDecode(response.body);
        log(resarray.toString());

        if (resarray['success'] == true) {
          user = User.fromJson(resarray['data'][0]);
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login successful"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(user: user),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resarray['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void prefUpdate(bool isChecked) async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();
    if (isChecked) {
      prefs.setString("email", emailController.text.trim());
      prefs.setString(
          "password", passwordController.text.trim());
      prefs.setBool("rememberme", isChecked);
    } else {
      prefs.remove("email");
      prefs.remove("password");
      prefs.remove("rememberme");
    }
  }

  void loadPref() {
    SharedPreferences.getInstance().then((prefs) {
      bool? rememberme = prefs.getBool("rememberme");
      if (rememberme != null && rememberme) {
        emailController.text =
            prefs.getString("email") ?? '';
        passwordController.text =
            prefs.getString("password") ?? '';
        setState(() {
          isChecked = true;
        });
      }
    });
  }
}
