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

  Future getInternHistory() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('reportIntern')
        .where('collegeId', isEqualTo: widget.id)
        .getDocuments();

    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getInternHistory(),
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
                  List<double> _kInt = List(7);
                  _kInt[0] = snapshot.data[index].data["K1"];
                  _kInt[1] = snapshot.data[index].data["K2"];
                  _kInt[2] = snapshot.data[index].data["K3"];
                  _kInt[3] = snapshot.data[index].data["K4"];
                  _kInt[4] = snapshot.data[index].data["K5"];
                  _kInt[5] = snapshot.data[index].data["K6"];
                  _kInt[6] = snapshot.data[index].data["K7"];

                  // print("$wew");
                  // for (var i = 0; i < 7; i++) {

                  //      print("$i inilah $wew");
                  // }
                  return new TimePemagang(
                    userId: snapshot.data[index].data["userId"],
                    vacanciesId: snapshot.data[index].data["vacanciesId"],
                    kImportant: _kInt,
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
  TimePemagang({this.userId, this.vacanciesId, this.no, this.kImportant});

  final String userId, vacanciesId, no;
  final List<double> kImportant;

  @override
  TimePemagangState createState() {
    return new TimePemagangState();
  }
}

class TimePemagangState extends State<TimePemagang> {
  var name, agency;
  String _namaUser,_judulLowongan,_nimUser;
  Future getInternship() async {
    var firestore = Firestore.instance;
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
            .where('id', isEqualTo: widget.vacanciesId).limit(1);

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
    getInternship();
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
                      kImportant: widget.kImportant,
                      namaUser: _namaUser,
                      nim: _nimUser,
                    )));
          },
          leading: new Text(
            widget.no,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          title: new Text(
            _namaUser == null ? "" : _namaUser,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle:
              new Text("Magang di : ${_judulLowongan == null ? "" : _judulLowongan}"),
          // trailing: new Icon(widget.iconData, color: widget.warna),
        ),
      ],
    ));
  }
}
