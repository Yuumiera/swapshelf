import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';
import 'map_screen.dart';
import 'package:swapshelfproje/exchange_screen.dart';
import 'home_screen.dart';
import 'package:swapshelfproje/message_to_person.dart';
import 'wishes_screen.dart'; // Yeni eklediğimiz isteklerim ekranı
import 'package:swapshelfproje/widgets/custom_background.dart';
import 'package:swapshelfproje/widgets/gradient_app_bar.dart';
import 'package:swapshelfproje/widgets/gradient_bottom_navigation_bar.dart';

class ProfileScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
      print('Çıkış başarılı');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Çıkış işlemi sırasında hata: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Profil Ekranı'),
      body: CustomBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150',
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Elif Yıldız',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Yaş:22',
                          style: TextStyle(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Meslek: öğrenci',
                          style: TextStyle(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Konum: Muğla',
                          style: TextStyle(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Cinsiyet:Kadın',
                          style: TextStyle(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 2, 2, 2)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'kullanici@example.com',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WishesScreen()),
                              );
                            },
                            child: Text('İsteklerim'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Kütüphanem ekranına yönlendirme
                            },
                            child: Text('Kütüphanem'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Geçmiş Takaslarım ekranına yönlendirme
                            },
                            child: Text('Geçmiş Takaslarım'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _signOut(context),
                            icon: Icon(Icons.logout),
                            label: Text('Çıkış Yap'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: GradientBottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ExchangeScreen(exchangeBooks: []), // Boş liste örneği
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MessageToPersonScreen()),
              );
              break;
            case 4:
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Harita'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: 'Takaslarım'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mesajlar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
