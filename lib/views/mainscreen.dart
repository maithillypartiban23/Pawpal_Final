import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal1/views/loginscreen.dart';
import 'package:pawpal1/myconfig.dart';
import 'package:pawpal1/shared/mydrawer.dart';
import 'package:pawpal1/models/mypet.dart';
import 'package:pawpal1/views/petdetailscreen.dart';
import 'package:pawpal1/views/submitpetscreen.dart';
import 'package:pawpal1/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  User? user;

  MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<MyPet?> listPets = [];
  String status = "Loading...";
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

  late double width, height;

  List<String> types = ['All', 'Dog', 'Cat', 'Bird', 'Fish','Rabbit', 'Other'];
  String selectedType = 'All';

  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPets("", "");
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    if (width > 900) width = 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA66A46),
        title: const Text(
          'Available Pets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(onPressed: submitPet, icon: const Icon(Icons.add)),
          IconButton(
            onPressed: () {
              selectedType = 'All';
              nameController.clear();
              loadPets("", "");
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: MyDrawer(user: widget.user),
      body: Center(
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              // ================= SEARCH + FILTER =================
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // SEARCH
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: nameController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          loadPets(value, selectedType);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search pet name',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF8B5E3C)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // FILTER
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: types
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          selectedType = value!;
                          loadPets(nameController.text, selectedType);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ================= PET LIST =================
              listPets.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.find_in_page_outlined,
                                size: 64),
                            const SizedBox(height: 12),
                            Text(
                              status,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: listPets.length,
                        itemBuilder: (context, index) {
                          // ✅ SAFE IMAGE HANDLING (FIXES RANGE ERROR)
                          String rawImages =
                              listPets[index]!.imagePaths ?? "[]";

                          List images = [];
                          try {
                            images = jsonDecode(rawImages);
                          } catch (_) {
                            images = [];
                          }

                          String? firstImage =
                              images.isNotEmpty ? images[0] : null;

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  // IMAGE
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    child: Container(
                                      width: width * 0.30,
                                      height: width * 0.22,
                                      color: Colors.grey[200],
                                      child: firstImage == null
                                          ? const Icon(
                                              Icons.pets,
                                              size: 60,
                                              color: Colors.grey,
                                            )
                                          : Image.network(
                                              '${Myconfig.baseURL}/pawpal/api/$firstImage',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      const Icon(
                                                Icons.broken_image,
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // TEXT
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listPets[index]!
                                              .petName
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          listPets[index]!
                                              .petType
                                              .toString(),
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          listPets[index]!
                                              .description
                                              .toString(),
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 10,
                                              vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFC97C5D)
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            listPets[index]!
                                                .category
                                                .toString(),
                                            style: const TextStyle(
                                                color:
                                                    Color(0xFF8B5E3C)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PetDetailScreen(
                                            pet: listPets[index]!,
                                            user: widget.user,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOGIC (UNCHANGED) =================

  void submitPet() async {
    if (widget.user!.userId == "0") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login to submit pets!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubmitPetScreen(user: widget.user),
        ),
      );
      loadPets("", "");
    }
  }

  void loadPets(String name, String type) {
    listPets.clear();
    setState(() => status = "Loading...");

    if (type == 'All') type = '';

    http
        .get(Uri.parse(
            '${Myconfig.baseURL}/pawpal/api/get_my_pets.php?searchQuery=$name&filterQuery=$type'))
        .then((response) {
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == 'true' &&
            jsonResponse['data'] != null &&
            jsonResponse['data'].isNotEmpty) {
          for (var item in jsonResponse['data']) {
            listPets.add(MyPet.fromJson(item));
          }
          setState(() {});
        } else {
          setState(() => status = "No submissions yet");
        }
      } else {
        setState(() => status = "Failed to load services");
      }
    });
  }

  void loadProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.containsKey('user')) {
      setState(() {
        widget.user =
            User.fromJson(jsonDecode(pref.getString('user')!));
      });
    }
  }
}
