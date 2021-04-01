import 'package:flutter/material.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:flutter_app/editLesson.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

var infoGetter;
String stuff ;
class LessonInfo extends StatefulWidget {
  LessonInfo({Key key, this.lessonName}) : super(key: key);
  // always marked "final".
  final String lessonName;

  //final String courseId;

  @override
  _infoState createState() => _infoState();
}

class _infoState extends State<LessonInfo> {
  TextEditingController nameEditingController = new TextEditingController();

  void delete()
  {
    firestoreInstance.collection("Users").doc('UserList').collection('Designers').doc(firebaseUser.uid)
        .collection('Courses').doc(modName)
        .collection('Modules').doc(lessonName)
        .collection('Lessons').doc(widget.lessonName).delete();
  }

  @override

  Widget build(BuildContext context) {
    infoGetter = userPath.collection('Courses').doc(modName).collection('Modules').doc(lessonName).collection('Lessons').doc(widget.lessonName);
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.lessonName + " Lesson",
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Delete Task',
              onPressed: () {
                delete();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Lessons(
                      LessonName: lessonName),
                )
                );
              },
            ),

            IconButton(
              icon: Icon(Icons.edit_outlined),
              tooltip: 'Edit Lesson',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new editLesson(
                      lessonName: widget.lessonName,
                    )));
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                print("Stupid Debug Flag.");
              },
            ),
          ]),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Add new user to Lesson "),
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

