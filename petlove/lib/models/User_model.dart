import 'dart:io';

class UserModel {
  String? uid;
  String? email;
  String? displayName;
  // String? phoneNumber;
  String? ngo_uid;
  String? photoURL;

  UserModel({
    this.uid,
    this.email,
    this.displayName,
    // this.phoneNumber,
    this.ngo_uid,
    this.photoURL,
  });

  // fetch data from server
  factory UserModel.fromMap(map) {
    return UserModel(
        uid: map['uid'],
        email: map['email'],
        displayName: map['displayName'],
        // phoneNumber: map['phoneNumber'],
        ngo_uid: map['ngo_uid'],
        photoURL: map['photoURL']);
  }

  // Sending data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      // 'phoneNumber': phoneNumber,
      'ngo_uid': ngo_uid,
      'photoURL': photoURL,
    };
  }
}
