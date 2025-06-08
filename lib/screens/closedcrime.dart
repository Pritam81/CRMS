import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ClosedCrimesScreen extends StatefulWidget {
  final String policeStationId;

  const ClosedCrimesScreen({super.key, required this.policeStationId});

  @override
  State<ClosedCrimesScreen> createState() => _ClosedCrimesScreenState();
}

class _ClosedCrimesScreenState extends State<ClosedCrimesScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> closedCrimes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClosedCrimes();
  }

  Future<void> fetchClosedCrimes() async {
    final ref = _db.child("crime_records/${widget.policeStationId}");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      List<Map<String, dynamic>> temp = [];

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      data.forEach((key, value) {
        final crime = Map<String, dynamic>.from(value);
        if (crime['status'] == 'closed') {
          crime['key'] = key; // store Firebase key for future use
          temp.add(crime);
        }
      });

      setState(() {
        closedCrimes = temp;
        isLoading = false;
      });
    } else {
      setState(() {
        closedCrimes = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Closed Crime Records'),
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : closedCrimes.isEmpty
              ? const Center(child: Text("No closed records found."))
              : ListView.builder(
                  itemCount: closedCrimes.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final crime = closedCrimes[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crime['crime_type'] ?? 'Unknown Crime',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('FIR Number: ${crime['fir_number']}'),
                            Text('Location: ${crime['location']}'),
                            Text('Accused: ${crime['accused']}'),
                            Text('Victim: ${crime['victim']}'),
                            const SizedBox(height: 6),
                            Text(
                              crime['description'] ?? '',
                              style: const TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Status: Closed',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Date: ${crime['date_time'].toString().split('T').first}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
