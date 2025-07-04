// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
        return windows;
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
    apiKey: 'AIzaSyAtxafvkvi6GEiTzdMZqt8FbIS2SlF4H1c',
    appId: '1:827918365951:web:2e3874a4181a626de9c8ca',
    messagingSenderId: '827918365951',
    projectId: 'toplanti-56f58',
    authDomain: 'toplanti-56f58.firebaseapp.com',
    storageBucket: 'toplanti-56f58.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZC8p_QcLGP0_O7uUfjhokwdlRGPeIv7Q',
    appId: '1:827918365951:android:bc99b0496752e932e9c8ca',
    messagingSenderId: '827918365951',
    projectId: 'toplanti-56f58',
    storageBucket: 'toplanti-56f58.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBiImLnm4eZPrpKJQFT60rcQoVyHuoI7o',
    appId: '1:827918365951:ios:144d0b0df72db9a2e9c8ca',
    messagingSenderId: '827918365951',
    projectId: 'toplanti-56f58',
    storageBucket: 'toplanti-56f58.firebasestorage.app',
    iosBundleId: 'com.example.proje',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDBiImLnm4eZPrpKJQFT60rcQoVyHuoI7o',
    appId: '1:827918365951:ios:144d0b0df72db9a2e9c8ca',
    messagingSenderId: '827918365951',
    projectId: 'toplanti-56f58',
    storageBucket: 'toplanti-56f58.firebasestorage.app',
    iosBundleId: 'com.example.proje',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAtxafvkvi6GEiTzdMZqt8FbIS2SlF4H1c',
    appId: '1:827918365951:web:aff35b70e99866b2e9c8ca',
    messagingSenderId: '827918365951',
    projectId: 'toplanti-56f58',
    authDomain: 'toplanti-56f58.firebaseapp.com',
    storageBucket: 'toplanti-56f58.firebasestorage.app',
  );
}
