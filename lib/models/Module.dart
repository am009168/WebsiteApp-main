import 'package:flutter/material.dart';

class Module {
  //Module id unique identifier
  String id;
  //The actual name of the Module (ex: Intro to Languages)
  String name;
  //Get the prefix of the Modulename (ex: ENG 400)
  String prefix;
  //Flag to see if the Module itself is open
  bool isOpen;
  //Date open
  String dateOpen;
  //Date close
  String dateClose;
  //Constructor to populate our fields.
  Module(
      {@required this.id,
      @required this.name,
      this.prefix,
      this.isOpen,
      this.dateOpen,
      this.dateClose});

  //Factory method allowing us to read from json from firestore to a local object
  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      name: json['name'],
      isOpen: json['isopen'],
      dateOpen: json['dateopen'],
      dateClose: json['dateclose'],
    );
  }
  //Allows us to push to the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isopen': isOpen,
      'dateopen': dateOpen,
      'dateclose': dateClose
    };
  }
}
