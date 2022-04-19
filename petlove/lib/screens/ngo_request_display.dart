import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petlove/utils/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NGORequestsDisplay extends StatefulWidget {
  const NGORequestsDisplay({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  State<NGORequestsDisplay> createState() => _NGORequestsDisplayState();
}

class _NGORequestsDisplayState extends State<NGORequestsDisplay> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference _requestReference =
      FirebaseFirestore.instance.collection('Request');
  late final Stream<QuerySnapshot> _requestStream =
      _requestReference.snapshots();

  @override
  void initState() {
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
          'Current Requests',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _requestStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                // return Card(
                //     color: Color.fromARGB(255, 4, 50, 88),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10.0),
                //     ),
                //     child: Container(
                //       padding: EdgeInsets.all(10),
                //       height: 300,
                //       width: double.infinity,
                //       decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(15.0),
                //           image: DecorationImage(
                //               fit: BoxFit.cover,
                //               image: NetworkImage(
                //                 data['ImageURL'],
                //               ))),
                //       child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: <Widget>[
                //             Text(
                //               'Animal : ' + data['Animal'],
                //               style: TextStyle(
                //                   fontSize: 15, fontWeight: FontWeight.bold),
                //             ),
                //             SizedBox(
                //               height: 10,
                //             ),
                //             Text(
                //               'Description : ' + data['Description'],
                //               style: TextStyle(
                //                   fontSize: 15, fontWeight: FontWeight.bold),
                //             ),
                //           ]),
                //       margin:
                //           EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                //     ));

                // precacheImage(NetworkImage(data['ImageURL']), context);

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
                    child: Container(
                      height: 720,
                      width: double.infinity,
                      child: Image.network(
                        data['ImageURL'],
                        fit: BoxFit.contain,
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
                'Current Requests',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Center(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: Color.fromARGB(255, 255, 253, 208),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        height: 400,
                        width: double.infinity,
                        child: Image.network(
                          data!['ImageURL'],
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
