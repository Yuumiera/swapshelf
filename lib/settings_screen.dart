import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/language_settings_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/location_services_screen.dart';

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
        title: Text(
          'Settings',
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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection(
            'Account',
            [
              _buildSettingTile(
                icon: Icons.person,
                title: 'Edit Profile',
                color: Color(0xFF1E88E5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen()),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.lock,
                title: 'Change Password',
                color: Color(0xFF43A047),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen()),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            'Notifications',
            [
              _buildSettingTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                color: Color(0xFF7E57C2),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Switch değişim işlevi
                  },
                  activeColor: Color(0xFF7E57C2),
                ),
              ),
              _buildSettingTile(
                icon: Icons.email,
                title: 'Email Notifications',
                color: Color(0xFF7E57C2),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // Email bildirimleri değişim işlevi
                  },
                  activeColor: Color(0xFF7E57C2),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            'Privacy',
            [
              _buildSettingTile(
                icon: Icons.location_on,
                title: 'Location Services',
                color: Color(0xFFEF5350),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LocationServicesScreen()),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.visibility,
                title: 'Profile Visibility',
                color: Color(0xFFFF7043),
                onTap: () {
                  // Profil görünürlüğü işlevi
                },
              ),
              _buildSettingTile(
                icon: Icons.block,
                title: 'Blocked Users',
                color: Color(0xFFEF5350),
                onTap: () {
                  // Engellenen kullanıcılar işlevi
                },
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            'App Settings',
            [
              _buildSettingTile(
                icon: Icons.language,
                title: 'Language',
                color: Color(0xFF1E88E5),
                trailing: Text('English'),
                onTap: () {
                  // Dil seçimi işlevi
                },
              ),
              _buildSettingTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                color: Color(0xFF5E35B1),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // Karanlık mod değişim işlevi
                  },
                  activeColor: Color(0xFF5E35B1),
                ),
              ),
              _buildSettingTile(
                icon: Icons.notifications_active,
                title: 'Sound Effects',
                color: Color(0xFF00897B),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // Ses efektleri değişim işlevi
                  },
                  activeColor: Color(0xFF00897B),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            'Support',
            [
              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                color: Color(0xFF546E7A),
                onTap: () {
                  // Yardım merkezi işlevi
                },
              ),
              _buildSettingTile(
                icon: Icons.feedback,
                title: 'Send Feedback',
                color: Color(0xFF546E7A),
                onTap: () {
                  // Geri bildirim gönderme işlevi
                },
              ),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'About',
                color: Color(0xFF546E7A),
                onTap: () {
                  // Uygulama hakkında işlevi
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
      ),
    );
  }
}
