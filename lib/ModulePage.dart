import 'package:flutter/material.dart';
import 'package:flutter_app/Lessons.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/Module.dart';
import 'package:flutter_app/providers/module_provider.dart';
import 'package:flutter_app/utils/session.dart';
import 'package:flutter_app/main.dart';
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

var path;
String modName;
class ModulePage extends StatefulWidget {
  ModulePage({Key key, this.courseID, this.courseName}) : super(key: key);
  // always marked "final".
  final String courseName;
  final String courseID ;

  //final String courseId;

  @override
  _ModulePageState createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  @override
  Widget build(BuildContext context) {
    var coursePath = userPath.collection('Courses').doc(widget.courseName);
    modName = widget.courseName;
    path = coursePath;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseName + " Modules",
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
                    MaterialPageRoute(builder: (context) => new CreateModule()));
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
              stream: coursePath.collection('Modules').snapshots(),
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
                      trailing: IconButton(
                        icon: Icon(Icons.info),
                        tooltip: 'Get Course Information',
                        onPressed: () {
                          setState(() {
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Lessons(
                              LessonName: document.data()["name"],
                              LessonID: document.data()['id'],),
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

class CreateModule extends StatelessWidget {
  List<Widget> course;
  TextEditingController nameEditingController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Create Module')),
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
                          labelText: "Module Name",
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
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: RaisedButton(
                        child: Text("Create Module"),
                        onPressed: () {
                          DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                          String date = dateFormat.format(DateTime.now());
                          path.collection('Modules').doc(nameEditingController.text.trim()).set(
                              {
                                "dateopen" : date,
                                "designerid" : firebaseUser.uid,
                                "isopen" : true,
                                "id": nameEditingController.text.trim(),
                                "name" : nameEditingController.text.trim(),
                              }
                          );
                          Navigator.pop(context, nameEditingController.text);
                        }),
                  ),
                ),
              ],
            )));
  }
}
