import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/Module.dart';
import 'package:flutter_app/providers/module_provider.dart';
import 'package:flutter_app/utils/session.dart';
import 'package:flutter_app/ModulePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'LessonPage.dart';
import 'dart:collection';
import 'dart:io' as io;
import 'dart:async';

import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class ModulePage extends StatefulWidget {
  ModulePage({Key key, this.courseName, this.userSession}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Session userSession;
  final String courseName;
  //final String courseId;

  @override
  _ModulePageState createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  @override
  Widget build(BuildContext context) {
    final moduleProvider = Provider.of<ModuleProvider>(context, listen: false);
    Future<List<Module>> userModules =
        moduleProvider.getModules(widget.userSession);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseName + " Modules",
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("CourseId: " + widget.userSession.courseId),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Please select your desired module.",
                style: new TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Flexible(
              child: FutureBuilder<List<Module>>(
                future: userModules,
                builder: (context, snapshot) {
                  //This will give us a loading indicator while we await the snapshot.
                  if (snapshot.data == null) return CircularProgressIndicator();

                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data[index].name),
                        leading: Icon(Icons.event_note),
                        trailing: Icon(Icons.arrow_forward_outlined),
                        onTap: () {
                          print("Module name");
                          print(snapshot.data[index].id);
                          //Update the current moduleId in the userSession object to pass.
                          widget.userSession.moduleId = snapshot.data[index].id;
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LessonPage(
                                moduleName: snapshot.data[index].name,
                                userSession: widget.userSession),
                          ));
                        },
                      );
                    },
                  );
                },
              ),
            ),
            /* Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const SizedBox(width: 3),
                TextButton(
                  child: const Text('OPEN'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LessonPage(isOpen: true)),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),*/
            RaisedButton(
                child: Text("Home"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuthenticationWrapper()),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
