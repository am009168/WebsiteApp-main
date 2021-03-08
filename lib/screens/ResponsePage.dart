import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/Lesson.dart';
import 'package:flutter_app/models/Response.dart';
import 'package:flutter_app/models/Task.dart';
import 'package:flutter_app/providers/lesson_provider.dart';
import 'package:flutter_app/providers/task_provider.dart';

import 'package:flutter_app/screens/InstructionTask.dart';
import 'package:flutter_app/utils/session.dart';
import '../main.dart';
import 'package:flutter_app/utils/utils.dart';
import 'PerceptionTask.dart';
import 'ProductionTask.dart';
import 'dart:collection';

class ResponsePage extends StatefulWidget {
  ResponsePage({Key key, this.userSession}) : super(key: key);

  //Current userSession and course ids.
  final Session userSession;

  @override
  _ResponsePageState createState() => _ResponsePageState();
}

class _ResponsePageState extends State<ResponsePage> {
  @override
  Widget build(BuildContext context) {
    //Init providers and lesson future
    //Provider of lessons to be displayed on this screen's futurebuilder
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
    //Provider of tasks to be displayed starting on the next page.
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    Future<List<Lesson>> userLessons =
        lessonProvider.getLessons(widget.userSession);
    Future<List<Task>> userTasks = taskProvider.getTasks(widget.userSession);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Instructor Feedback Page",
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Please select your desired lesson.",
                style: new TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Flexible(
              child: FutureBuilder<List<Lesson>>(
                future: userLessons,
                builder: (context, snapshot) {
                  //This will give us a loading indicator while we await the snapshot.
                  if (snapshot.data == null) return CircularProgressIndicator();
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      print(index);
                      return ListTile(
                        title: Text(snapshot.data[index].name),
                        leading: Icon(Icons.event_note),
                        trailing: Icon(Icons.arrow_forward_outlined),
                        onTap: () async {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AuthenticationWrapper(),
                          ));
                        },
                      );
                    },
                  );
                },
              ),
            ),
            RaisedButton(
                child: Text("View Feedback"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuthenticationWrapper()),
                  );
                }),
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
