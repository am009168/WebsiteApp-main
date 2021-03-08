import 'package:flutter/material.dart';
import 'package:flutter_app/models/Response.dart';
import 'package:flutter_app/models/Task.dart';

class Session {
  //Id of the designer who created the current course we are completing
  String designerId;
  //Current courseId
  String courseId;
  //Current moduleId
  String moduleId;
  //Current lessonId, TODO refactor into Lesson object for badge creation
  String lessonId;
  //Current taskIndex
  int taskIndex;
  //Current taskList
  List<Task> currentTasks;
  //List of responses to tasks
  List<Response> currentResponses;

  //Constructor to populate our fields.
  Session({@required this.courseId, @required this.designerId});

  void incrementTask() {
    taskIndex++;
  }
}
