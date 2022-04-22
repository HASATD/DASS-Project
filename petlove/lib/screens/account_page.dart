import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:petlove/models/NGO_model.dart';
import 'package:petlove/models/User_model.dart';
import 'package:petlove/res/custom_colors.dart';
import 'package:petlove/screens/home_page.dart';
import 'package:petlove/utils/authentication.dart';
import 'package:petlove/widgets/button_widget.dart';
import 'package:petlove/widgets/google_sign_in_button.dart';
import 'package:petlove/screens/sign_in_screen.dart';
import 'package:petlove/models/User_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late UserModel _user;
  bool _isSigningOut = false;

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 210, 210),
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
          'User Account',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
                    _user.photoURL != null
                        ? CircleAvatar(
                            backgroundColor: Colors.white70,
                            minRadius: 60.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: CachedNetworkImageProvider(
                                  _user.photoURL as String),
                              radius: 50,
                            ),
                          )
                        : CircleAvatar(
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
                            ),
                          ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          // Row(
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
                    _user.displayName!,
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
                    '${_user.email!}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                _isSigningOut
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 4, 50, 88),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            _isSigningOut = true;
                          });
                          await Authentication.signOut(context: context);
                          setState(() {
                            _isSigningOut = false;
                          });
                          Navigator.of(context)
                              .pushReplacement(_routeToSignInScreen());
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    ); // Scaffold
  } // build
} // end class

class NGOAccountPage extends StatefulWidget {
  const NGOAccountPage({Key? key, required NGOModel NGO})
      : _NGO = NGO,
        super(key: key);

  final NGOModel _NGO;

  @override
  _NGOAccountPageState createState() => _NGOAccountPageState();
}

class _NGOAccountPageState extends State<NGOAccountPage> {
  late NGOModel _NGO;
  bool _isSigningOut = false;

  @override
  void initState() {
    _NGO = widget._NGO;

    super.initState();
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 210, 210),
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
                Navigator.of(context).pop();
              },
            ),
          ),
        ), //Container,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 50, 88),
        title: Text(
          'Account',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
                    if (_NGO.dpURL != null) ...{
                      CircleAvatar(
                        backgroundColor: Colors.white70,
                        minRadius: 60.0,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              CachedNetworkImageProvider(_NGO.dpURL as String),
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
                              Icons.group,
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
                    _NGO.Organization!,
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
                    '${_NGO.email!}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    ); // Scaffold
  } // build
} // end class
