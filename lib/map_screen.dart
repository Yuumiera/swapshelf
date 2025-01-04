import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/user_avatar.dart';
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
  bool _isLoading = false;

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
    setState(() => _isLoading = true);
    try {
      // Konum izni kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Konum izni reddedildi');
        }
      }

      // Konum servisi açık mı kontrolü
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Konum servisi kapalı');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      });

      // Konumu Firestore'a kaydet
      await _updateUserLocation();
    } catch (e) {
      print('Konum alma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konum alınamadı: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
                      // Mevcut kullanıcının konumu
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
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              child: UserAvatar(
                                userId: _auth.currentUser!.uid,
                                size: 60,
                              ),
                            ),
                          ),
                        ),
                      // Diğer kullanıcıların konumları
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
              onPressed: _isLoading ? null : _getCurrentLocation,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Icon(Icons.my_location),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
