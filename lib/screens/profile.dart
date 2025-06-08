import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _stationData;
  bool _isLoading = true;
  bool _isEditing = false;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        final ref = FirebaseDatabase.instance.ref().child(
          'policeStations/${user.uid}',
        );
        final snapshot = await ref.get();

        if (snapshot.exists && snapshot.value != null) {
          final data = Map<String, dynamic>.from(
            (snapshot.value as Map<Object?, Object?>).map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          );

          setState(() {
            _stationData = data;
            for (var key in data.keys) {
              _controllers[key] = TextEditingController(text: data[key]);
            }
            _isLoading = false;
          });
        } else {
          setState(() {
            _stationData = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _stationData = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEdits() async {
    final user = _auth.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child(
        'policeStations/${user.uid}',
      );
      final updatedData = {
        for (var key in _controllers.keys) key: _controllers[key]!.text,
      };
      await ref.update(updatedData);
      setState(() {
        _isEditing = false;
        _stationData = updatedData;
      });
    }
  }

  Widget _buildInfoField(String label, String key, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child:
                _isEditing
                    ? TextFormField(
                      controller: _controllers[key],
                      decoration: InputDecoration(
                        labelText: label,
                        border: const OutlineInputBorder(),
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _stationData![key] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Station Profile"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveEdits();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _stationData == null
              ? const Center(child: Text("No data found."))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.account_balance,
                              size: 40,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _stationData!["policeStationName"] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _stationData!["email"] ?? '',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoField(
                      "Officer Name",
                      "officerName",
                      Icons.person,
                    ),
                    _buildInfoField(
                      "Station Code",
                      "stationCode",
                      Icons.confirmation_number,
                    ),
                    _buildInfoField("City", "city", Icons.location_city),
                    _buildInfoField("District", "district", Icons.map),
                    _buildInfoField("State", "state", Icons.flag),
                    _buildInfoField(
                      "Postal Code",
                      "postalCode",
                      Icons.local_post_office,
                    ),
                    _buildInfoField("Landline", "landline", Icons.phone),
                    _buildInfoField("Mobile", "mobile", Icons.phone_android),
                    _buildInfoField(
                      "Officer Contact",
                      "officerContact",
                      Icons.contact_phone,
                    ),
                    _buildInfoField(
                      "Jurisdiction",
                      "jurisdiction",
                      Icons.gavel,
                    ),
                    _buildInfoField("Address", "address", Icons.home),
                  ],
                ),
              ),
    );
  }
}
