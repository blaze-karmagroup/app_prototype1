import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:test7/screens/home/widgets/map_view.dart';

import '../../models/geofence.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.employeeData});

  final String title;
  final Map<String, dynamic>? employeeData;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // final user = FirebaseAuth.instance.currentUser;
  User? _currentUser;
  StreamSubscription<User?>? _authStateSubscription;
  String _statusMessage = 'Checking Location...';
  Position? _currentPosition;
  String? employeeId;
  String? employeeName;
  Geofence? _currentGeofence;

  List<Geofence> geoFences = [
    Geofence(
      id: "1",
      name: "Car Parking",
      latitude: 15.175448,
      longitude: 73.949296,
      radius: 10,
    ),
    Geofence(
      id: "2",
      name: "Slide Pool",
      latitude: 15.175858,
      longitude: 73.948252,
      radius: 10,
    ),
    Geofence(
      id: "3",
      name: "Splash Bar",
      latitude: 15.175573,
      longitude: 73.948259,
      radius: 10,
    ),
    Geofence(
      id: "4",
      name: "Restaurant",
      latitude: 15.175269,
      longitude: 73.948058,
      radius: 10,
    ),
    Geofence(
      id: "5",
      name: "Time Office",
      latitude: 15.175058,
      longitude: 73.947809,
      radius: 10,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      print(
        "MyHomePage AuthStateChanged: UserId: ${user?.uid}, DisplayName: ${user?.displayName}",
      );
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
    _initLocationFlow();
    if (widget.employeeData != null) {
      employeeId = widget.employeeData!['id'].toString();
      employeeName = widget.employeeData!['empName'];
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
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

  void _checkUserGeoFences(Position userPosition) {
    Geofence? foundFence;
    for (var fence in geoFences) {
      if (isInsideGeofence(userPosition, fence)) {
        foundFence = fence;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _currentGeofence = foundFence;
        if (foundFence != null) {
          _statusMessage =
              "You're in ${foundFence.name} \n Lat: ${foundFence.latitude} \n Lon: ${foundFence.longitude}";
        } else {
          _statusMessage = "You're not in any GeoFence";
        }
      });
    }
  }

  void _sortGeoFencesByDistance() {
    if (_currentPosition == null) {
      print("User location not available to sort geofences.");
      return;
    }

    geoFences.sort((a, b) {
      double distanceToA = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        a.latitude,
        a.longitude,
      );

      double distanceToB = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        b.latitude,
        b.longitude,
      );

      return distanceToA.compareTo(distanceToB);
    });

    if (mounted) {
      setState(() {});
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
            onPressed: _initLocationFlow,
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // GeofenceMap(
                //   geoFences: geoFences,
                //   userLatitude: _currentPosition?.latitude,
                //   userLongitude: _currentPosition?.longitude,
                // ),
                if (_currentUser?.photoURL != null)
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(_currentUser!.photoURL!),
                  ),
                const SizedBox(height: 16),
                Text(
                  "Good Day, $employeeName",
                  // "Good Day, ${_currentUser?.displayName ?? (_currentUser != null ? _currentUser?.email : 'Guest')}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentUser?.email ?? "Not Logged In (G-Auth)",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _initLocationFlow,
                  child: const Text("Re-Check Location"),
                ),
                ElevatedButton(
                  onPressed: _markAttendance,
                  child: const Text("Mark Attendance"),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Available Locations:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent,
                  ),
                ),
                const SizedBox(height: 16),
                geoFences.isEmpty
                    ? const Text(
                        "No geofences defined.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : SizedBox(
                        height: 300,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: geoFences.length,
                          itemBuilder: (BuildContext context, int index) {
                            final fence = geoFences[index];
                            return ListTile(
                              leading: Icon(
                                Icons.location_pin,
                                color: Colors.tealAccent.withOpacity(0.8),
                                size: 28,
                              ),
                              title: Text(
                                fence.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                "Lat: ${fence.latitude.toStringAsFixed(4)}, Lon: ${fence.longitude.toStringAsFixed(4)}",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              color: Colors.teal.withOpacity(0.3),
                              indent: 16,
                              endIndent: 16,
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

  /*
  Future<void> checkUserGeoFences(
    Position userPosition,
    List<Geofence> geoFences,
  ) async {
    for (var fence in geoFences) {
      if (isInsideGeofence(userPosition, fence)) {
        print("User is in ${fence.name}");
        return;
      }
    }
    print("User is not in any GeoFence");
  }
   */

  Future<void> _initLocationFlow() async {
    bool ready = await checkLocationAndPermission(context);
    setState(() {
      _statusMessage = 'Location check failed (permissions or GPS off)';
    });
    if (!ready) {
      setState(() {
        _statusMessage = 'Location check failed (permissions or GPS off)';
      });
      return;
    }

    try {
      LocationSettings settings = const LocationSettings(
        accuracy: LocationAccuracy
            .high, // distanceFilter: 0, // optional: only if you want to restrict updates
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _statusMessage = 'Location acquired, checking geofences...';
        });
      }

      _checkUserGeoFences(position);
      _sortGeoFencesByDistance();

      print("Current Position: ${position.latitude}, ${position.longitude}");
    } on TimeoutException {
      setState(() {
        _statusMessage = 'Error: Location fetch timed out';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error fetching location: ${e.toString()}';
          _currentGeofence = null;
        });
      }
      print('Error in _initLocationFlow: $e');
    }
  }

  Future<void> _markAttendance() async {
    if (widget.employeeData == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No employee data found")));
      return;
    }

    final supaBase = Supabase.instance.client;

    try {
      final empId = widget.employeeData!['id'];
      final empName = widget.employeeData!['empName'];
      final phone = widget.employeeData!['mobileNumber'];

      final data = {
        'empId': empId,
        'mobileNumber': phone,
        'dateTime': DateTime.now().toIso8601String(),

        'geofenceName': _currentGeofence!.name,
        // 'coordinates': "${_currentGeofence!.latitude + _currentGeofence!.longitude}",
      };

      final response = await supaBase.from('Attendance').insert(data).select();

      if (response != null) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            // Changed context name to avoid conflict
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Attendance recorded successfully!'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Dismiss the dialog
                  },
                ),
              ],
            );
          },
        );
      }

      print("Insert response: $response");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Attendance marked successfully")));
    } catch (e) {
      print("Error marking attendance: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error marking attendance: $e")));
    }
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
                  Geolocator.openAppSettings();
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
