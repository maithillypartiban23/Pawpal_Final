import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pawpal1/shared/animated_route.dart';
import 'package:pawpal1/views/loginscreen.dart';
import 'package:pawpal1/views/mainscreen.dart';
import 'package:pawpal1/myconfig.dart';
import 'package:pawpal1/views/mydonation.dart';
import 'package:pawpal1/views/myprofile.dart';
import 'package:pawpal1/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatefulWidget {
  User? user;

  MyDrawer({super.key, required this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late double height;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.brown,
            ),
            currentAccountPicture: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.network(
                  '${Myconfig.baseURL}/pawpal/api/userimages/${widget.user!.userId}.png',
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      widget.user?.name
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          '',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
            accountName: Text(
              widget.user?.name ?? "Guest",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(widget.user?.email ?? "Guest"),
          ),

          // HOME
          ListTile(
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(
                  MainScreen(user: widget.user),
                ),
              );
            },
          ),

          // MY DONATION
          ListTile(
            title: const Text("My Donation"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(
                  MyDonation(user: widget.user),
                ),
              );
            },
          ),

          // PROFILE
          ListTile(
            title: const Text("Profile"),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                AnimatedRoute.slideFromRight(
                  MyProfile(user: widget.user),
                ),
              );
              await loadProfile();
            },
          ),

          const Divider(),

          // LOGOUT
          ListTile(
            title: const Text(
              "Log out",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content:
                      const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.remove("user");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(
            height: height / 3,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "PawPal",
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Version 0.1",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey('user')) {
      setState(() {
        widget.user =
            User.fromJson(jsonDecode(pref.getString('user')!));
      });
    }
  }
}
