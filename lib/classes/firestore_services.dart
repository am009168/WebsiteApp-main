import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/Course.dart';
import 'package:flutter_app/models/Lesson.dart';
import 'package:flutter_app/models/Module.dart';
import 'package:flutter_app/models/Response.dart';
import 'package:flutter_app/models/Task.dart';
import 'package:flutter_app/utils/session.dart';
import 'package:flutter_app/utils/utils.dart';

var firebaseUser1 = FirebaseAuth.instance.currentUser;
final firestoreInstance1 = FirebaseFirestore.instance;
var userPath1 = firestoreInstance1.collection("Users").doc('UserList').collection('Designers').doc(firebaseUser1.uid);
var coursePath = userPath1.collection('Courses');

class FirestoreService {
  //Grab the link to our service
  FirebaseFirestore _db = FirebaseFirestore.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser;

  //Upsert (Update and Create, C U)

  //Retrieve (R)

  //Query to load the current User's list of courses.
  Future<List<Course>> getCourses() async {
    //Check where the user is located, either in the Learner or Designer collection
    bool isDesignerUser = await isDesigner();
    //Refresh the local firebaseUser incase of signout.
    firebaseUser = FirebaseAuth.instance.currentUser;
    //List of all tasks from repeated queries combined into this one list.
    Future<List<Course>> courses;
    List<Course> workingCourses = [];
    List<String> learnerSubs = await getLearnerSubscriptions();
    if (isDesignerUser) {
      print("Getting designer courses for userId: " + firebaseUser.uid);
      //If we are a designer, add ourselves to the courses to load.
      learnerSubs.add(firebaseUser.uid);
      for (String currentId in learnerSubs) {
        print("Getting course id from designer " + currentId);
        await _db
            .collection('Users')
            .doc('UserList')
            .collection('Designers')
            .doc(currentId)
            .collection('Courses')
            .where("isopen", isEqualTo: true)
            .where("learnerids", arrayContains: firebaseUser.uid)
            .get()
            .then((value) {
          workingCourses.addAll(
              value.docs.map((e) => Course.fromJson(e.data())).toList());
        });
      }
      return workingCourses;
    } else {
      if (learnerSubs.length == 0) {
        print("NO LEARNER SUBS, RETURNING NULL");
        return workingCourses;
      }
      print("LEARNER SUBS LENGTH" + learnerSubs.length.toString());
      for (String currentId in learnerSubs) {
        print("Getting course id from designer " + currentId);
        await _db
            .collection('Users')
            .doc('UserList')
            .collection('Designers')
            .doc(currentId)
            .collection('Courses')
            .where("isopen", isEqualTo: true)
            .where("learnerids", arrayContains: firebaseUser.uid)
            .get()
            .then((value) {
          workingCourses.addAll(
              value.docs.map((e) => Course.fromJson(e.data())).toList());
        });
      }
    }
    return workingCourses;
  }

  //Query to load the current User's list of modules.
  Future<List<Module>> getModules(Session userSession) async {
    //Checks if the user is a designer or learner to search the right collection.
    bool isDesignerUser = await isDesigner();
    //Refresh the local firebaseUser incase of signout.
    firebaseUser = FirebaseAuth.instance.currentUser;
    return _db
        .collection('Users')
        .doc('UserList')
        .collection('Designers')
        .doc(userSession.designerId)
        .collection('Courses')
        .doc(userSession.courseId)
        .collection('Modules')
        .where("isopen", isEqualTo: true)
        .get()
        .then((value) =>
            value.docs.map((e) => Module.fromJson(e.data())).toList());
    /*else {
      print("Getting learner courses!");
      return _db
          .collection('Users')
          .doc('UserList')
          .collection('Learners')
          .doc(firebaseUser.uid)
          .collection('Courses')
          .doc(userSession.courseId)
          .collection('Modules')
          .where("isopen", isEqualTo: true)
          .get()
          .then((value) =>
              value.docs.map((e) => Module.fromJson(e.data())).toList());
    }*/
  }

  //Query to load the current User's list of modules.
  Future<List<Lesson>> getLessons(Session userSession) async {
    return _db
        .collection('Users')
        .doc('UserList')
        .collection('Designers')
        .doc(userSession.designerId)
        .collection('Courses')
        .doc(userSession.courseId)
        .collection('Modules')
        .doc(userSession.moduleId)
        .collection('Lessons')
        .where("isopen", isEqualTo: true)
        //This will be commented out for testing purposes. We are removing users after completion.
        //.where("learnerids", arrayContains: firebaseUser.uid)
        .get()
        .then((value) =>
            value.docs.map((e) => Lesson.fromJson(e.data())).toList());
  }

  //Query to load the lessons that have feedback from the designer.
  Future<List<Lesson>> getLessonFeedback(Session userSession) async {
    return _db
        .collection('Users')
        .doc('UserList')
        .collection('Designers')
        .doc(userSession.designerId)
        .collection('Courses')
        .doc(userSession.courseId)
        .collection('Modules')
        .doc(userSession.moduleId)
        .collection('Lessons')
        .where('hasfeedback', arrayContains: firebaseUser.uid)
        .get()
        .then((value) =>
            value.docs.map((e) => Lesson.fromJson(e.data())).toList());
  }

  //Query to load the current User's list of modules.
  Future<List<Task>> getTasks(Session userSession) async {
    //Checks if the user is a designer or learner to search the right collection.
    bool isDesignerUser = await isDesigner();
    //Refresh the local firebaseUser incase of signout.
    firebaseUser = FirebaseAuth.instance.currentUser;
    return _db
        .collection('Users')
        .doc('UserList')
        .collection('Designers')
        .doc(userSession.designerId)
        .collection('Courses')
        .doc(userSession.courseId)
        .collection('Modules')
        .doc(userSession.moduleId)
        .collection('Lessons')
        .doc(userSession.lessonId)
        .collection('Tasks')
        .orderBy('orderid')
        .get()
        .then(
            (value) => value.docs.map((e) => Task.fromJson(e.data())).toList());
    /*else {
      return _db
          .collection('Users')
          .doc('UserList')
          .collection('Learners')
          .doc(firebaseUser.uid)
          .collection('Courses')
          .doc(courseId)
          .collection('Modules')
          .doc(moduleId)
          .collection('Lessons')
          .doc(lessonId)
          .collection('Tasks')
          .where("isopen", isEqualTo: true)
          .get()
          .then((value) =>
              value.docs.map((e) => Task.fromJson(e.data())).toList());
    }*/
  }
  //Old stream version of these services, incase we need it later on.
  /*Stream<List<Course>> getCoursesStream() {
    return _db
        .collection('Users')
        .doc('UserList')
        .collection('Designers')
        .doc(firebaseUser.uid)
        .collection('Courses')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Course.fromJson(doc.data())).toList());
  }*/

  //This will take in the list of response objects and add them to TaskResponse
  //collections under each Task.
  void pushResponses(Session userSession) {
    //Merge options to create an upsert
    var options = SetOptions(merge: true);

    for (Response currResp in userSession.currentResponses) {
      //Set each collection for each task
      _db
          .collection('Users')
          .doc('UserList')
          .collection('Designers')
          .doc(userSession.designerId)
          .collection('Courses')
          .doc(userSession.courseId)
          .collection('Modules')
          .doc(userSession.moduleId)
          .collection('Lessons')
          .doc(userSession.lessonId)
          .collection('Tasks')
          .doc(currResp.taskId)
          .collection('TaskResponses')
          .doc(firebaseUser.uid)
          .set(currResp.toMap(), options);
    }
  }

  Future<void> updateLessonLearners(Session userSession) {
    var userList = [firebaseUser.uid];
    _db
        .collection('Users')
        .doc('UserList')
        .collection('Designers')
        .doc(userSession.designerId)
        .collection('Courses')
        .doc(userSession.courseId)
        .collection('Modules')
        .doc(userSession.moduleId)
        .collection('Lessons')
        .doc(userSession.lessonId)
        .update({
      "learnerids": FieldValue.arrayRemove(userList),
      "completedlearners": FieldValue.arrayUnion(userList)
    });
  }

//Cloud Firestore audio upload method.
  Future<String> uploadFile(String filePath) async {
    File file = File(filePath);
    String fileName = filePath.split("/").last;
    final ref = firebase_storage.FirebaseStorage.instance
        .ref("learneraudio/" + fileName);
    var url;
    try {
      //Keep it simple for right now, upload to root by leaving .ref() empty.
      await ref.putFile(file);
      //Grab the url to push to firestore entry for this task.
      url = await ref.getDownloadURL();
    } on Exception catch (_) {
      print('File upload failed!');
    }
    return url;
  }

  //Delete(D)
}
