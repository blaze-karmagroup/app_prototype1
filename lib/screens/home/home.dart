import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:test7/screens/home/widgets/map_view.dart';
import '../../models/geofence.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  // final Map<String, dynamic>? employee;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String _statusMessage = 'Checking Location...';
  String _authStatusMessage = '';
  Position? _currentPosition;
  Map<String, dynamic>? _currentEmployee;
  bool _isLoading = false;
  Geofence? _currentGeofence;
  bool _attendanceMarked = false;

  List<Geofence> geoFences = [];

  @override
  void initState() {
    super.initState();
    _initLocationFlow();
    _fetchUserFromApi();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isInsideGeofence(Position userPosition, Geofence geofence) {
    double distanceBetween = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      geofence.latitude,
      geofence.longitude,
    );

    return distanceBetween <= geofence.radius;
  }

  void _checkUserGeoFences(Position userPosition, List<Geofence> geofences) {
    if (geofences.isEmpty) {
      setState(() {
        _statusMessage = "No geofences have been assigned to you.";
        _currentGeofence = null;
      });
      return;
    }

    Geofence? foundFence;
    for (var fence in geofences) {
      if (isInsideGeofence(userPosition, fence)) {
        foundFence = fence;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _currentGeofence = foundFence;
        if (foundFence != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "You're in ${foundFence.name} \n Lat: ${foundFence.latitude} \n Lon: ${foundFence.longitude}",
              ),
            ),
          );
          _statusMessage =
              "You're in ${foundFence.name} \n Lat: ${foundFence.latitude} \n Lon: ${foundFence.longitude}";
        } else {
          _statusMessage = "You are not inside any designated area.";
          _currentGeofence = null;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("You're not in any GeoFence")));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetchAssignedGeofences,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () async {
          //     await FirebaseAuth.instance.signOut();
          //     Navigator.pushReplacementNamed(context, '/login');
          //   },
          // ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal.shade900, Colors.grey.shade900],
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // GeofenceMap(
                      //   geoFences: geoFences,
                      //   userLatitude: _currentPosition?.latitude,
                      //   userLongitude: _currentPosition?.longitude,
                      // ),
                      const SizedBox(height: 16),
                      Text(
                        "Good Day, ${_currentEmployee?['Employee_Name'] ?? 'Guest'}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text(
                      //   _currentUser?.email ?? "Not Logged In",
                      //   style: const TextStyle(fontSize: 16, color: Colors.grey),
                      // ),
                      const SizedBox(height: 20),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        _authStatusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFF8F00),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _initLocationFlow,
                        child: const Text("Retry Location Check"),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _attendanceMarked ? null : _recordAttendance,
                        child: const Text("Record Attendance"),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        height: 200,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: geoFences.isEmpty
                            ? const Center(
                                child: Text(
                                  "Geofences assigned to you will be shown here...",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                itemCount: geoFences.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final fence = geoFences[index];

                                  return ListTile(
                                    visualDensity: VisualDensity.compact,
                                    title: Text(fence.name),
                                    subtitle: Text(
                                      "Lat: ${fence.latitude}, Lon: ${fence.longitude}",
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _fetchUserFromApi() async {
    setState(() => _isLoading = true);
    final userToken = FirebaseAuth.instance.currentUser;
    print('Fetched User Token: $userToken');

    if (userToken == null || userToken.uid.isEmpty) {
      print("User not logged in or phone number is missing from token.");
      if (mounted) {
        setState(() {
          _authStatusMessage = "Could not verify user.";
          _isLoading = false;
        });
      }
      return;
    }

    String rawUid = userToken.uid;
    String? userPhoneNumber;

    print('Logged in user phone: $userPhoneNumber');

    if (rawUid.startsWith("phone_")) {
      userPhoneNumber = rawUid.substring(6);
    } else {
      print("UID does not have the 'phone_' prefix. Using raw UID.");
      userPhoneNumber = rawUid;
    }

    print("Attempting to fetch $userPhoneNumber from API...");

    final url = Uri.parse(
      'http://192.168.10.128:8080/employee?mobile=+$userPhoneNumber',
    );
    print('Calling Api from: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      print("Response Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> employee = jsonDecode(response.body);
        print("Fetched employee: $employee");
        setState(() {
          _currentEmployee = employee;
          _isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
        if (mounted) {
          setState(() {
            _authStatusMessage = "Server Error: ${response.statusCode}";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("_fetchUserFromApi Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _initLocationFlow() async {
    bool ready = await checkLocationAndPermission(context);
    setState(() {
      _statusMessage = 'Initializing Location Flow...';
    });
    if (!ready) {
      setState(() {
        _statusMessage = 'Location check failed (permissions or GPS off)';
      });
      return;
    }

    try {
      LocationSettings settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _statusMessage = 'Location acquired...';
      });

      final List<Geofence>? fetchedGeofences = await _fetchAssignedGeofences();

      if (fetchedGeofences != null) {
        _checkUserGeoFences(position, fetchedGeofences);
      } else {
        setState(() {
          _statusMessage = "Could not load geofence data from server.";
        });
      }

      print("Current Position: ${position.latitude}, ${position.longitude}");
    } on TimeoutException {
      setState(() {
        _statusMessage = 'Error: Location fetch timed out';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching location: ${e.toString()}';
      });
    }
  }

  Future<void> _recordAttendance() async {
    if (_currentEmployee == null) {
      print("User not logged in or token not found.");
      if (mounted) {
        setState(() {
          _authStatusMessage =
              "_recordAttendance error: Could not verify user.";
        });
      }
      return;
    }

    if (_currentGeofence == null) {
      print("Cannot record attendance: Not inside any geofence.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Attendance can only be marked inside a designated area.",
          ),
        ),
      );
      return;
    }

    if (_currentPosition == null) {
      print("Cannot record attendance: Current location is unknown.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not determine your current location."),
        ),
      );
      return;
    }

    print("Attempting to insert user attendance through API...");

    final Map<String, dynamic> attendanceData = {
      'Employee_ID': _currentEmployee!['Employee_ID'],
      'Employee_Name': _currentEmployee!['Employee_Name'],
      'Date_Time': DateTime.now().toIso8601String(),
      'Mobile_no': _currentEmployee!['Mobile_no'],
      'Geofence_Name': _currentGeofence!.name,
      'Coordinates': {
        'lat': _currentPosition!.latitude,
        'lon': _currentPosition!.longitude,
      },
    };

    print('Attendance Data: $attendanceData');

    try {
      final url = Uri.parse('http://192.168.10.128:8080/record-attendance');
      print('Calling Api from: $url');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(attendanceData),
          )
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Current location attendance recorded successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Current location attendance recorded successfully"),
          ),
        );
        setState(() => _attendanceMarked = true);

        Future.delayed(const Duration(hours: 2), () {
          print('Enabling mark attendance button after 2 hours...');
          if (mounted) {
            setState(() => _attendanceMarked = false);
          }
        });
      } else {
        print('Failed to record attendance: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to record attendance")),
        );
      }
    } catch (e) {
      print("_recordAttendance Error: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error in _recordAttendance: $e")));
    }
  }

  Future<List<Geofence>?> _fetchAssignedGeofences() async {
    // final userToken = FirebaseAuth.instance.currentUser;
    // print('Fetched User Token: $userToken');
    //
    // if (userToken == null || userToken.uid.isEmpty) {
    //   print("User not logged in or phone number is missing from token.");
    //   if (mounted) {
    //     setState(() {
    //       _authStatusMessage = "Could not verify user.";
    //       _isLoading = false;
    //     });
    //   }
    //   return;
    // }
    //
    // String rawUid = userToken.uid;
    // String? userPhoneNumber;
    //
    // if (rawUid.startsWith("phone_")) {
    //   userPhoneNumber = rawUid.substring(6);
    // } else {
    //   print("UID does not have the 'phone_' prefix. Using raw UID.");
    //   userPhoneNumber = rawUid;
    // }

    try {
      final url = Uri.parse('http://192.168.10.128:8080/geofences');
      print('Calling Api from: $url');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> geofenceData = jsonDecode(response.body);

        final List<Geofence> fetchedGeofences = geofenceData
            .map((item) => Geofence.fromJson(item))
            .toList();

        setState(() {
          geoFences = fetchedGeofences;
        });

        print("Fetched geofences: $fetchedGeofences");
        return fetchedGeofences;
      }
    } catch (e) {
      print("_fetchAssignedGeofences Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching geofences.")),
      );
    }
    return null;
  }

  Future<bool> checkLocationAndPermission(BuildContext context) async {
    bool locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Location'),
          content: const Text(
            'Location is turned off. Please enable GPS to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
      return false;
    }
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Permission Needed"),
            content: const Text(
              "This app needs location permission to work. Please allow it.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Retry"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Geolocator.openAppSettings(); // open settings manually
                },
                child: const Text("Open App Settings"),
              ),
            ],
          ),
        );
        return false;
      }
    }
    if (locationPermission == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Permanently Denied"),
          content: const Text(
            "This app needs location permission to work. Please allow it from settings.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }
}
