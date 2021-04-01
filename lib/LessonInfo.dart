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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title:Container(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Smart-Talk Course Page'),
                InkWell(
                  onTap: () {
                    delete();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Lessons(
                          LessonName: lessonName),
                    )
                    );
                  },
                  child: Text(
                    'Delete Task',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => new editLesson(
                          lessonName: widget.lessonName,
                        )));
                  },
                  child: Text(
                    'Edit Lesson',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container( // image below the top bar
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    'assets/bg.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left:MediaQuery.of(context).size.width * 0.37,
                top: MediaQuery.of(context).size.height * 0.42,
                child: Card(
                  elevation: 8.0,
                  margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                      margin: new EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                      child: Text("Lesson Info",style: TextStyle(fontSize:50 ),)),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Image(image: AssetImage('assets/banner.png'),height:350 ,width: 750,),
                    SizedBox(height: 175,),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2)
                      ),
                      margin: const EdgeInsets.all(10.0),
                      width: 1500.0,
                      height: 500.0,
                      child: SingleChildScrollView(
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
                    ),
                  ],
                ),
              ),
            ],
          ),
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

