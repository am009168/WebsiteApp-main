import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/models/Module.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/utils/session.dart';

class ModuleProvider with ChangeNotifier {
  //Class private variables to be retrieved via getters
  final firestoreService = FirestoreService();
  String _id;
  String _name;
  bool _isOpen;
  String _dateOpen;
  String _dateClose;

  //Getters
  String get id => _id;
  String get name => _name;
  bool get isOpen => _isOpen;
  String get dateOpen => _dateOpen;
  String get dateClose => _dateClose;

  Future<List<Module>> getModules(Session userSession) {
    return firestoreService.getModules(userSession);
  }
}
