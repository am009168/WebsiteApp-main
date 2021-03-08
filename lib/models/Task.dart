import 'package:flutter/material.dart';

class Task {
  //Unique id for this task
  String id;
  //Prompt that appears for the task inputted by designer.
  String prompt;

  //Flag to designate task type
  String taskType;

  //For perception tasks, this designates the audio or video to be played.
  String mediaLink;

  //Image link
  String imageLink;

  //Number of attempts on this task
  var attemptCount;

  //List of all the responses sent for this task.
  var userResponses;

  //List of possible multiple choice answers.
  var multiChoices;

  //Correct choice for multiple choice
  String correctChoice;

  var orderId;

  String retryFlag;

  //Instruction task specific fields
  //List of images to be shown
  var instructionImages;
  //List of words to be displayed to the user
  var instructionWords;
  //List of audio file links to be played.
  var instructionMedias;

  Task(
      {@required this.id,
      @required this.prompt,
      @required this.taskType,
      this.mediaLink,
      this.imageLink,
      this.attemptCount,
      this.userResponses,
      this.multiChoices,
      this.correctChoice,
      this.orderId,
      this.retryFlag,
      this.instructionImages,
      this.instructionMedias,
      this.instructionWords});

  //Factory method allowing us to read from json from firestore to a local object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        id: json['id'],
        prompt: json['prompt'],
        taskType: json['tasktype'],
        mediaLink: json['medialink'],
        imageLink: json['imagelink'],
        attemptCount: json['attemptcount'],
        multiChoices: json['multichoices'],
        correctChoice: json['correctchoice'],
        userResponses: json['userresponses'],
        orderId: json['orderid'],
        retryFlag: json['retryflag'],
        instructionMedias: json['medialinks'],
        instructionImages: json['imagelinks'],
        instructionWords: json['instructionwords']);
  }
  //Allows us to push to the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prompt': prompt,
      'tasktype': taskType,
      'medialink': mediaLink,
      'imageLink': imageLink,
      'attemptcount': attemptCount,
      'multichoices': multiChoices,
      'correctchoice': correctChoice,
      'userresponses': userResponses,
      'orderid': orderId,
      'retryflag': retryFlag,
      'mediaLinks': instructionMedias,
      'imagelinks': instructionImages,
      'instructionwords': instructionWords
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "ID: " +
        this.id.toString() +
        " TaskType: " +
        this.taskType +
        " Orderid: " +
        this.orderId.toString();
  }
}
