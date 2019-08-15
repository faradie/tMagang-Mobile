import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tempat_magang/college_page/qfd.dart';

final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);

class InternDevelopment extends StatefulWidget {
  InternDevelopment({this.collegeId});
  final String collegeId;
  @override
  _InternDevelopmentState createState() => _InternDevelopmentState();
}

class _InternDevelopmentState extends State<InternDevelopment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          new FlatButton(
            child: new Icon(
              Icons.show_chart,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Solusi Pengembangan"),
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: new Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
        ),
      ),
      body: new Container(
        child: ListInternHistory(
          id: widget.collegeId,
        ),
      ),
    );
  }
}

class ListInternHistory extends StatefulWidget {
  ListInternHistory({this.id});
  final String id;
  @override
  ListInternHistoryState createState() {
    return new ListInternHistoryState();
  }
}

class ListInternHistoryState extends State<ListInternHistory> {
  DateTime dateNow = DateTime.now();
  var firestore = Firestore.instance;
  String vacanciesId;
  bool check = false;

  Future _getInternHistory() async {
    
    QuerySnapshot qn = await firestore
        .collection('reportIntern')
        .where('collegeId', isEqualTo: widget.id)
        .getDocuments();

    return qn.documents;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _getInternHistory(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[loadingLoad, Text("Loading Data..")],
              ),
            );
          } else {
            if (snapshot.data.length == 0) {
              return new Center(
                child: new Text("Belum ada data magang..."),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index) {
                    List<double> _kepuasan = List(7);
                    _kepuasan[0] = snapshot.data[index].data["KP1"];
                    _kepuasan[1] = snapshot.data[index].data["KP2"];
                    _kepuasan[2] = snapshot.data[index].data["KP3"];
                    _kepuasan[3] = snapshot.data[index].data["KP4"];
                    _kepuasan[4] = snapshot.data[index].data["KP5"];
                    _kepuasan[5] = snapshot.data[index].data["KP6"];
                    _kepuasan[6] = snapshot.data[index].data["KP7"];
                    // print("$wew");
                    // for (var i = 0; i < 7; i++) {

                    //      print("$i inilah $wew");
                    // }
                    return new TimePemagang(
                      userId: snapshot.data[index].data["userId"],
                      vacanciesId: snapshot.data[index].data["vacanciesId"],
                      kepuasan: _kepuasan,
                      no: (index + 1).toString(),
                    );
                  },
                );
            }
          }
        },
      ),
    );
  }
}

class TimePemagang extends StatefulWidget {
  TimePemagang({this.userId, this.vacanciesId, this.no, this.kepuasan});

  final String userId, vacanciesId, no;
  final List<double> kepuasan;

  @override
  TimePemagangState createState() {
    return new TimePemagangState();
  }
}

class TimePemagangState extends State<TimePemagang> {
  var name, agency;
  String _namaUser, _judulLowongan, _nimUser;
  var firestore = Firestore.instance;
  List<double> kImportance = List(7);

  Future _getImportance() async {
    var vacanciesQuery = firestore
        .collection('internNeeded')
        .where('vacanciesId', isEqualTo: widget.vacanciesId)
        .limit(1);
    vacanciesQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          kImportance[0] = data.documents[0].data['K1'];
          kImportance[1] = data.documents[0].data['K2'];
          kImportance[2] = data.documents[0].data['K3'];
          kImportance[3] = data.documents[0].data['K4'];
          kImportance[4] = data.documents[0].data['K5'];
          kImportance[5] = data.documents[0].data['K6'];
          kImportance[6] = data.documents[0].data['K7'];
        });
      }else{
        setState(() {
         kImportance = null; 
        });
      }
    });
  }

  Future _getPenilaian() async {
    var userQuery = firestore
        .collection('users')
        .where('uid', isEqualTo: widget.userId)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          name = data.documents[0].data['data'] as Map<dynamic, dynamic>;
          _namaUser = name["displayName"];
          _nimUser = name["studentIDNumber"];
          // _statusUser = data.documents[0].data['isActive'];
        });

        var vacanciesHistory = firestore
            .collection('vacancies')
            .where('id', isEqualTo: widget.vacanciesId)
            .limit(1);

        vacanciesHistory.getDocuments().then((collegeData) {
          if (collegeData.documents.length > 0) {
            setState(() {
              _judulLowongan = collegeData.documents[0].data['title'];
            });
            print("judullll $_judulLowongan");
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getImportance();
    _getPenilaian();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Column(
      children: <Widget>[
        new Divider(),
        new ListTile(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(
                builder: (BuildContext context) => new QfDeployment(
                    judulLowongan: _judulLowongan,
                    kepuasan: widget.kepuasan,
                    kImportant: kImportance,
                    namaUser: _namaUser,
                    nim: _nimUser,
                    idLowongan: widget.vacanciesId)));
          },
          leading: new Text(
            widget.no,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          title: new Text(
            _namaUser == null ? "" : _namaUser,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: new Text(
              "Magang di : ${_judulLowongan == null ? "" : _judulLowongan}"),
          // trailing: new Icon(widget.iconData, color: widget.warna),
        ),
      ],
    ));
  }
}
