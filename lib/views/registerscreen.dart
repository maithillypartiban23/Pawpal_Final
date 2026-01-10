import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal1/views/loginscreen.dart';
import 'package:pawpal1/myconfig.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController comfirmpasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool passwordvisible = false;
  bool comfirmpasswordvisible = false;
  late double height, width;
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    if (width > 400) width = 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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

                    const SizedBox(height: 10),

                    // NAME
                    buildTextField(
                      controller: nameController,
                      label: 'Name',
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 10),

                    // EMAIL
                    buildTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 10),

                    // PASSWORD
                    buildPasswordField(
                      controller: passwordController,
                      label: 'Password',
                      visible: passwordvisible,
                      onToggle: () {
                        setState(() {
                          passwordvisible = !passwordvisible;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // CONFIRM PASSWORD
                    buildPasswordField(
                      controller: comfirmpasswordController,
                      label: 'Confirm Password',
                      visible: comfirmpasswordvisible,
                      onToggle: () {
                        setState(() {
                          comfirmpasswordvisible =
                              !comfirmpasswordvisible;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // PHONE
                    buildTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 20),

                    // REGISTER BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFC97C5D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: registerDialog,
                        child: const Text('Register'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // LOGIN LINK
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Already have an account? Login here',
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

  // ================= UI HELPERS (NO LOGIC CHANGE) =================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        labelText: label,
        labelStyle:
            const TextStyle(color: Color(0xFF8B5E3C)),
        prefixIcon: Icon(icon,
            color: const Color(0xFF8B5E3C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        labelText: label,
        labelStyle:
            const TextStyle(color: Color(0xFF8B5E3C)),
        prefixIcon: const Icon(Icons.lock,
            color: Color(0xFF8B5E3C)),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF8B5E3C),
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ================= LOGIC (UNCHANGED) =================

  void registerDialog() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmpassword =
        comfirmpasswordController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmpassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all the fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmpassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration'),
        content: Text(
          'Do you want to register with the following details?\n\n'
          'Name: $name\nEmail: $email\nPhone: $phone',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              registerUser(name, email, password, phone);
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void registerUser(
      String name, String email, String password, String phone) async {
    setState(() => isloading = true);

    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Registering...'),
          ],
        ),
      ),
    );

    await http
        .post(
          Uri.parse("${Myconfig.baseURL}/pawpal/api/register_user.php"),
          body: {
            'name': name,
            'email': email,
            'password': password,
            'phone': phone,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            var resarray = jsonDecode(response.body);
            log(resarray.toString());

            if (resarray['success'] == true) {
              Navigator.pop(context);
              setState(() => isloading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registration Successful'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const LoginScreen()),
              );
            } else {
              Navigator.pop(context);
              setState(() => isloading = false);
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
}
