import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/models/Lesson.dart';
import 'package:flutter_app/models/Task.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/utils/session.dart';

class TaskProvider with ChangeNotifier {
  //Class private variables to be retrieved via getters
  final firestoreService = FirestoreService();
  String _id;
  String _prompt;
  String _taskType;
  String _mediaLink;
  String _imageLink;
  double _attemptCount;
  List<String> _userResponses;
  List<String> _multiChoices;
  String _correctChoice;
  double _orderId;
  String _retryFlag;
  List<String> _instructionImages;
  List<String> _instructionWords;
  List<String> _instructionMedias;

  //Getters
  String get id => _id;
  String get name => _prompt;
  String get taskType => _taskType;
  String get mediaLink => _mediaLink;
  String get imageLink => _imageLink;
  double get attemptCount => _attemptCount;
  List<String> get userResponses => _userResponses;
  List<String> get multiChoices => _multiChoices;
  String get correctChoice => _correctChoice;
  double get orderId => _orderId;
  String get retryFlag => _retryFlag;
  List<String> get instructionImages => _instructionImages;
  List<String> get instructionWords => _instructionWords;
  List<String> get instructionMedias => _instructionMedias;

  //Three parameter method to get the list of tasks for the clicked lesson.
  Future<List<Task>> getTasks(Session userSession) {
    return firestoreService.getTasks(userSession);
  }
}
