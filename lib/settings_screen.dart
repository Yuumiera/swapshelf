import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Edit Profile'),
            subtitle: Text('Change your profile information'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Manage your notifications'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Bildirim ayarları sayfasına yönlendir
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Privacy'),
            subtitle: Text('Manage your privacy settings'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Gizlilik ayarları sayfasına yönlendir
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('Change app language'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Dil ayarları sayfasına yönlendir
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            subtitle: Text('Get help or contact support'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Yardım sayfasına yönlendir
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('App information and version'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Uygulama bilgileri sayfasına yönlendir
            },
          ),
        ],
      ),
    );
  }
}
