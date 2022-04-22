import 'package:flutter/material.dart';
import 'package:petlove/models/NGO_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petlove/models/User_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NGOteam extends StatefulWidget {
  const NGOteam({Key? key, required NGOModel NGO})
      : _NGO = NGO,
        super(key: key);

  final NGOModel _NGO;
  @override
  State<NGOteam> createState() => _NGOteamState();
}

class _NGOteamState extends State<NGOteam> {
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
  final CollectionReference _userReference =
      FirebaseFirestore.instance.collection('users');

  late final Stream<QuerySnapshot> _userstream = _userReference.snapshots();

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
          'Team',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _userstream,
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
                  .where((element) => element['ngo_uid'] == _NGO.uid)
                  .map((DocumentSnapshot document) {
                Map<String, dynamic>? data =
                    document.data()! as Map<String, dynamic>?;

                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Memberprofile(
                                  document: data,
                                )),
                      );
                    }, // Image tapped
                    child: Card(
                      color: Colors.white70,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                data!['photoURL'],
                              ),
                            ),
                            title: Text(
                              data['displayName'],
                              style: TextStyle(
                                color: Color.fromARGB(255, 4, 50, 88),
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Memberprofile(
                                              document: data,
                                            )),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              const SizedBox(width: 16),
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
}

class Memberprofile extends StatelessWidget {
  const Memberprofile({required Map<String, dynamic>? document, Key? key})
      : data = document,
        super(key: key);

  final Map<String, dynamic>? data;

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
                'Member',
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
                          if (data!['photoURL'] != null) ...{
                            CircleAvatar(
                              backgroundColor: Colors.white70,
                              minRadius: 60.0,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: CachedNetworkImageProvider(
                                    data!['photoURL'] as String),
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
                          data!['displayName'] as String,
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
                          data!['email'] as String,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ],
            )));
  }
}
