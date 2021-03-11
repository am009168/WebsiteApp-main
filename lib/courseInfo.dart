import 'package:flutter/material.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/taskCreater.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/Module.dart';
import 'package:flutter_app/providers/module_provider.dart';
import 'package:flutter_app/utils/session.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/Tasks.dart';
import 'package:flutter_app/screens/LessonPage.dart';
import 'dart:collection';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/taskCreater.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/responses.dart';
import 'package:flutter_app/models/Module.dart';
import 'package:flutter_app/providers/module_provider.dart';
import 'package:flutter_app/utils/session.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/Tasks.dart';
import 'package:flutter_app/screens/LessonPage.dart';
import 'dart:collection';
import 'dart:io' as io;
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

var infoGetter;
String stuff ;
class courseInfo extends StatefulWidget {
  courseInfo({Key key, this.courseName}) : super(key: key);
  // always marked "final".
  final String courseName;

  //final String courseId;

  @override
  _infoState createState() => _infoState();
}

class _infoState extends State<courseInfo> {
  TextEditingController nameEditingController = new TextEditingController();

  @override

  Widget build(BuildContext context) {
    infoGetter = coursePath.doc(widget.courseName);


    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.courseName + " Course",
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[

          ]),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Add new user to Course "),
            Container(
              child: TextField(
                keyboardType: TextInputType.text,
                maxLines: 1,
                autofocus: false,
                cursorColor: Colors.blue,
                controller: nameEditingController,
                decoration: InputDecoration(
                  labelText: "User Email",
                  prefixIcon: Icon(Icons.account_circle_sharp),
                  //Unfocus Text is grey
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  //Focued Text is blue
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),

            Container(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: RaisedButton(
                    child: Text("Add User"),
                    onPressed: () async{
                      stuff= await getIdByEmail(nameEditingController.text.trim());

                      if (getIdByEmail(nameEditingController.text.trim()) != null) {
                        infoGetter.updateData(
                            {'learnerids': FieldValue.arrayUnion([stuff])});
                      }
                      else {
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('User Not Found'),
                              content: Text('Please enter a new email'),
                            )
                        );
                      }
                      Navigator.pop(context, nameEditingController.text);
                    }),
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

Future<String> getIdByEmail(String email) async {
  final firestoreInstance = FirebaseFirestore.instance;
  var userRef;
  userRef = await firestoreInstance
      .collection('Users')
      .doc('UserList')
      .collection('Designers')
      .where('email', isEqualTo: email)
      .get();
  if (userRef.documents.length > 0) {
    print("Found designer user via email!");
    return userRef.documents[0]["uid"];
  } else {
    userRef = await firestoreInstance
        .collection('Users')
        .doc('UserList')
        .collection('Learners')
        .where('email', isEqualTo: email)
        .get();
  }
  if (userRef.documents.length > 0) {
    print("Found learner user via email!");
    return userRef.documents[0]["uid"];
  }
  //We didn't find anything, return null.
  return null;
}

