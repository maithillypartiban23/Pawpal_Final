import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal1/myconfig.dart';
import 'package:pawpal1/models/mypet.dart';
import 'package:pawpal1/views/mydonation.dart';
import 'package:pawpal1/models/user.dart';

class DonationScreen extends StatefulWidget {
  final MyPet? pet;
  final User? user;

  DonationScreen({Key? key, required this.pet, required this.user}) : super(key: key);

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedDonationType = 'Food';
  final List<String> donationTypes = ['Food', 'Medical', 'Money'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        title: const Text('Donate for Pet'),
        backgroundColor: const Color(0xFFA66A46),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PET INFO
                    Text(widget.pet?.petName ?? '',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('${widget.pet?.petType} • Needs Help',
                        style: TextStyle(
                            color: Colors.grey[700], fontSize: 15)),
                    const Divider(height: 40),

                    // DONATION TYPE
                    const Text('Donation Type',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      value: selectedDonationType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: donationTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDonationType = value!;
                          amountController.clear();
                          descriptionController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // MONEY DONATION
                    if (selectedDonationType == 'Money')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Donation Amount (RM)',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Enter donation amount',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),

                    // FOOD / MEDICAL
                    if (selectedDonationType != 'Money')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Description',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: descriptionController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText:
                                  'Describe the food or medical help you want to provide',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 40),

                    // CONFIRM BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA66A46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: processDonation,
                        child: const Text('Confirm Donation',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= API CALL =================
  void processDonation() async {
    String description = descriptionController.text.trim();
    String amountRM =
        selectedDonationType == 'Money' ? amountController.text.trim() : '0';

    try {
      final response = await http.post(
        Uri.parse("${Myconfig.baseURL}/pawpal/api/donate_pet.php"),
        body: {
          'pet_id': widget.pet!.petId!,
          'user_id': widget.user!.userId!,
          'donation_type': selectedDonationType,
          'amount': amountRM,
          'description': description,
        },
      );

      var data = jsonDecode(response.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message'] ?? 'Donation processed'),
        backgroundColor: (data['success'] == true ||
                data['success'] == 'true')
            ? Colors.green
            : Colors.red,
        duration: const Duration(seconds: 3),
      ));

      if (data['success'] == true || data['success'] == 'true') {
        // Navigate to MyDonation page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => MyDonation(user: widget.user)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ));
    } finally {
      amountController.clear();
      descriptionController.clear();
    }
  }
}
