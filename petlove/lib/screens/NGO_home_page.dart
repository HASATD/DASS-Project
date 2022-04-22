import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:petlove/res/custom_colors.dart';
import 'package:petlove/utils/authentication.dart';
import 'package:petlove/widgets/google_sign_in_button.dart';
import 'package:petlove/screens/account_page.dart';
import 'package:petlove/mainkk.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:petlove/screens/account_page.dart';
import 'package:petlove/mainkk.dart';
import 'package:petlove/screens/register_NGO.dart';
import 'package:petlove/screens/join_NGO.dart';
import 'package:petlove/screens/ngo_request_display.dart';
import 'package:petlove/models/NGO_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petlove/screens/pending_applications.dart';
import 'package:petlove/models/User_model.dart';
import 'package:petlove/screens/home_page.dart';

class NGOHomePage extends StatefulWidget {
  const NGOHomePage({Key? key, required String? uid})
      : _uid = uid,
        super(key: key);

  final String? _uid;

  @override
  _NGOHomePageState createState() => _NGOHomePageState();
}

class _NGOHomePageState extends State<NGOHomePage> {
  late String? _uid;

  @override
  void initState() {
    _uid = widget._uid;

    super.initState();
  }

  FloatingActionButtonLocation fabLocation =
      FloatingActionButtonLocation.centerDocked;
  static final List<FloatingActionButtonLocation> centerLocations =
      <FloatingActionButtonLocation>[
    FloatingActionButtonLocation.centerDocked,
    FloatingActionButtonLocation.centerFloat,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 4, 50, 88),
        //   leading: Container(
        //   color: Color.fromARGB(255, 57, 152, 216),
        //   padding: EdgeInsets.all(3),
        //   /** PetCare Logo **/
        //     child: Flexible(
        //     flex: 1,
        //     child: Image.asset(
        //       'assets/petcare_image.PNG',
        //       height: 50,
        //     ),
        //   ),
        // ), //Container
          title: Text('Welcome to petcare app'),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 4, 50, 88),
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              leading: Icon(Icons.change_circle_outlined),
              title: Text("Switch Account", style: TextStyle(fontSize: 18)),
              onTap: () async {
                UserModel fireuser = UserModel();
                DocumentSnapshot variable = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_uid)
                    .get();
                Map<String, dynamic> data =
                    variable.data()! as Map<String, dynamic>;
                fireuser.displayName = data['displayName'];
                fireuser.uid = data['uid'];
                fireuser.email = data['email'];
                fireuser.photoURL = data['photoURL'];
                fireuser.ngo_uid = data['ngo_uid'];
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              user: fireuser,
                            )));
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text("Team Members", style: TextStyle(fontSize: 18)),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => AccountPage(
                //             user: _user,
                //           )),
                // );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_task_outlined),
              title: Text("Join Requests", style: TextStyle(fontSize: 18)),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => AccountPage(
                //             user: _user,
                //           )),
                // );
              },
            ),
            ListTile(
              leading: Icon(Icons.request_quote),
              title: Text("Help Requests", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NGORequestsDisplay(
                            uid: _uid,)
                  )
                );
              }
            ),
            ListTile(
              leading: Icon(Icons.pending_outlined),
              title: Text("Applications", style: TextStyle(fontSize: 18)),
              onTap: () async {
                DocumentSnapshot variable = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_uid)
                    .get();
                print(_uid);
                Map<String, dynamic> NGOdata =
                    variable.data()! as Map<String, dynamic>;

                NGOModel NGO = NGOModel();
                NGO.uid = _uid;
                NGO.Organization = NGOdata['Organization'];
                NGO.certificate = NGOdata['certificate'];
                NGO.dpURL = NGOdata['dpURL'];
                NGO.email = NGOdata['email'];
                NGO.phoneNumber = NGOdata['phoneNumber'];
                NGO.verified = NGOdata['verified'];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => pendingappls(
                            NGO: NGO,
                          )),
                );
              },
            ),
          ]),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(),
                SizedBox(height: 16.0),
                Text(
                  'Hi!',
                  style: TextStyle(
                    color: Color.fromARGB(255, 4, 50, 88),
                    fontSize: 26,
                  ),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          // should display available requests within 30kms radius
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => MyCustomForm(
            //             user: _user,
            //           )),
            // );
          },
          tooltip: 'Accept',
          child: const Icon(Icons.assignment_turned_in_outlined),
        ),
        floatingActionButtonLocation: fabLocation,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.blue,
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: 'Home',
                  icon: const Icon(Icons.home, size: 35),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => NGOHomePage(
                    //             user: _user,
                    //           )),
                    // );
                  },
                ),
                if (centerLocations.contains(fabLocation)) const Spacer(),
                IconButton(
                  tooltip: 'Profile',
                  icon: const Icon(Icons.account_circle, size: 35),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => AccountPage(
                    //             user: _user,
                    //           )),
                    // );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
