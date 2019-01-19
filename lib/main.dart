import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tempat_magang/auth.dart';
import 'package:tempat_magang/global_page/loaders.dart';
import 'root_page.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  bool isOffline = false;
  Firestore firestore = Firestore();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tempat Magang",
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        primaryColorDark: Colors.orange[900],
      ),
      home: new SplashNya(),
      routes: <String, WidgetBuilder>{
        '/rootNya': (BuildContext context) => new RootPage(
              auth: new Auth(),
            ),
        '/detailPost': (BuildContext context) => new RootPage(
              auth: new Auth(),
            ),
      },
    );
  }
}

class SplashNya extends StatefulWidget {
  @override
  _SplashNyaState createState() => _SplashNyaState();
}

class _SplashNyaState extends State<SplashNya> {
  Future getConn() async {
    var user = await FirebaseAuth.instance.currentUser();
    return user;
  }

  // AnimationController _animationController;
  // Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    // _animationController = new AnimationController(
    //     vsync: this, duration: new Duration(milliseconds: 500));
    // _animation = new CurvedAnimation(
    //   parent: _animationController,
    //   curve: Curves.easeOut,
    // );

    // _animation.addListener(() => this.setState(() {}));
    // _animationController.forward();

    Timer(
        Duration(seconds: 10),
        () => Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) {
                return RootPage(
                  auth: new Auth(),
                );
              },
              transitionDuration: Duration(milliseconds: 2000),
              transitionsBuilder: (context, animation1, animation2, child) {
                return FadeTransition(
                  opacity:
                      Tween<double>(begin: 0.0, end: 1.0).animate(animation1),
                  child: child,
                );
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'img/logoDoangS.png',
            width: 100.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          Text(
            "Temukan Tempat Magang Idealmu",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
            ),
          )
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: logo,
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ColorLoader3(
                      radius: 15.0,
                      dotRadius: 6.0,
                    )
                    // Padding(padding: EdgeInsets.only(top: 20.0),),
                    // Text("Mohon bersabar")
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
