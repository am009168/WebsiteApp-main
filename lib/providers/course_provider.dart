import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/models/Course.dart';
import 'package:flutter_app/classes/firestore_services.dart';

class CourseProvider with ChangeNotifier {
  //Class private variables to be retrieved via getters
  var firestoreService = FirestoreService();
  String _id;
  int _orderId;
  String _name;
  String _prefix;
  bool _isOpen;
  String _dateOpen;
  String _dateClose;
  var _learnerids;

  //Getters
  String get id => _id;
  int get orderId => _orderId;
  String get name => _name;
  String get prefix => _prefix;
  bool get isOpen => _isOpen;
  String get dateOpen => _dateOpen;
  String get dateClose => _dateClose;
  String get learnerIds => _learnerids;

  Future<List<Course>> get courses => firestoreService.getCourses();
}
