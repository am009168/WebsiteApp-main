import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/models/Lesson.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/utils/session.dart';

class LessonProvider with ChangeNotifier {
  //Class private variables to be retrieved via getters
  final firestoreService = FirestoreService();
  String _id;
  String _name;
  bool _isOpen;
  String _dateOpen;
  String _dateClose;
  List<String> _learnerIds;

  //Getters
  String get id => _id;
  String get name => _name;
  bool get isOpen => _isOpen;
  String get dateOpen => _dateOpen;
  String get dateClose => _dateClose;
  List<String> get learnerIds => _learnerIds;

  Future<List<Lesson>> getLessons(Session userSession) {
    return firestoreService.getLessons(userSession);
  }
}
