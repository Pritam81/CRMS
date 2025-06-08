import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PoliceStationRegistrationPage extends StatefulWidget {
  const PoliceStationRegistrationPage({Key? key}) : super(key: key);

  @override
  State<PoliceStationRegistrationPage> createState() =>
      _PoliceStationRegistrationPageState();
}

class _PoliceStationRegistrationPageState
    extends State<PoliceStationRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _psNameController = TextEditingController();
  final _stationCodeController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedState;
  final _postalCodeController = TextEditingController();
  final _landlineController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _officerNameController = TextEditingController();
  final _officerContactController = TextEditingController();
  final _jurisdictionController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Dropdown options (example)
  final List<String> _cities = ['Gangtok', 'Namchi', 'Gyalshing', 'Mangan'];
  final List<String> _districts = ['East', 'West', 'North', 'South'];
  final List<String> _states = ['Sikkim']; // Single example for demo

  bool _isSubmitting = false;

  // Password visibility toggle
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    // Dispose controllers
    _psNameController.dispose();
    _stationCodeController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _landlineController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _officerNameController.dispose();
    _officerContactController.dispose();
    _jurisdictionController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _formKey.currentState?.validate() ?? false;
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Step 1: Create user with Firebase Auth
      UserCredential authResult = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final currentUser = authResult.user;

      // Step 2: If user created, store data in Realtime Database
      if (currentUser != null) {
        final userId = currentUser.uid;

        Map<String, String> stationData = {
          "id": userId,
          "policeStationName": _psNameController.text.trim(),
          "stationCode": _stationCodeController.text.trim(),
          "address": _addressController.text.trim(),
          "city": _selectedCity ?? '',
          "district": _selectedDistrict ?? '',
          "state": _selectedState ?? '',
          "postalCode": _postalCodeController.text.trim(),
          "landline": _landlineController.text.trim(),
          "mobile": _mobileController.text.trim(),
          "email": _emailController.text.trim(),
          "officerName": _officerNameController.text.trim(),
          "officerContact": _officerContactController.text.trim(),
          "jurisdiction": _jurisdictionController.text.trim(),
          "username": _usernameController.text.trim(),
          "createdAt": DateTime.now().toIso8601String(),
        };

        DatabaseReference userRef = FirebaseDatabase.instance.ref().child(
          "policeStations",
        );
        await userRef.child(userId).set(stationData);

        // Step 3: Toast and Navigate
        await Fluttertoast.showToast(
          msg: "Police Station Registered Successfully!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // var prefs = await SharedPreferences.getInstance();
        // prefs.setBool("islogin", true);

        _formKey.currentState?.reset();
        Navigator.of(context).pop(); // Or navigate to login/home
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        errorMsg = 'Email already in use.';
      } else if (e.code == 'weak-password') {
        errorMsg = 'Password is too weak.';
      }

      Fluttertoast.showToast(
        msg: errorMsg,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Police Station'),
        centerTitle: true,
        elevation: 2,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 600 : double.infinity,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      SizedBox(
                        height: 160,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      // Police Station Name
                      TextFormField(
                        controller: _psNameController,
                        decoration: const InputDecoration(
                          labelText: 'Police Station Name *',
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        validator:
                            (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Station Code (optional)
                      TextFormField(
                        controller: _stationCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Station Code / ID (Optional)',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Address (multiline)
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          prefixIcon: Icon(Icons.home),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                        validator:
                            (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // City, District, State, Postal Code - dropdowns and input
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'City *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_city),
                              ),
                              value: _selectedCity,
                              items:
                                  _cities
                                      .map(
                                        (city) => DropdownMenuItem(
                                          value: city,
                                          child: Text(city),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) => setState(() => _selectedCity = val),
                              validator:
                                  (val) => val == null ? 'Select city' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'District *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.map),
                              ),
                              value: _selectedDistrict,
                              items:
                                  _districts
                                      .map(
                                        (dist) => DropdownMenuItem(
                                          value: dist,
                                          child: Text(dist),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) =>
                                      setState(() => _selectedDistrict = val),
                              validator:
                                  (val) =>
                                      val == null ? 'Select district' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'State *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.map),
                              ),
                              value: _selectedState,
                              items:
                                  _states
                                      .map(
                                        (state) => DropdownMenuItem(
                                          value: state,
                                          child: Text(state),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) => setState(() => _selectedState = val),
                              validator:
                                  (val) => val == null ? 'Select state' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _postalCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Postal Code *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.local_post_office),
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (!RegExp(
                                  r'^\d{5,6}$',
                                ).hasMatch(val.trim())) {
                                  return 'Invalid postal code';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Phone numbers
                      TextFormField(
                        controller: _landlineController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (Landline) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          if (!RegExp(r'^\d{6,15}$').hasMatch(val.trim())) {
                            return 'Invalid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _mobileController,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.smartphone),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(val.trim())) {
                            return 'Invalid mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Address
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(val.trim())) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Officer-in-Charge Name
                      TextFormField(
                        controller: _officerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Officer-in-Charge Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        textInputAction: TextInputAction.next,
                        validator:
                            (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Officer Contact Number
                      TextFormField(
                        controller: _officerContactController,
                        decoration: const InputDecoration(
                          labelText: 'Officer Contact Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_android),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(val.trim())) {
                            return 'Invalid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Jurisdiction Area (optional)
                      TextFormField(
                        controller: _jurisdictionController,
                        decoration: const InputDecoration(
                          labelText: 'Jurisdiction Area (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_circle),
                        ),
                        textInputAction: TextInputAction.next,
                        validator:
                            (val) =>
                                val == null || val.trim().isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          if (val.trim().length < 6) {
                            return 'Min 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                ),
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Required';
                          }
                          if (val != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Upload Verification Document (optional)

                      // Register Button
                      ElevatedButton(
                        onPressed:
                            _isFormValid && !_isSubmitting ? _trySubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child:
                            _isSubmitting
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                                : const Text(
                                  'Register',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),

                      const SizedBox(height: 16),

                      // Link back to Login page
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Back to Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
