/*File consisting of useful utility functions to be used throughout the project
files and modules*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/models/Task.dart';
import 'package:flutter_app/screens/InstructionTask.dart';
import 'package:flutter_app/screens/PerceptionTask.dart';
import 'package:flutter_app/screens/ProductionTask.dart';
import 'package:flutter_app/classes/firestore_services.dart';
import 'package:flutter_app/screens/all_confetti_widget.dart';

import 'session.dart';

//Function to tell if our authenticated user is a learner or designer.
Future<bool> isDesigner() async {
  final firestoreInstance = FirebaseFirestore.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser;
  print("Seeing if userId: " + firebaseUser.uid + " is a designer.");
  //Grab a reference to the designers.
  var designersRef = await firestoreInstance
      .collection('Users')
      .doc('UserList')
      .collection('Designers')
      .doc(firebaseUser.uid)
      .get();

  if (designersRef.exists) {
    return true;
  }
  //Otherwise we are a learner, and we won't make it past the login without an account at all.
  return false;
}

void printName() async {
  final firestoreInstance = FirebaseFirestore.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser;
  String name;
  var userRef;
  bool isDesignerFlag = await isDesigner();

  if (isDesignerFlag) {
    //Grab a reference to the designers.
    userRef = await firestoreInstance
        .collection('Users')
        .doc('UserList')
        .collection('Designers')
        .doc(firebaseUser.uid)
        .get();
  } else {
    userRef = await firestoreInstance
        .collection('Users')
        .doc('UserList')
        .collection('Learners')
        .doc(firebaseUser.uid)
        .get();
  }

  name = userRef['firstname'];

  print("Trying to print the name");
  print(name);
}

Future<List<String>> getLearnerSubscriptions() async {
  final firestoreInstance = FirebaseFirestore.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser;
  var learnerSnapshot;
  var isDesignerFlag = await isDesigner();

  if (!isDesignerFlag) {
    print("Getting list of designers for current learner!");
    learnerSnapshot = await firestoreInstance
        .collection('Users')
        .doc('UserList')
        .collection('Learners')
        .doc(firebaseUser.uid)
        .get();
    return List.from(learnerSnapshot["designerids"]);
  }
  print("Getting list of designers for current designer!");
  learnerSnapshot = await firestoreInstance
      .collection('Users')
      .doc('UserList')
      .collection('Designers')
      .doc(firebaseUser.uid)
      .get();
  return List.from(learnerSnapshot["designerids"]);
}

Widget pushBadge() {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Text('Congratulations!'),
      centerTitle: true,
    ),
    body: AllConfettiWidget(
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/badge_silver.png'),
        ],
      )),
    ),
  );
}

Widget getNextTask(Session inputSession) {
  //switch statement to return the proper widget to build on a new navigation.
  if (inputSession.taskIndex == inputSession.currentTasks.length) {
    FirestoreService firestoreService = FirestoreService();
    //Push responses, catch a nullpointerexception if we dont have any stored.
    try {
      firestoreService.pushResponses(inputSession);
      firestoreService.updateLessonLearners(inputSession);
    } catch (error) {
      print('Error pushing responses' + error.toString());
    }
    //Push badge
    print("Pushing badge");
    //Return to homepage
    return pushBadge();
  }
  //Otherwise we have another task to load
  Task nextTask = inputSession.currentTasks.elementAt(inputSession.taskIndex);

  switch (nextTask.taskType) {
    case "instruction":
      return new InstructionTask(userSession: inputSession);
      break;
    case "multiplechoice":
      return new MultipleChoice(userSession: inputSession);
      break;
    case "freetext":
      return new FreeText(userSession: inputSession);
      break;
    case "video":
      return new VideoTask(userSession: inputSession);
      break;
    case "constproduction":
      return new ConstrainedProduction(userSession: inputSession);
      break;
    case "unconstproduction":
      return new UnconstrainedProduction(userSession: inputSession);
      break;
    default:
      return null;
      break;
  }
}
