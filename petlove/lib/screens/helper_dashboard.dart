import 'dart:ffi';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petlove/models/User_model.dart';
import 'package:petlove/utils/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:petlove/screens/NGO_team.dart';

class HelperAssignedRequests extends StatefulWidget {
  const HelperAssignedRequests({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;

  @override
  State<HelperAssignedRequests> createState() => _HelperAssignedRequestsState();
}

class _HelperAssignedRequestsState extends State<HelperAssignedRequests> {
  final CollectionReference _requestReference =
      FirebaseFirestore.instance.collection('Request');

  late final Stream<QuerySnapshot> _requestStream = _requestReference
      .where('HelperUID', isEqualTo: widget._user.uid)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _requestStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => RequestDetail(
                      //             document: data,
                      //           )),
                      // );
                    }, // Image tapped
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: CircleAvatar(
                              radius: 75,
                              backgroundImage: CachedNetworkImageProvider(
                                data['ImageURL'],
                              ),
                            ),
                            title: Text(
                              data['Animal'],
                              style: TextStyle(
                                color: Color.fromARGB(255, 4, 50, 88),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          } else {
            return const Center(
              child: Text("No Requests to display"),
            );
          }
        });
  }
}
