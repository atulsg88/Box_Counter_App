// Firebase configuration from Factory_Box_Tracker project
// Project: box-detection-75f81
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyB42eMqL3O7IFLZWydBmX-RA78o0y3IBpw',
    appId: '1:316007235728:web:a20b1081aff646977a9815',
    messagingSenderId: '316007235728',
    projectId: 'box-detection-75f81',
    authDomain: 'box-detection-75f81.firebaseapp.com',
    storageBucket: 'box-detection-75f81.firebasestorage.app',
    measurementId: 'G-8FYGS2Z2XD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB42eMqL3O7IFLZWydBmX-RA78o0y3IBpw',
    appId: '1:316007235728:android:a20b1081aff646977a9815',
    messagingSenderId: '316007235728',
    projectId: 'box-detection-75f81',
    storageBucket: 'box-detection-75f81.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB42eMqL3O7IFLZWydBmX-RA78o0y3IBpw',
    appId: '1:316007235728:ios:a20b1081aff646977a9815',
    messagingSenderId: '316007235728',
    projectId: 'box-detection-75f81',
    storageBucket: 'box-detection-75f81.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB42eMqL3O7IFLZWydBmX-RA78o0y3IBpw',
    appId: '1:316007235728:ios:a20b1081aff646977a9815',
    messagingSenderId: '316007235728',
    projectId: 'box-detection-75f81',
    storageBucket: 'box-detection-75f81.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB42eMqL3O7IFLZWydBmX-RA78o0y3IBpw',
    appId: '1:316007235728:web:a20b1081aff646977a9815',
    messagingSenderId: '316007235728',
    projectId: 'box-detection-75f81',
    authDomain: 'box-detection-75f81.firebaseapp.com',
    storageBucket: 'box-detection-75f81.firebasestorage.app',
    measurementId: 'G-8FYGS2Z2XD',
  );
}
