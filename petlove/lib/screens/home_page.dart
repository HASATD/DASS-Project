import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:petlove/res/custom_colors.dart';
import 'package:petlove/utils/authentication.dart';
import 'package:petlove/widgets/google_sign_in_button.dart';
import 'package:petlove/screens/account_page.dart';
import 'package:petlove/mainkk.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User _user;

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 4, 50, 88),
        leading: Container(
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
        ), //Container
        title: Text('Welcome to petcare app'),
        centerTitle: true,
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
                  color: Color.fromARGB(255, 209, 179, 72),
                  fontSize: 26,
                ),
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: null,
        color: Color.fromARGB(255, 4, 50, 88),
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Request for help',
                icon: const Icon(Icons.add),
                alignment: Alignment.center,
                //padding: ,
                iconSize: 35,
                onPressed: () {
                  if (_user != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => AnimalDetails(
                          user: _user,
                        ),
                      ),
                    );
                  }
                },
              ),
              // if (centerLocations.contains(fabLocation)) const Spacer(),
              IconButton(
                tooltip: 'Account',
                icon: const Icon(Icons.manage_accounts_rounded),
                alignment: Alignment.center,
                iconSize: 35,
                onPressed: () {
                  if (_user != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => AccountPage(
                          user: _user,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
