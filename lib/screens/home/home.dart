import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test7/screens/home/widgets/map_view.dart';

import '../../models/geofence.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // final user = FirebaseAuth.instance.currentUser;
  User? _currentUser;
  StreamSubscription<User?>? _authStateSubscription;
  String _statusMessage = 'Checking Location...';
  Position? _currentPosition;

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
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print("MyHomePage AuthStateChanged: UserId: ${user?.uid}, DisplayName: ${user?.displayName}");
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
    _initLocationFlow();
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
    bool found = false;
    for (var fence in geoFences) {
      if (isInsideGeofence(userPosition, fence)) {
        setState(() {
          _statusMessage =
              "You're in ${fence.name} \n Lat: ${fence.latitude} \n Lon: ${fence.longitude}";
        });
        found = true;
        break;
      }
    }

    if (!found) {
      setState(() {
        _statusMessage = "You're not in any GeoFence";
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
                  "Good Day, ${_currentUser?.displayName ?? (_currentUser != null ? _currentUser?.email : 'Guest')}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentUser?.email ?? "Not Logged In",
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
                  child: const Text("Retry Location Check"),
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

      setState(() {
        _currentPosition = position;
        _statusMessage = 'Location acquired';
      });

      _checkUserGeoFences(position);

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
