import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreManager {
  FirebaseFirestore _firestore;
  final String userId;
  final FirebaseApp firebaseApp;

  FirestoreManager([this.userId, this.firebaseApp]) {
    _firestore = FirebaseFirestore.instance;
  }

  static Future<FirestoreManager> from([String userId]) async {
    final firebaseApp = await Firebase.initializeApp();
    // await Firebase.initializeApp(
    //     name: 'SecondaryApp',
    //     options: const FirebaseOptions(
    //         appId: 'my_appId',
    //         apiKey: 'my_apiKey',
    //         messagingSenderId: 'my_messagingSenderId',
    //         projectId: 'my_projectId'));
    return FirestoreManager(userId, firebaseApp);
  }

  Stream<DocumentSnapshot> get onNotification {
    return _firestore.collection('users').doc(userId).snapshots();
  }
}
