import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:petlove/models/User_model.dart';
import 'package:petlove/res/custom_colors.dart';
import 'package:petlove/utils/authentication.dart';
import 'package:petlove/widgets/google_sign_in_button.dart';
import 'package:petlove/screens/account_page.dart';
import 'package:petlove/mainkk.dart';
import 'package:flutter/material.dart';
import 'package:petlove/screens/account_page.dart';
import 'package:petlove/mainkk.dart';
import 'package:petlove/screens/register_NGO.dart';
import 'package:petlove/screens/join_NGO.dart';
import 'package:petlove/screens/ngo_request_display.dart';
import 'package:petlove/screens/help_request_display_user.dart';
import 'package:petlove/screens/update_user_profile.dart';
import 'package:petlove/screens/helper_dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserModel _user;

  @override
  void initState() {
    _user = widget._user;

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
          /**leading: Container(
          color: Color.fromARGB(255, 57, 152, 216),
          padding: EdgeInsets.all(3),
          /** PetCare Logo **/
            child: Flexible(
            flex: 1,
            child: Image.asset(
              'assets/petcare_image.PNG',
              height: 50,
            ),
          ),
        ),**/ //Container
          title: const Text('Home'),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            // height: 50,
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 4, 50, 88),
              ),
              child: Text('Menu',
                  style: TextStyle(fontSize: 25, color: Colors.white)),
            ),

            ListTile(
              leading: Icon(Icons.change_circle_outlined),
              title: Text("Switch Account", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NGOregistration(
                            uid: _user.uid,
                          )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_task_outlined),
              title: Text("Join NGO", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NGOsDisplay(
                        user: _user,
                      ),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.request_quote),
              title: Text("Help Requests", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HelpRequestDisplayUser(
                            user: _user,
                          )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.update),
              title: Text("Update Profile", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => updateProfile(
                            user: _user,
                          )),
                );
              },
            ),
            (_user.ngo_uid != null)
                ? ListTile(
                    leading: Icon(Icons.request_quote),
                    title: Text("Requests Assigned",
                        style: TextStyle(fontSize: 18)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HelperAssignedRequests(
                                  user: _user,
                                )),
                      );
                    },
                  )
                : Container(),
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
                  'Hi ' + _user.displayName! + '!',
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyCustomForm(
                        user: _user,
                      )),
            );
          },
          tooltip: 'Request',
          child: const Icon(Icons.add),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                user: _user,
                              )),
                    );
                  },
                ),
                if (centerLocations.contains(fabLocation)) const Spacer(),
                IconButton(
                  tooltip: 'Profile',
                  icon: const Icon(Icons.account_circle, size: 35),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountPage(
                                user: _user,
                              )),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
