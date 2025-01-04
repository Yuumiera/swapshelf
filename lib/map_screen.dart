import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/user_avatar.dart';
import 'profile_screen.dart';
import 'user_profile_view.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _currentPosition;
  final MapController _mapController = MapController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updateUserLocation();
  }

  Future<void> _updateUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'location': GeoPoint(position.latitude, position.longitude),
          'lastLocationUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating user location: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          13.0,
        );
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _goToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        13.0,
      );
    }
  }

  void _showUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileView(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .where('lastLocationUpdate',
                    isGreaterThan: Timestamp.fromDate(
                        DateTime.now().subtract(Duration(hours: 24))))
                .snapshots(),
            builder: (context, snapshot) {
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _currentPosition != null
                      ? LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        )
                      : LatLng(41.0082, 28.9784),
                  zoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      if (_currentPosition != null && _auth.currentUser != null)
                        Marker(
                          point: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          width: 60,
                          height: 60,
                          builder: (context) => GestureDetector(
                            onTap: () =>
                                _showUserProfile(_auth.currentUser!.uid),
                            child: UserAvatar(
                              userId: _auth.currentUser!.uid,
                              size: 60,
                            ),
                          ),
                        ),
                      ...snapshot.data?.docs
                              .map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final location = data['location'] as GeoPoint?;
                                if (location != null &&
                                    doc.id != _auth.currentUser?.uid) {
                                  return Marker(
                                    point: LatLng(
                                        location.latitude, location.longitude),
                                    width: 50,
                                    height: 50,
                                    builder: (context) => GestureDetector(
                                      onTap: () => _showUserProfile(doc.id),
                                      child: UserAvatar(
                                        userId: doc.id,
                                        size: 50,
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              })
                              .whereType<Marker>()
                              .toList() ??
                          [],
                    ],
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              child: Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              color: Colors.white.withOpacity(0.8),
              child: Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
