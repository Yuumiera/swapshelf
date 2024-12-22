import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class MockGoogleSignInAccount {
  final String email;

  MockGoogleSignInAccount({this.email = 'mockuser@example.com'});

  Future<MockGoogleSignInAuthentication> get authentication async {
    return MockGoogleSignInAuthentication();
  }
}

class MockGoogleSignInAuthentication {
  final String mockAccessToken;
  final String mockIdToken;

  MockGoogleSignInAuthentication({
    this.mockAccessToken = 'mock_access_token',
    this.mockIdToken = 'mock_id_token',
  });

  String get accessToken => mockAccessToken;

  String get idToken => mockIdToken;
}

class MockGoogleSignIn {
  bool shouldCancel = false;

  Future<MockGoogleSignInAccount?> signIn() async {
    if (shouldCancel) {
      return null; // Kullanıcı iptal etti
    }
    return MockGoogleSignInAccount();
  }
}

Future<User?> signInWithMockGoogle(
    MockFirebaseAuth mockAuth, MockGoogleSignIn mockGoogleSignIn) async {
  try {
    final MockGoogleSignInAccount? googleUser = await mockGoogleSignIn.signIn();
    if (googleUser == null) {
      print("User canceled Google Sign-In.");
      return null; // Kullanıcı giriş yapmadı
    }

    final MockGoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await mockAuth.signInWithCredential(credential);
    return userCredential.user;
  } catch (e) {
    print('Google Sign-In Error: $e');
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Test ortamını başlat

  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        isAnonymous: false,
        email: 'mockuser@example.com',
      ),
    );
    mockGoogleSignIn = MockGoogleSignIn();
  });

  group('Google Sign-In Tests', () {
    test('Successful Google Sign-In', () async {
      mockGoogleSignIn.shouldCancel = false; // Kullanıcı giriş yapacak

      final user = await signInWithMockGoogle(mockAuth, mockGoogleSignIn);

      expect(user, isNotNull);
      expect(user?.email, equals('mockuser@example.com'));
      print('Google Sign-In successful for user: ${user?.email}');
    });

    test('Google Sign-In Canceled by User', () async {
      mockGoogleSignIn.shouldCancel = true; // Kullanıcı iptal etti

      final user = await signInWithMockGoogle(mockAuth, mockGoogleSignIn);

      expect(user, isNull);
      print('Google Sign-In was canceled by the user.');
    });
  });
}
