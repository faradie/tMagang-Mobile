import 'package:flutter/material.dart';
import 'package:tempat_magang/admin_page/admin_dashboard.dart';
import 'package:tempat_magang/college_page/college_dashboard.dart';
import 'package:tempat_magang/instansi_page/dashboard_instansi.dart';
import 'package:tempat_magang/mentor/dashboard_mentor.dart';

import 'package:tempat_magang/user_page/dashboard.dart';

import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus { notSignedIn, signedIn }

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  String _statusUser;

  void initState() {
    super.initState();
    
    widget.auth.currentUser().then((userId) {
      setState(() {
        // if(userId==null){
        //   AuthStatus.notSignedIn;
        //   _showDialog();
        // }
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
      if (userId != null) {
        getUser();
      }
    });
  }

  void _signedIn() {
    setState(() {
      getUser();
      authStatus = AuthStatus.signedIn;
    });
  }

  void getUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    var firestore = Firestore.instance;
    
    var userQuery = firestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .limit(1);
    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          _statusUser = data.documents[0].data['role'];
        });
      }
    });
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
      _statusUser = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (authStatus == AuthStatus.notSignedIn) {
      return new LoginPage(
        auth: widget.auth,
        onSignedIn: _signedIn,
      );
    } else if (authStatus == AuthStatus.signedIn && _statusUser == "agency") {
      return new InstansiDashboard(
        auth: widget.auth,
        onSignedOut: _signedOut,
        wew: _statusUser,
      );
    } else if (authStatus == AuthStatus.signedIn && _statusUser == "intern") {
      return new Dashboard(
        auth: widget.auth,
        onSignedOut: _signedOut,
      );
    } else if (authStatus == AuthStatus.signedIn && _statusUser == "admin") {
      return new AdminDashboard(
        auth: widget.auth,
        onSignedOut: _signedOut,
        wew: _statusUser,
      );
    } else if (authStatus == AuthStatus.signedIn && _statusUser == "college") {
      return new CollegeDashboard(
        auth: widget.auth,
        onSignedOut: _signedOut,
        wew: _statusUser,
      );
    } else if (authStatus == AuthStatus.signedIn && _statusUser == "mentor") {
      return new MentorDashboard(
        auth: widget.auth,
        onSignedOut: _signedOut,
        wew: _statusUser,
      );
    } else {
      return new LoginPage(
        auth: widget.auth,
        onSignedIn: _signedIn,
      );
    }
  }
}
