import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/Lesson.dart';
import 'package:flutter_app/models/Response.dart';
import 'package:flutter_app/models/Task.dart';
import 'package:flutter_app/providers/lesson_provider.dart';
import 'package:flutter_app/providers/task_provider.dart';

import 'package:flutter_app/screens/InstructionTask.dart';
import 'package:flutter_app/screens/ResponsePage.dart';
import 'package:flutter_app/utils/session.dart';
import '../main.dart';
import 'package:flutter_app/utils/utils.dart';
import 'PerceptionTask.dart';
import 'ProductionTask.dart';
import 'dart:collection';

class LessonPage extends StatefulWidget {
  LessonPage({Key key, this.moduleName, this.userSession}) : super(key: key);

  //Name of the parent module
  final String moduleName;
  //Current userSession and course ids.
  final Session userSession;

  @override
  _LessonPageState createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  @override
  Widget build(BuildContext context) {
    //Init providers and lesson future
    //Provider of lessons to be displayed on this screen's futurebuilder
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
    //Provider of tasks to be displayed starting on the next page.
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    Future<List<Lesson>> userLessons =
        lessonProvider.getLessons(widget.userSession);

    List<Task> userTasks;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.moduleName + " Lessons",
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
                  print("CourseId: " +
                      widget.userSession.courseId +
                      " ModuleId: " +
                      widget.userSession.moduleId);
                  //This will give us a loading indicator while we await the snapshot.
                  if (snapshot.data == null) return CircularProgressIndicator();

                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      print("Building list of courses");
                      print(index);
                      return ListTile(
                        title: Text(snapshot.data[index].name),
                        leading: Icon(Icons.event_note),
                        trailing: Icon(Icons.arrow_forward_outlined),
                        onTap: () async {
                          print("Learner Ids");
                          print(snapshot.data[index].learnerIds);
                          //Initialize the list of learner tasks for this lesson.
                          //Set the current lessonId to load the tasks.
                          widget.userSession.lessonId = snapshot.data[index].id;
                          //Grab the list of tasks for the selected lesson.
                          userTasks =
                              await taskProvider.getTasks(widget.userSession);
                          //Start our index at zero for the first task
                          widget.userSession.taskIndex = 0;
                          //Pass the list of tasks to the getNextTask func to start the lesson.
                          widget.userSession.currentTasks = userTasks;
                          //Init an empty list to store our responses.
                          widget.userSession.currentResponses = <Response>[];
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                getNextTask(widget.userSession),
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
                        builder: (context) => ResponsePage(
                              userSession: widget.userSession,
                            )),
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
