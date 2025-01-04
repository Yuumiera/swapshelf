import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationServicesScreen extends StatefulWidget {
  @override
  _LocationServicesScreenState createState() => _LocationServicesScreenState();
}

class _LocationServicesScreenState extends State<LocationServicesScreen> {
  bool _isLocationEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final locationEnabled = prefs.getBool('location_enabled') ?? false;
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();

    setState(() {
      _isLocationEnabled = locationEnabled &&
          serviceEnabled &&
          (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse);
      _isLoading = false;
    });
  }

  Future<void> _toggleLocationServices() async {
    if (_isLocationEnabled) {
      // Konum servisini kapat
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_enabled', false);
      setState(() => _isLocationEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services disabled')),
      );
    } else {
      // Konum servisini aç
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showSettingsDialog();
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final result = await _showEnableLocationDialog();
        if (result != true) return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_enabled', true);
      setState(() => _isLocationEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services enabled')),
      );
    }
  }

  Future<bool?> _showEnableLocationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enable Location Services'),
        content: Text(
            'Location services are required to show your location on the map. Would you like to enable location services?'),
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('SETTINGS'),
            onPressed: () {
              Navigator.pop(context, true);
              AppSettings.openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text(
            'Location permission is required to show your location on the map. Please enable it in settings.'),
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('SETTINGS'),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Location Services',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Enable Location Services',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Allow the app to access your location to show you on the map',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Switch(
                          value: _isLocationEnabled,
                          onChanged: (value) => _toggleLocationServices(),
                          activeColor: Color(0xFFEF5350),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Location services are used to show your position on the map and help other users find books near them.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
    );
  }
}
