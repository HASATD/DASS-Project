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

class UserHelpRequests extends StatefulWidget {
  const UserHelpRequests(
      {Key? key, required UserModel user, required bool isCompleted})
      : _user = user,
        _isCompleted = isCompleted,
        super(key: key);

  final UserModel _user;
  final bool _isCompleted;

  @override
  State<UserHelpRequests> createState() => _UserHelpRequestsState();
}

class _UserHelpRequestsState extends State<UserHelpRequests> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference _requestReference =
      FirebaseFirestore.instance.collection('Request');

  late final Stream<QuerySnapshot> _requestStream = _requestReference
      .where('UserID', isEqualTo: widget._user.uid)
      .where('IsCompleted', isEqualTo: widget._isCompleted)
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RequestDetail(
                                  document: data,
                                )),
                      );
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

class HelpRequestDisplayUser extends StatefulWidget {
  const HelpRequestDisplayUser({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;

  @override
  State<HelpRequestDisplayUser> createState() => _HelpRequestDisplayUserState();
}

class _HelpRequestDisplayUserState extends State<HelpRequestDisplayUser> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var _requestReference = FirebaseFirestore.instance
      .collection('Request')
      .where('Animal', isEqualTo: 'new');

  void UpdateFields() async {
    var querySnapshots = await _requestReference.get();
    for (var doc in querySnapshots.docs) {
      await doc.reference.update({
        'HelperUID': null,
      });

      String id = doc.id;

      await FirebaseFirestore.instance
          .runTransaction((Transaction myTransaction) async {
        await myTransaction.delete(doc.reference);
      });
    }
  }

  @override
  void initState() {
    //UpdateFields();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "OPEN",
                ),
                Tab(
                  text: "ASSIGNED TO HELPER",
                ),
              ],
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // passing this to our root
                Navigator.of(context).pop();
              },
            ), //Container,
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 4, 50, 88),
            title: Text(
              'Current Requests',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: TabBarView(
            children: [
              UserHelpRequests(user: widget._user, isCompleted: false),
              UserHelpRequests(user: widget._user, isCompleted: true),
            ],
          ),
        ),
      ),
    );
  }
}

class RequestDetail extends StatelessWidget {
  const RequestDetail({required Map<String, dynamic>? document, Key? key})
      : data = document,
        super(key: key);

  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // passing this to our root
                  Navigator.of(context).pop();
                },
              ),
              //Container,
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 4, 50, 88),
              title: Text(
                'Current Requests',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: Color.fromARGB(255, 255, 255, 255),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        height: 400,
                        width: double.infinity,
                        // child: Image.network(
                        //   data!['ImageURL'],
                        //   fit: BoxFit.contain,
                        // ),
                        child: CachedNetworkImage(
                          imageUrl: data!['ImageURL'],
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        'Animal : ' + data!['Animal'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Description : ' + data!['Description'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      (data!['HelperUID'] == null)
                          ? Container()
                          : MaterialButton(
                              color: Color.fromARGB(255, 4, 50, 88),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HelperView(
                                          helperUID: data!['HelperUID'])),
                                );
                              },
                              child: Text(
                                'View Helper',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ))));
  }
}

class RequestDetailWithoutHelper extends StatelessWidget {
  const RequestDetailWithoutHelper(
      {required Map<String, dynamic>? document, Key? key})
      : data = document,
        super(key: key);

  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // passing this to our root
                  Navigator.of(context).pop();
                },
              ), //Container,
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 4, 50, 88),
              title: Text(
                'Current Requests',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: Color.fromARGB(255, 255, 255, 255),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        height: 400,
                        width: double.infinity,
                        // child: Image.network(
                        //   data!['ImageURL'],
                        //   fit: BoxFit.contain,
                        // ),
                        child: CachedNetworkImage(
                          imageUrl: data!['ImageURL'],
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        'Animal : ' + data!['Animal'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Description : ' + data!['Description'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ))));
  }
}

class RequestInfo extends StatefulWidget {
  const RequestInfo({Map<String, dynamic>? document, Key? key})
      : data = document,
        super(key: key);

  final Map<String, dynamic>? data;

  @override
  State<RequestInfo> createState() => _RequestInfoState();
}

class _RequestInfoState extends State<RequestInfo> {
  late Map<String, dynamic>? data;

  @override
  void initState() {
    data = widget.data;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              leading: Container(
                color: Color.fromARGB(255, 4, 50, 88),
                padding: EdgeInsets.all(3),
                child: Flexible(
                  flex: 1,
                  child: IconButton(
                    tooltip: 'Go back',
                    icon: const Icon(Icons.arrow_back),
                    alignment: Alignment.center,
                    iconSize: 20,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ), //Container,
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 4, 50, 88),
              title: Text(
                'Current Requests',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Center(
              child: Container(
                child: Column(children: <Widget>[
                  Text('Animal : ' + data!['Animal']),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Description : ' + data!['Description']),
                  SizedBox(
                    height: 10,
                  ),
                ]),
              ),
            )));
  }
}

class HelperView extends StatefulWidget {
  const HelperView({Key? key, required String helperUID})
      : _helperUID = helperUID,
        super(key: key);

  final String _helperUID;
  @override
  State<HelperView> createState() => _HelperViewState();
}

class _HelperViewState extends State<HelperView> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference _usersReference =
      FirebaseFirestore.instance.collection('users');

  late final Stream<QuerySnapshot> _helperReferenceStream =
      _usersReference.where('uid', isEqualTo: widget._helperUID).snapshots();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _helperReferenceStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.hasData) {
            Map<String, dynamic> data =
                snapshot.data!.docs[0].data()! as Map<String, dynamic>;

            return Memberprofile(document: data);
          } else {
            return const Text('Loading...');
          }
        });
  }
}
