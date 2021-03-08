import 'package:flutter/material.dart';

class Course {
  //Course designer userid
  String designerId;
  //Course id unique identifier
  String id;
  //Course id order identifier
  var orderId;
  //The actual name of the course (ex: Intro to Languages)
  String name;
  //Get the prefix of the coursename (ex: ENG 400)
  String prefix;
  //Flag to see if the course itself is open
  bool isOpen;
  //Date open
  String dateOpen;
  //Date close
  String dateClose;
  //List of registered learners
  var learnerIds;
  //Constructor to populate our fields.
  Course(
      {@required this.designerId,
      @required this.id,
      @required this.name,
      this.orderId,
      this.prefix,
      this.isOpen,
      this.dateOpen,
      this.dateClose,
      this.learnerIds});

  //Factory method allowing us to read from json from firestore to a local object
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
        designerId: json['designerid'],
        id: json['id'],
        orderId: json['orderid'],
        name: json['name'],
        prefix: json['prefix'],
        isOpen: json['isopen'],
        dateOpen: json['dateopen'],
        dateClose: json['dateclose'],
        learnerIds: json['learnerids']);
  }
  //Allows us to push to the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderid': orderId,
      'name': name,
      'prefix': prefix,
      'isopen': isOpen,
      'dateopen': dateOpen,
      'dateclose': dateClose,
      'learnerids': learnerIds
    };
  }
}
