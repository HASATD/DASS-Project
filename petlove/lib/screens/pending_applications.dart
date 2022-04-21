import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:petlove/models/NGO_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:petlove/models/User_model.dart';

class pendingappls extends StatefulWidget {
  const pendingappls({Key? key, required NGOModel NGO})
      : _NGO = NGO,
        super(key: key);

  final NGOModel _NGO;
  @override
  State<pendingappls> createState() => _pendingapplsState();
}

class _pendingapplsState extends State<pendingappls> {
  @override
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var joinstat = 0;
  late NGOModel _NGO;
  late UserModel user;

  @override
  void initState() {
    _NGO = widget._NGO;

    super.initState();
  }

  @override
  final CollectionReference _joinngoReference =
      FirebaseFirestore.instance.collection('JoinRequests');

  late final Stream<QuerySnapshot> _joinngostream =
      _joinngoReference.snapshots();

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
              icon: const Icon(Icons.arrow_back_ios),
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
          'pending applications',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _joinngostream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return ListView(
              children: snapshot.data!.docs
                  .where((element) =>
                      element['ngo_uid'] == _NGO.uid &&
                      element['status'] == "ongoing")
                  .map((DocumentSnapshot document) {
                Map<String, dynamic>? data =
                    document.data()! as Map<String, dynamic>?;

                var id = document.id;
                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: GestureDetector(
                    onTap: () async {
                      user = await Applicantdetails(data!['uid'], data);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ApplicationDetail(
                                    document: data,
                                    user: user,
                                  )),
                          (route) => false);
                    }, // Image tapped
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            // leading: CircleAvatar(
                            //   backgroundImage: CachedNetworkImageProvider(
                            //     data!['dpURL'],
                            //   ),
                            // ),
                            title: Text(
                              data!['contact'],
                              style: TextStyle(
                                color: Color.fromARGB(255, 4, 50, 88),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                child: const Text(
                                  'View',
                                  style: TextStyle(fontSize: 15),
                                ),
                                onPressed: () async {
                                  user = await Applicantdetails(
                                      data!['uid'], data);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ApplicationDetail(
                                              document: data,
                                              user: user,
                                            )),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: ElevatedButton(
                                  child: const Text(
                                    'Accept',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  onPressed: () async {
                                    DocumentSnapshot variable =
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(data!['uid'])
                                            .get();
                                    Map<String, dynamic> userdata = variable
                                        .data()! as Map<String, dynamic>;

                                    if (userdata['ngo_uid'] == null) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(data!['uid'])
                                          .update({'ngo_uid': _NGO.uid});
                                      await FirebaseFirestore.instance
                                          .collection('JoinRequests')
                                          .doc(id)
                                          .update({'status': 'accepted'});
                                      Fluttertoast.showToast(
                                          msg:
                                              "Congrats! New volunteer added...");
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              "User is already registered in an NGO :(");
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: ElevatedButton(
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('JoinRequests')
                                        .doc(id)
                                        .update({'status': 'rejected'});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
    ));
  }

  Applicantdetails(String? uid, Map<String, dynamic>? document) async {
    // calling our firestore
    // calling our user model
    // sedning these values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    UserModel dataUser = UserModel();

    // writing all the values

    DocumentSnapshot variable =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    Map<String, dynamic> data = variable.data()! as Map<String, dynamic>;

    dataUser.displayName = data['displayName'];
    dataUser.uid = data['uid'];
    dataUser.email = data['email'];
    dataUser.photoURL = data['photoURL'];
    dataUser.ngo_uid = data['ngo_uid'];

    return dataUser;
  }
}

class ApplicationDetail extends StatelessWidget {
  const ApplicationDetail(
      {required Map<String, dynamic>? document,
      required UserModel user,
      Key? key})
      : data = document,
        user = user,
        super(key: key);

  final Map<String, dynamic>? data;
  final UserModel user;

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
                    icon: const Icon(Icons.arrow_back_ios),
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
                'Application',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: ListView(
              children: <Widget>[
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 4, 50, 88),
                        Color.fromARGB(255, 66, 152, 173)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.5, 0.9],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          if (user.photoURL != null) ...{
                            CircleAvatar(
                              backgroundColor: Colors.white70,
                              minRadius: 60.0,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: CachedNetworkImageProvider(
                                    user.photoURL as String),
                                radius: 50,
                              ),
                            ),
                          } else ...{
                            CircleAvatar(
                                backgroundColor: Colors.white70,
                                minRadius: 60.0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.blueGrey,
                                  ),
                                  radius: 50,
                                ))
                          }
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Name',
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 50, 88),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          user.displayName as String,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          'Email',
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 50, 88),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          user.email as String,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          'Contact',
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 50, 88),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          data!['contact'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          'Description',
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 50, 88),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          data!['description'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
}
