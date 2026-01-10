import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawpal1/myconfig.dart';
import 'package:pawpal1/models/user.dart';

class SubmitPetScreen extends StatefulWidget {
  final User? user;

  const SubmitPetScreen({super.key, required this.user});

  @override
  State<SubmitPetScreen> createState() => _SubmitPetScreenState();
}

class _SubmitPetScreenState extends State<SubmitPetScreen> {
  late double height, width;
  late Position myPosition;

  List<Uint8List?> webImages = [null, null, null];
  List<File?> images = [null, null, null];

  List<String> categories = ['Adoption', 'Donation', 'Help/Rescue'];
  List<String> types = ['Dog', 'Cat', 'Fish', 'Bird', 'Rabbit', 'Other'];
  List<String> genders = ['Male', 'Female'];
  List<String> healthStatus = [
    'very Healthy',
    'Healthy',
    'Average',
    'Weak',
    'Very Weak'
  ];

  TextEditingController petNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  String selectedCategory = 'Adoption';
  String selectedType = 'Dog';
  String selectedGender = 'Male';
  String selectedHealth = 'Healthy';

  bool isLoading = false;
  int maxImageNum = 3;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    if (width > 800) width = 800;

    return Scaffold(
      appBar: AppBar(title: const Text('New Pet Submission')),
      body: Center(
        child: SizedBox(
          width: width,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGES (TOP)
                const Text("Pet Images",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(maxImageNum, (index) {
      return GestureDetector(
        onTap: () {
          if (kIsWeb) {
            openGallery(index);
          } else {
            pickImageDialog(index);
          }
        },
        child: Container(
          width: 235, // bigger width
          height: 180, // bigger height
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade400),
            image: images[index] != null && !kIsWeb
                ? DecorationImage(
                    image: FileImage(images[index]!),
                    fit: BoxFit.cover,
                  )
                : webImages[index] != null
                    ? DecorationImage(
                        image: MemoryImage(webImages[index]!),
                        fit: BoxFit.cover,
                      )
                    : null,
          ),
          child: images[index] == null && webImages[index] == null
              ? const Icon(Icons.add_a_photo,
                  size: 40, color: Colors.grey)
              : null,
        ),
      );
    }),
  ),
),
const SizedBox(height: 20),

                /// PET NAME
                TextField(
                  controller: petNameController,
                  decoration: const InputDecoration(
                    labelText: 'Pet Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                /// AGE + GENDER
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        items: genders
                            .map((g) => DropdownMenuItem(
                                value: g, child: Text(g)))
                            .toList(),
                        onChanged: (value) {
                          selectedGender = value!;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// TYPE
                DropdownButtonFormField(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: types
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) {
                    selectedType = value!;
                    setState(() {});
                  },
                ),

                const SizedBox(height: 10),

                /// CATEGORY
                DropdownButtonFormField(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                    setState(() {});
                  },
                ),

                const SizedBox(height: 10),

                /// HEALTH
                DropdownButtonFormField(
                  value: selectedHealth,
                  decoration: const InputDecoration(
                    labelText: 'Health Status',
                    border: OutlineInputBorder(),
                  ),
                  items: healthStatus
                      .map((h) =>
                          DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
                  onChanged: (value) {
                    selectedHealth = value!;
                    setState(() {});
                  },
                ),

                const SizedBox(height: 10),

                /// LAT + LNG
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latitudeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.location_on),
                            onPressed: getLocation,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: longitudeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Longitude',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.location_on),
                            onPressed: getLocation,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// DESCRIPTION
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                /// SUBMIT BUTTON
                SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF8B4513), // brown color same as AppBar
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: showSubmitDialog,
    child: const Text(
      'Submit Pet',
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  ),
),

              ],
            ),
          ),
        ),
      ),
    );
  }
  void pickImageDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  openCamera(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  openGallery(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> openCamera(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (kIsWeb) {
        webImages[index] = await pickedFile.readAsBytes();
        setState(() {});
      } else {
        images[index] = File(pickedFile.path);
        cropImage(index);
      }
    }
  }

  Future<void> openGallery(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        webImages[index] = await pickedFile.readAsBytes();
        setState(() {});
      } else {
        images[index] = File(pickedFile.path);
        cropImage(index); // only for mobile
      }
    }
  }

  Future<void> cropImage(int index) async {
    if (kIsWeb) return; // skip cropping on web
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: images[index]!.path,
      aspectRatio: CropAspectRatio(ratioX: 5, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Please Crop Your Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );

    if (croppedFile != null) {
      images[index] = File(croppedFile.path);
      setState(() {});
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void getLocation() async {
    isLoading = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Loading...'),
          ],
        ),
      ),
    );
    myPosition = await _determinePosition();

    latitudeController.text = myPosition.latitude.toString();
    longitudeController.text = myPosition.longitude.toString();

    if (isLoading) {
      Navigator.pop(context);
      isLoading = false;
    }
    setState(() {});
  }

  void showSubmitDialog() {
    if (petNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Pet Name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (ageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Pet Age"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (int.tryParse(ageController.text.trim())==null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Pet Age as a number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if ( int.parse(ageController.text.trim())<0 ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pet Age cannot less than 0"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (latitudeController.text.trim().isEmpty ||
        longitudeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please click the location icon to get the latitude and longitude",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (descController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The description is too short"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (webImages[0] == null && images[0] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide at least one image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Pet'),
          content: const Text('Are you sure you want to submit this?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                submitPet();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void submitPet() {
    String petName = petNameController.text.trim();
    String age = ageController.text.trim();
    String petType = selectedType.trim();
    String category = selectedCategory.trim();
    String gender= selectedGender.trim();
    String health = selectedHealth.trim();
    String latitude = latitudeController.text.trim();
    String longitude = longitudeController.text.trim();
    String desc = descController.text.trim();
    List<String> base64Images = [];

    if (kIsWeb) {
      for (int i = 0; i < maxImageNum && webImages[i] != null; i++) {
        base64Images.add(base64Encode(webImages[i]!));
      }
    } else {
      for (int i = 0; i < maxImageNum && images[i] != null; i++) {
        base64Images.add(base64Encode(images[i]!.readAsBytesSync()));
      }
    }

    http
        .post(
          Uri.parse("${Myconfig.baseURL}/pawpal/api/submit_pet.php"),

          body: {
            "userid": widget.user!.userId,
            "name": petName,
            "age": age,
            "type": petType,
            "category": category,
            'gender': gender,
            'health': health,
            "latitude": latitude,
            "longitude": longitude,
            "description": desc,
            "images": jsonEncode(base64Images),
          },
        )
        .then((response) {
          print(response.body);
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            print(resarray['success']);
            if (resarray['success'] == 'true') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resarray['message']),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              if (!mounted) return;
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