import 'package:flutter/material.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:flutter_app/taskInfo.dart';
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
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

var finPath;
int counter = 0;
var pathPasser;
var nameOfTask;
var idOfTask;
String namePasser;
class Tasks extends StatefulWidget {
  Tasks({Key key, this.taskName}) : super(key: key);
  // always marked "final".
  final String taskName;
  //final String courseId;

  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  @override
  Widget build(BuildContext context) {
    var lessonPath = userPath.collection('Courses').doc(modName).collection('Modules').doc(lessonName).collection('Lessons').doc(widget.taskName);
    finPath = lessonPath;
    namePasser = widget.taskName;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.taskName + " Tasks",
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
                    MaterialPageRoute(builder: (context) => new CreateTask()));
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
              stream: lessonPath.collection('Tasks').snapshots(),
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
                    counter = snapshot.data.documents.length;
                    return new ListTile(
                      title: new Text(document.data()['name']),

                      trailing: IconButton(
                        icon: Icon(Icons.info),
                        tooltip: 'Task Page',
                          onPressed: () {
                            setState(() {
                            });
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => taskInfo(
                                taskName: document.data()["name"],
                                taskType: document.data()['tasktype'],
                                mediaLink:document.data()["medialink"] ,),
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

class CreateTask extends StatelessWidget {
  List<Widget> course;
  TextEditingController nameEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Create Task')),
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
                          labelText: "Task Name",
                          prefixIcon: Icon(Icons.folder),
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
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: RaisedButton(
                        child: Text("Create Task"),
                        onPressed: () {
                          DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                          String date = dateFormat.format(DateTime.now());
                          finPath.collection('Tasks').doc(nameEditingController.text.trim()).set(
                              {
                                'orderid' : counter,
                                "dateopen" : date,
                                "designerid" : firebaseUser.uid,
                                "isopen" : true,
                                "id": nameEditingController.text.trim(),
                                "name" : nameEditingController.text.trim(),
                              }
                          );
                          pathPasser = finPath.collection('Tasks').doc(nameEditingController.text.trim());
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => new taskCreater()));
                        }),
                  ),
                ),
              ],
            )));
  }
}
