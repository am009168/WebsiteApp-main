import 'package:flutter_app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/verify.dart';

String dropdownValue = 'Designer';
final username = FirebaseFirestore.instance.collection('Usernames');

class SignUp extends StatefulWidget {
  SignUpPage createState() => SignUpPage();
}

class SignUpPage extends State<SignUp> {
  //Init Text Field Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
  TextEditingController();
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign Up Screen'),
          backgroundColor: Colors.black,
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: fNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name',
                    ),
                  ),
                ),

                //Create Controller Fields
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: lNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name',
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    obscureText: true,
                    controller: passwordConfirmController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password',
                    ),
                  ),
                ),
                Text(""),

                //Format and create a Drop Down Button to designate user types
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.black,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items: <String>['Designer', 'Learner']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Text(""),

                //Sign Up Button
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.black,
                      child: Text('Sign Up'),
                      onPressed: () async {
                        //Check if desired password is correct
                        if (passwordConfirmController.text.trim() ==
                            passwordController.text.trim()) {
                          await context.read<Authentication>().signUp(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          //Wait for Data to be pushed to database
                          // while (FirebaseAuth.instance.currentUser == null)
                          //   return const Text('Creating Account...');
                          //Push other fields
                          print(FirebaseAuth.instance.currentUser);
                          infoPush();
                        }

                        //If passwords differ alert the user
                        else {
                          showAlertDialog(context);
                        }
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VerifyScreen()));
                      },
                    )),
              ],
            )));
  }

  //Handles pushing the user data into the database
  void infoPush() {
    //init firebase instance
    var firebaseUser = FirebaseAuth.instance.currentUser;
    print("====>>>>>>${firebaseUser}");
    //Push to database with Designer designation
    if (dropdownValue == "Designer") {
      firestoreInstance
          .collection("Users")
          .doc('UserList')
          .collection('Designers')
          .doc(firebaseUser.uid)
          .set({
        "firstname": fNameController.text.trim(),
        "lastname": lNameController.text.trim(),
        "email": emailController.text.trim(),
        "uid": firebaseUser.uid,
        "designerids": <String>[]
      }).then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyScreen()),
        );
      });
    }

    //Push to database with Learner designation
    else if (dropdownValue == "Learner") {
      firestoreInstance
          .collection("Users")
          .doc('UserList')
          .collection('Learners')
          .doc(firebaseUser.uid)
          .set({
        "firstname": fNameController.text.trim(),
        "lastname": lNameController.text.trim(),
        "email": emailController.text.trim(),
        "uid": firebaseUser.uid,
        "designerids": <String>[]
      }).then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyScreen()),
        );
      });
    }
  }

  //Handles and formats the alert box.
  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Passwords must match"),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}