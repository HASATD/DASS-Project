class NGOModel {
  String? uid;
  String? email;
  String? Organization;
  String? phoneNumber;
  int? verified;

  NGOModel(
      {this.uid,
      this.email,
      this.Organization,
      this.phoneNumber,
      this.verified});

  // fetch data from server
  factory NGOModel.fromMap(map) {
    return NGOModel(
      uid: map['uid'],
      email: map['email'],
      Organization: map['Organization'],
      phoneNumber: map['phoneNumber'],
      verified: map['verified'],
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
    };
  }
}
