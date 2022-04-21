import 'dart:io';

class JoinModel {
  String? uid;
  String? ngo_uid;
  String? contact;
  String? description;
  String? status;

  JoinModel(
      {this.uid, this.ngo_uid, this.contact, this.description, this.status});

  // fetch data from server
  factory JoinModel.fromMap(map) {
    return JoinModel(
        uid: map['uid'],
        ngo_uid: map['ngo_uid'],
        contact: map['contact'],
        description: map['description'],
        status: map['status']);
  }

  // Sending data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'ngo_uid': ngo_uid,
      'contact': contact,
      'description': description,
      'status': status,
    };
  }
}
