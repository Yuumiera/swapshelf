import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<bool> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      // Tüm gerekli izinleri kontrol et
      List<Permission> permissions = [
        Permission.camera,
        Permission.storage,
        Permission.photos,
        Permission.mediaLibrary,
      ];

      // Android 13+ için ek izinler
      if (int.parse(await DeviceInfoPlugin()
              .androidInfo
              .then((value) => value.version.release)) >=
          13) {
        permissions.addAll([
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ]);
      }

      // İzin durumlarını kontrol et
      Map<Permission, PermissionStatus> statuses = await permissions.request();

      bool allGranted = true;
      statuses.forEach((permission, status) {
        if (!status.isGranted) {
          allGranted = false;
        }
      });

      if (!allGranted) {
        // İzinler reddedildiyse kullanıcıya ayarları açma seçeneği sun
        if (!mounted) return false;

        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('İzinler Gerekli'),
            content: Text(
                'Resim seçmek için gerekli izinleri vermeniz gerekmektedir. Lütfen ayarlardan tüm izinleri verin.'),
            actions: [
              TextButton(
                child: Text('İptal'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Ayarları Aç'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        return false;
      }
      return true;
    }
    return true;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      bool permissionsGranted = await _checkAndRequestPermissions();
      if (!permissionsGranted) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim seçilirken bir hata oluştu: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resim Kaynağı Seçin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeriden Seç'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Kitap Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Resim seçme butonu
            ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              icon: Icon(Icons.add_photo_alternate),
              label: Text('Resim Seç'),
            ),
            if (selectedImage != null) ...[
              SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Book Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    authorController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance.collection('wishes').add({
                      'title': titleController.text.trim(),
                      'author': authorController.text.trim(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Book added successfully!')),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields!')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
