import 'package:flutter/material.dart';
import 'package:flutter_app/LessonInfo.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/Tasks.dart';
import 'package:flutter_app/screens/LessonPage.dart';
import 'dart:collection';
import 'dart:io' as io;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

var path;
String lessonName;
var bigLesson;
class Lessons extends StatefulWidget {
  Lessons({Key key, this.LessonName}) : super(key: key);
  // always marked "final".
  final String LessonName;

  //final String courseId;

  @override
  _LessonsState createState() => _LessonsState();
}

class _LessonsState extends State<Lessons> {
  @override
  Widget build(BuildContext context) {
    var modulePath = userPath.collection('Courses').doc(modName).collection('Modules').doc(widget.LessonName);
    path = modulePath;
    lessonName = widget.LessonName;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.LessonName + " Lessons",
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: 'refresh courses',
              onPressed: () {
                setState(() {}) ;
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'add course',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new CreateLesson()));
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
            StreamBuilder<QuerySnapshot>(
              stream: modulePath.collection('Lessons').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return new ListView(
                  shrinkWrap: true,
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return new ListTile(
                      title: new Text(document.data()['name']),
                      leading:  IconButton(
                          icon: Icon(Icons.info),
                          tooltip: 'Get Lesson Information',
                          onPressed: () {
                            setState(() {
                            });
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LessonInfo(
                                lessonName: document.data()["name"],),
                            )
                            );}
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_right),
                        tooltip: 'Get Lesson Information',
                        onPressed: () {
                          setState(() {
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Tasks(
                              taskName: document.data()["name"],),
                          )
                          );}
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class CreateLesson extends StatefulWidget {
  @override
  _CreateLessonState createState() => _CreateLessonState();
}

class _CreateLessonState extends State<CreateLesson> {
  List<Widget> course;

  TextEditingController nameEditingController = new TextEditingController();

  DateTime selectedDateOpen = DateTime.now();

  DateTime selectedDateClose = DateTime.now();

  bool value = false;

  Future<Null> _selectDateOpen(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateOpen,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDateOpen)
      setState(() {
        selectedDateOpen = picked;
      });
  }

  Future<Null> _selectDateClose(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDateClose,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDateClose)
      setState(() {
        selectedDateClose = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Create Lesson')),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Column(
                  children: [
                    Container(
                      child: TextField(
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        autofocus: false,
                        cursorColor: Colors.blue,
                        maxLengthEnforced: true,
                        controller: nameEditingController,
                        decoration: InputDecoration(
                          labelText: "Lesson Name",
                          prefixIcon: Icon(Icons.edit),
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
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Set Open Date and Close Date: ',
                      style: TextStyle(fontSize: 17.0),
                    ),
                    SizedBox(width: 10),
                    Checkbox(
                      value: this.value,
                      onChanged: (bool value) {
                        setState(() {
                          this.value = value;
                        });
                        print(value);
                      },
                    ),
                  ],
                ),
                (value)
                    ?Container(
                  child: Column(
                    children: [
                      Text("Date open: " + "${selectedDateOpen.toLocal()}".split(' ')[0]),
                      SizedBox(height: 20.0,),
                      RaisedButton(
                        onPressed: () => _selectDateOpen(context),
                        child: Text('Select Open Date'),
                      ),
                      SizedBox(height: 50.0,),
                      Text("Date close: " + "${selectedDateClose.toLocal()}".split(' ')[0]),
                      SizedBox(height: 20.0,),
                      RaisedButton(
                        onPressed: () => _selectDateClose(context),
                        child: Text('Select Close Date'),
                      ),
                    ],
                  ),
                ):Container(),

                Container(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: RaisedButton(
                        child: Text("Create Lesson"),
                        onPressed: () {
                          if (value)
                          {
                            path.collection('Lessons').doc(nameEditingController.text.trim()).set(
                                {
                                  "hasfeedback" : [],
                                  "completedlearners" : [],
                                  "learnerids" : [],
                                  "dateopen": selectedDateOpen.toString(),
                                  "dateclose": selectedDateClose.toString(),
                                  "designerid" : firebaseUser.uid,
                                  "isopen" : true,
                                  "id": nameEditingController.text.trim(),
                                  "name" : nameEditingController.text.trim(),
                                }
                            );
                          }
                          else
                          {
                            path.collection('Lessons').doc(nameEditingController.text.trim()).set(
                                {
                                  "hasfeedback" : [],
                                  "completedlearners" : [],
                                  "learnerids" : [],
                                  "dateopen" : "1999-01-21 15:00:00.000",
                                  "dateclose" : "3021-01-21 15:00:00.000",
                                  "designerid" : firebaseUser.uid,
                                  "isopen" : true,
                                  "id": nameEditingController.text.trim(),
                                  "name" : nameEditingController.text.trim(),
                                }
                            );
                          }
                          Navigator.pop(context, nameEditingController.text);
                        }),
                  ),
                ),
              ],
            )));
  }
}
