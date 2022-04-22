import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:petlove/screens/home_page.dart';
import 'package:petlove/screens/user_info_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:petlove/models/User_model.dart';

class Authentication {
  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;
    UserModel? fireuser = UserModel();

    if (user != null) {
      DocumentSnapshot variable = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      Map<String, dynamic> data = variable.data()! as Map<String, dynamic>;
      fireuser.displayName = data['displayName'];
      fireuser.uid = data['uid'];
      fireuser.email = data['email'];
      fireuser.photoURL = data['photoURL'];
      fireuser.ngo_uid = data['ngo_uid'];

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(
            user: fireuser,
          ),
        ),
      );
    }

    return firebaseApp;
  }

  static Future<UserModel?> signInWithGoogle(
      {required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    UserModel fireuser = UserModel();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          final List<DocumentSnapshot> docs;
          QuerySnapshot result = await _firestore
              .collection('users')
              .where('uid', isEqualTo: userCredential.user!.uid)
              .get();
          docs = result.docs;
          DocumentSnapshot variable = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          if (docs.isEmpty) {
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'displayName': userCredential.user!.displayName,
              'uid': userCredential.user!.uid,
              'email': userCredential.user!.email,
              'photoURL': userCredential.user!.photoURL,
              'ngo_uid': null,
            });
            user = userCredential.user;
            fireuser.displayName = userCredential.user!.displayName;
            fireuser.uid = userCredential.user!.uid;
            fireuser.email = userCredential.user!.email;
            fireuser.photoURL = userCredential.user!.photoURL;
            fireuser.ngo_uid = null;
          } else {
            Map<String, dynamic> data =
                variable.data()! as Map<String, dynamic>;
            fireuser.displayName = data['displayName'];
            fireuser.uid = data['uid'];
            fireuser.email = data['email'];
            fireuser.photoURL = data['photoURL'];
            fireuser.ngo_uid = data['ngo_uid'];
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'The account already exists with a different credential.',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred using Google Sign-In. Try again.',
            ),
          );
        }
      }
    }

    return fireuser;
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }
}
