import 'package:flutter/material.dart';

class Response {
  //Unique id for this task
  String taskId;
  //Type of task this response originated from
  String taskType;
  //User id of the learner
  String learnerId;
  //List of responses
  var learnerResponses;
  //Designer feedback
  String designerFeedback;
  //Number of attempts for this task
  double attemptCount;

  Response(
      {@required this.taskId,
      @required this.learnerResponses,
      @required this.learnerId,
      @required this.attemptCount,
      this.taskType,
      this.designerFeedback});

  //Factory method allowing us to read from json from firestore to a local object
  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
        taskId: json['taskid'],
        taskType: json['tasktype'],
        learnerId: json['learnerid'],
        attemptCount: json['attemptcount'],
        learnerResponses: json['learnerresponses']);
  }
  //Allows us to push to the database.
  Map<String, dynamic> toMap() {
    return {
      'taskid': taskId,
      'tasktype': taskType,
      'learnerid': learnerId,
      'learnerresponses': learnerResponses,
      'designerfeedback': designerFeedback,
      'attemptcount': attemptCount
    };
  }
}
