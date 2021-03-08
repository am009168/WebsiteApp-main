import 'package:flutter/material.dart';

class Lesson {
  //Lesson id unique identifier
  String id;
  //The actual name of the Lesson (ex: Intro to Languages)
  String name;
  //Flag to see if the Lesson itself is open
  bool isOpen;
  //Date open
  String dateOpen;
  //Date close
  String dateClose;
  //List of assigned users for this lesson, broke when defined as List<String>
  var learnerIds;

  //Constructor to populate our fields.
  Lesson(
      {@required this.id,
      @required this.name,
      @required this.isOpen,
      this.dateOpen,
      this.dateClose,
      this.learnerIds});

  //Factory method allowing us to read from json from firestore to a local object
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
        id: json['id'],
        name: json['name'],
        isOpen: json['isopen'],
        dateOpen: json['dateopen'],
        dateClose: json['dateclose'],
        learnerIds: json['learnerids']);
  }
  //Allows us to push to the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isopen': isOpen,
      'dateopen': dateOpen,
      'dateclose': dateClose,
      //May need to refactor this to push a list properly
      'learnerids': learnerIds
    };
  }
}
