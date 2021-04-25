import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String dropdownValue = 'Designer';
final username = FirebaseFirestore.instance.collection('Usernames');

class PasswordResetPage extends StatefulWidget {
  PasswordResetPageStae createState() => PasswordResetPageStae();
}

class PasswordResetPageStae extends State<PasswordResetPage> {
  //Init Text Field Controllers
  final TextEditingController emailController = TextEditingController();

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
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
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
              ],
            )));
  }
}