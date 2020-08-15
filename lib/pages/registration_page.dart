import 'package:flutter/material.dart';
import 'package:flutter_flash_chat/components/rounded_button.dart';
import 'package:flutter_flash_chat/pages/chat_page.dart';
import 'package:flutter_flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

final databaseReference = Firestore.instance;

class RegistrationPage extends StatefulWidget {
  static const String id = 'registration_page';
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  bool showSpinner = false;
  String email;
  String password;
  bool _isLoggedIn = false;

  _googleLogin() async {
    try {
      //await _googleSignIn.signIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;

      createRecord(user.email);

      setState(() {
        _isLoggedIn = true;
        Navigator.pushNamed(context, ChatPage.id);
      });
    } catch (err) {
      print(err);
    }
  }

  void createRecord(String email) async {
    final snapShot =
        await Firestore.instance.collection('users').document(email).get();

    if (snapShot == null || !snapShot.exists) {
      await databaseReference
          .collection("users")
          .document(email)
          .setData({'email': email});
    } else {
      print("user exists!");
    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error !"),
          content: new Text("El email ingresado ya existe."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Register',
                color: Colors.blueAccent,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final snapShot = await Firestore.instance
                        .collection('users')
                        .document(email)
                        .get();

                    if (snapShot == null || !snapShot.exists) {
                      await databaseReference
                          .collection("users")
                          .document(email)
                          .setData({'email': email});

                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                      if (newUser != null) {
                        print("user " + newUser.user.toString());

                        createRecord(newUser.user.email);
                        Navigator.pushNamed(context, ChatPage.id);
                      }
                      setState(() {
                        showSpinner = false;
                      });
                    } else {
                      print("user exists!");
                      _showDialog();
                      setState(() {
                        showSpinner = false;
                      });
                    }
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              Row(children: <Widget>[
                Expanded(
                  child: new Container(
                      margin: const EdgeInsets.only(left: 10.0, right: 15.0),
                      child: Divider(
                        color: Colors.black,
                        height: 50,
                      )),
                ),
                Text("OR"),
                Expanded(
                  child: new Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 10.0),
                      child: Divider(
                        color: Colors.black,
                        height: 50,
                      )),
                ),
              ]),
              GoogleSignInButton(
                onPressed: () {
                  _googleLogin();
                },
                darkMode: true, // default: false
              )
            ],
          ),
        ),
      ),
    );
  }
}
