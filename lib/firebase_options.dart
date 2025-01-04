import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAQJ1heIkwpyHQzrpPhuKfKs9YeaRCFwQA',
    appId: '1:806131222747:web:d4288c6ecccacc0f53e4fe',
    messagingSenderId: '806131222747',
    projectId: 'swapshelf-bdbf6',
    authDomain: 'swapshelf-bdbf6.firebaseapp.com',
    storageBucket: 'swapshelf-bdbf6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZqVw-Lqi2ZmgeOwbfaolMciWD4sHEfgM',
    appId: '1:806131222747:android:d5938cfc6ba2d84553e4fe',
    messagingSenderId: '806131222747',
    projectId: 'swapshelf-bdbf6',
    storageBucket: 'swapshelf-bdbf6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyByuCD5rFPfl6tthJVQLNGMYTOIFZ_Eamk',
    appId: '1:806131222747:ios:b2fb096daf6bfc7b53e4fe',
    messagingSenderId: '806131222747',
    projectId: 'swapshelf-bdbf6',
    storageBucket: 'swapshelf-bdbf6.firebasestorage.app',
    iosBundleId: 'com.example.swapshelfproje',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyByuCD5rFPfl6tthJVQLNGMYTOIFZ_Eamk',
    appId: '1:806131222747:ios:b2fb096daf6bfc7b53e4fe',
    messagingSenderId: '806131222747',
    projectId: 'swapshelf-bdbf6',
    storageBucket: 'swapshelf-bdbf6.firebasestorage.app',
    iosBundleId: 'com.example.swapshelfproje',
  );
}
