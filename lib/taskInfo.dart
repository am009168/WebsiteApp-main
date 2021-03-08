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

var infoPath;
class taskInfo extends StatefulWidget {
  taskInfo({Key key, this.taskName}) : super(key: key);
  // always marked "final".
  final String taskName;

  //final String courseId;

  @override
  _infoState createState() => _infoState();
}

class _infoState extends State<taskInfo> {
  @override
  Widget build(BuildContext context) {
    var pather = finPath.collection('Tasks').doc(widget.taskName);
    infoPath = pather.collection('TaskResponses');
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.taskName + " Task",
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
              stream: pather.collection('TaskResponses').snapshots(),
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
                      title: new Text(document.data()['learnerid']),
                      trailing: IconButton(
                          icon: Icon(Icons.info),
                          tooltip: 'Get Learner Information',
                          onPressed: () {
                            setState(() {
                            });
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => responses(
                                learner: document.data()["learnerid"],),
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
