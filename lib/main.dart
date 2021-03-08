import 'package:flutter/material.dart';
import 'package:flutter_app/website.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/authentication.dart';
import 'package:flutter_app/SignIn.dart';

//Use main.dart just to hold main and any very basic widgets.
void main() {
  runApp(MaterialApp(title: "Different pages test", home: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Authentication>(
          create: (_) => Authentication(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<Authentication>().authStateChange,
        )
      ],
      child: MaterialApp(
        title: 'Tasks Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return FirstScreen();
    }
    return SignIn();
  }
}
