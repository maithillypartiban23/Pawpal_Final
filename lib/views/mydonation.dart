import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal1/myconfig.dart';
import 'package:pawpal1/models/user.dart';

class MyDonation extends StatefulWidget {
  final User? user;
  const MyDonation({Key? key, required this.user}) : super(key: key);

  @override
  State<MyDonation> createState() => _MyDonationState();
}

class _MyDonationState extends State<MyDonation> {
  List<dynamic> donations = [];
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadDonations();
  }

  void loadDonations() async {
    final response = await http.get(Uri.parse(
        "${Myconfig.baseURL}/pawpal/api/get_my_donation.php?userid=${widget.user!.userId}"));

    try {
      var data = jsonDecode(response.body);
      if (data['success'] == true || data['success'] == 'true') {
        setState(() {
          donations = data['data'];
          status = donations.isEmpty ? "No donations yet" : "";
        });
      } else {
        setState(() {
          status = "No donations yet";
        });
      }
    } catch (e) {
      setState(() {
        status = "Failed to load donations";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE9D9),
      appBar: AppBar(
        title: const Text("My Donations"),
        backgroundColor: const Color(0xFFA66A46),
        foregroundColor: Colors.white,
      ),
      body: donations.isEmpty
          ? Center(
              child: Text(
                status,
                style: const TextStyle(
                  color: Color(0xFF8B5E3C),
                  fontSize: 16,
                ),
              ),
            )
          : Center(
              child: SizedBox(
                width: 800,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final donation = donations[index];
                    final isMoney =
                        donation['donation_type'] == 'Money';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER
                            Text(
                              donation['pet_name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B5E3C),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // TYPE CHIP
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9BFA7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                donation['donation_type'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5D4037),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // DETAILS
                            if (!isMoney)
                              _infoRow(
                                "Description",
                                donation['donation_description'],
                              ),

                            if (isMoney)
                              _infoRow(
                                "Amount",
                                "RM ${donation['amount']}",
                              ),

                            _infoRow(
                              "Date",
                              donation['donation_date']
                                  .split(' ')[0],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D4C41),
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF5D4037),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
