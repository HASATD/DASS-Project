import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class NGOModel {
  String? uid;
  String? email;
  String? Organization;
  String? phoneNumber;
  int? verified;
  String? certificate;
  String? dpURL;
  GeoPoint? location;

  NGOModel({
    this.uid,
    this.email,
    this.Organization,
    this.phoneNumber,
    this.verified,
    this.certificate,
    this.dpURL,
    this.location,
  });

  // fetch data from server
  factory NGOModel.fromMap(map) {
    return NGOModel(
      uid: map['uid'],
      email: map['email'],
      Organization: map['Organization'],
      phoneNumber: map['phoneNumber'],
      verified: map['verified'],
      certificate: map['certificate'],
      dpURL: map['dpURL'],
      location: map['location'],
    );
  }

  // Sending data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'Organization': Organization,
      'phoneNumber': phoneNumber,
      'verified': verified,
      'certificate': certificate,
      'dpURL': dpURL,
      'location': location,
    };
  }
}
