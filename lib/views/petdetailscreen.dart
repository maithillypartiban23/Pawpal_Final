import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal1/shared/animated_route.dart';
import 'package:pawpal1/myconfig.dart';
import 'package:pawpal1/models/pet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pawpal1/models/user.dart';
import 'donation_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;
  User? user;

  PetDetailScreen({super.key, required this.pet, required this.user});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

  final TextEditingController reasonController = TextEditingController();
  final TextEditingController donationAmountController =
      TextEditingController();

  String selectedDonationType = 'Food';
  final List<String> donationTypes = ['Food', 'Money', 'Medicine'];

  final Color themeBrown = const Color(0xFF6D4C41);

  @override
  Widget build(BuildContext context) {
    List<dynamic> imageList = jsonDecode(widget.pet.imagePaths ?? '[]');
    String formattedDate =
        formatter.format(DateTime.parse(widget.pet.createdAt.toString()));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        title: Text(widget.pet.petName ?? 'Pet Details'),
        backgroundColor: themeBrown,
        elevation: 2,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ================= IMAGE GALLERY =================
                SizedBox(
                  height: 320,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return Container(
                        width: 460,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            '${Myconfig.baseURL}/pawpal/api/${imageList[index]}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 80),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                /// ================= HEADER =================
                Text(
                  widget.pet.petName ?? '',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.pet.petType} • ${widget.pet.category}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                /// ================= DETAILS CARD =================
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _detailItem('Gender', widget.pet.petGender),
                        _detailItem('Age', widget.pet.petAge),
                        _detailItem('Health', widget.pet.petHealth),
                        _detailItem('Description', widget.pet.description),
                        const Divider(height: 30),
                        _detailItem('Posted By', widget.pet.name),
                        _detailItem('Phone', widget.pet.phone),
                        _detailItem('Email', widget.pet.email),
                        _detailItem('Posted On', formattedDate),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// ================= CONTACT CARD =================
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _contactButton(Icons.call, 'Call', () {
                          launchUrl(Uri.parse('tel:${widget.pet.phone}'));
                        }),
                        _contactButton(Icons.message, 'SMS', () {
                          launchUrl(Uri.parse('sms:${widget.pet.phone}'));
                        }),
                        _contactButton(Icons.email, 'Email', () {
                          launchUrl(Uri.parse('mailto:${widget.pet.email}'));
                        }),
                        _contactButton(Icons.wechat, 'WhatsApp', () {
                          launchUrl(
                              Uri.parse('https://wa.me/${widget.pet.phone}'));
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// ================= MAIN ACTION =================
                if (widget.pet.category == 'Adoption')
                  _primaryButton('Request to Adopt', () {
                    showAdoptionDialog();
                  }),

                if (widget.pet.category == 'Donation')
                  _primaryButton('Donate', () {
                    Navigator.push(
                      context,
                      AnimatedRoute.slideFromRight(
                        DonationScreen(
                          pet: widget.pet,
                          user: widget.user!,
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= UI HELPERS =================

  Widget _detailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: themeBrown,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactButton(
      IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: themeBrown.withOpacity(0.12),
            child: Icon(icon, color: themeBrown),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _primaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeBrown,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// ================= ADOPTION DIALOG =================

  void showAdoptionDialog() {
    if (widget.pet.userId == widget.user!.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot adopt your own pet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request to Adopt',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Commit Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () =>
                          requestAdoption(widget.pet.petId),
                      child: const Text('Submit'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void requestAdoption(String? petId) {
    http.post(
      Uri.parse("${Myconfig.baseURL}/pawpal/api/request_adopt.php"),
      body: {
        'pet_id': petId,
        'user_id': widget.user!.userId,
        'reason': reasonController.text.trim(),
      },
    ).then((response) {
      var data = jsonDecode(response.body);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor:
              data['success'] ? Colors.green : Colors.red,
        ),
      );
      reasonController.clear();
    });
  }
}
