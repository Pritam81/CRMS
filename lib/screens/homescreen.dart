import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String? policeStationId;

  @override
  void initState() {
    super.initState();
    policeStationId = _auth.currentUser?.uid;
  }

  Future<List<Map<String, dynamic>>> _fetchCrimeRecords() async {
    final snapshot =
        await _database.ref("crime_records/$policeStationId").once();
    if (snapshot.snapshot.value == null) return [];
    final Map<dynamic, dynamic> data = snapshot.snapshot.value as Map;
    return data.entries
        .map((e) => {...Map<String, dynamic>.from(e.value), 'key': e.key})
        .toList();
  }

  void _logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacementNamed(context, '/mainscreen');
  }

  void _showAddCrimeDialog({Map<String, dynamic>? existingRecord}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _type = TextEditingController(
      text: existingRecord?['crime_type'] ?? '',
    );
    final TextEditingController _accused = TextEditingController(
      text: existingRecord?['accused'] ?? '',
    );
    final TextEditingController _victim = TextEditingController(
      text: existingRecord?['victim'] ?? '',
    );
    final TextEditingController _location = TextEditingController(
      text: existingRecord?['location'] ?? '',
    );
    final TextEditingController _fir = TextEditingController(
      text: existingRecord?['fir_number'] ?? '',
    );
    final TextEditingController _description = TextEditingController(
      text: existingRecord?['description'] ?? '',
    );
    DateTime selectedDate =
        existingRecord != null
            ? DateTime.parse(existingRecord['date_time'])
            : DateTime.now();
    String status = existingRecord?['status'] ?? 'Open';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Crime Record Details"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _type,
                    decoration: const InputDecoration(labelText: "Crime Type"),
                    validator:
                        (val) => val!.isEmpty ? 'Enter crime type' : null,
                  ),
                  TextFormField(
                    controller: _accused,
                    decoration: const InputDecoration(
                      labelText: "Accused Name",
                    ),
                  ),
                  TextFormField(
                    controller: _victim,
                    decoration: const InputDecoration(labelText: "Victim Name"),
                  ),
                  TextFormField(
                    controller: _location,
                    decoration: const InputDecoration(
                      labelText: "Crime Location",
                    ),
                  ),
                  TextFormField(
                    controller: _fir,
                    decoration: const InputDecoration(labelText: "FIR Number"),
                  ),
                  TextFormField(
                    controller: _description,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                  ),
                  Row(
                    children: [
                      const Text("Date: "),
                      Text(
                        DateFormat('yyyy-MM-dd – kk:mm').format(selectedDate),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                selectedDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 'Open', child: Text('Open')),
                      DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                    ],
                    onChanged: (value) => status = value!,
                    decoration: const InputDecoration(labelText: "Status"),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newRecord = {
                    'crime_type': _type.text.trim(),
                    'accused': _accused.text.trim(),
                    'victim': _victim.text.trim(),
                    'location': _location.text.trim(),
                    'fir_number': _fir.text.trim(),
                    'description': _description.text.trim(),
                    'status': status,
                    'date_time': selectedDate.toIso8601String(),
                    'created_at': DateTime.now().toIso8601String(),
                  };

                  final ref = _database.ref("crime_records/$policeStationId");
                  if (existingRecord == null) {
                    await ref.push().set(newRecord);
                  } else {
                    await ref.child(existingRecord['key']).set(newRecord);
                  }

                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDetailDialog(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("${record['crime_type']} Details"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  record.entries
                      .where((e) => e.key != 'key')
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text("${e.key}: ${e.value}"),
                        ),
                      )
                      .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteRecord(String key) async {
    await _database.ref("crime_records/$policeStationId/$key").remove();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Crime Records")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 158, 212, 255),
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('All Crime Records'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Closed Cases'),
              onTap: () => Navigator.pushNamed(context, '/closedcrimes'),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Under Investigations'),
              onTap: () => Navigator.pushNamed(context, '/opencrimes'),
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCrimeRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No crime records found.'));
          }

          final records = snapshot.data!;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: () => _showDetailDialog(record),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.gavel, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                record['crime_type'] ?? 'Unknown Crime',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                              ),
                              onPressed:
                                  () => _showAddCrimeDialog(
                                    existingRecord: record,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteRecord(record['key']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('yyyy-MM-dd – kk:mm').format(
                                DateTime.parse(record['date_time'] ?? ''),
                              ),
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Status: ${record['status'] ?? 'N/A'}',
                          style: TextStyle(
                            color:
                                (record['status'] ?? '')
                                            .toString()
                                            .toLowerCase() ==
                                        'closed'
                                    ? Colors.green
                                    : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'FIR Number: ${record['fir_number'] ?? 'Not Issued'}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCrimeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
