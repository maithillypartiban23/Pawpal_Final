import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawpal1/myconfig.dart';
import 'package:pawpal1/shared/mydrawer.dart';
import 'package:pawpal1/views/paymentpage.dart';
import 'package:pawpal1/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  User? user;
  MyProfile({super.key, required this.user});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final GlobalKey<State<MyDrawer>> drawerKey = GlobalKey<State<MyDrawer>>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  int amount = 0;

  Image? profileImage;
  Uint8List? webImage;
  File? image;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    nameController.text = widget.user?.name ?? '';
    phoneController.text = widget.user?.phone ?? '';
    emailController.text = widget.user?.email ?? '';
    amount = widget.user?.walletBalanceCents ?? 0;
    setState(() {});
  }

  // ================= IMAGE PICK =================
  void pickImageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pick Profile Image"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                openCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                openGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      if (kIsWeb) {
        webImage = await pickedFile.readAsBytes();
      } else {
        image = File(pickedFile.path);
        await cropImage();
      }
      setState(() {});
    }
  }

  Future<void> openGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        webImage = await pickedFile.readAsBytes();
      } else {
        image = File(pickedFile.path);
        await cropImage();
      }
      setState(() {});
    }
  }

  Future<void> cropImage() async {
    if (kIsWeb) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.brown,
          toolbarWidgetColor: Colors.white,
        ),
      ],
    );
    if (cropped != null) {
      image = File(cropped.path);
    }
  }

  // ================= UPDATE PROFILE =================
  Future<void> _updateProfile() async {
    String base64image = "NA";

    if (kIsWeb && webImage != null) {
      base64image = base64Encode(webImage!);
    } else if (!kIsWeb && image != null) {
      base64image = base64Encode(image!.readAsBytesSync());
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${Myconfig.baseURL}/pawpal/api/update_profile.php'),
        body: {
          'user_id': widget.user?.userId,
          'user_name': nameController.text,
          'user_phone': phoneController.text,
          'user_email': emailController.text,
          'user_image': base64image,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        loadProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated")),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void loadProfile() {
    http.get(
      Uri.parse(
        '${Myconfig.baseURL}/pawpal/api/getuserdetails.php?userid=${widget.user!.userId}',
      ),
    ).then((response) async {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        User user = User.fromJson(data['data'][0]);
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('user', jsonEncode(user.toJson()));
        setState(() {
          widget.user = user;
          amount = user.walletBalanceCents ?? 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFEA),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadProfile,
          ),
        ],
      ),
      drawer: MyDrawer(user: widget.user, key: drawerKey),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // AVATAR
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.brown,
                      child: GestureDetector(
                        onTap: pickImageDialog,
                        child: ClipOval(
                          child: (!kIsWeb && image != null)
                              ? Image.file(image!, fit: BoxFit.cover)
                              : (webImage != null)
                                  ? Image.memory(webImage!, fit: BoxFit.cover)
                                  : Image.network(
                                      '${Myconfig.baseURL}/pawpal/api/userimages/${widget.user!.userId}.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Text(
                                        widget.user!.name![0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _readonlyField("Email", widget.user?.email),

                    const Divider(height: 30),

                    _inputField(
                      controller: nameController,
                      label: "Name",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: phoneController,
                      label: "Phone",
                      icon: Icons.phone,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                        ),
                       onPressed: _updateProfile,
  child: const Text(
    "Save Changes",
    style: TextStyle(color: Colors.white),
  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _readonlyField(String label, String? value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value ?? "-"),
      decoration: InputDecoration(
        labelText: label,
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.brown),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.brown),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.brown),
        ),
      ),
    );
  }
}
