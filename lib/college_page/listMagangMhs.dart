import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);

class ListMagangMhs extends StatefulWidget {
  ListMagangMhs({this.idCollege});
  final String idCollege;
  _ListMagangMhsState createState() => _ListMagangMhsState();
}

class _ListMagangMhsState extends State<ListMagangMhs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("List Magang"),
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
        child: ListMagang(
          id: widget.idCollege,
        ),
      ),
    );
  }
}

class ListMagang extends StatefulWidget {
  ListMagang({this.id});
  final String id;
  @override
  ListMagangState createState() {
    return new ListMagangState();
  }
}

class ListMagangState extends State<ListMagang> {
  DateTime dateNow = DateTime.now();

  Future getMagang() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('internship')
        .where('collegeId', isEqualTo: widget.id)
        .getDocuments();

    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getMagang(),
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
                  return new TimePemagang(
                    userId: snapshot.data[index].data["userId"],
                    ownerAgency: snapshot.data[index].data["ownerAgency"],
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
  TimePemagang({this.userId, this.ownerAgency, this.no});

  final String userId, ownerAgency, no;

  @override
  TimePemagangState createState() {
    return new TimePemagangState();
  }
}

class TimePemagangState extends State<TimePemagang> {
  var name, agency;
  String _namaUser, _namaAgency;
  Future getDatInternship() async {
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
          // _statusUser = data.documents[0].data['isActive'];
        });

        var agencyQuery = firestore
            .collection('users')
            .where('uid', isEqualTo: widget.ownerAgency)
            .limit(1);

        agencyQuery.getDocuments().then((collegeData) {
          if (collegeData.documents.length > 0) {
            setState(() {
              agency = collegeData.documents[0].data['data']
                  as Map<dynamic, dynamic>;
              _namaAgency = agency["displayName"];
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getDatInternship();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Column(
      children: <Widget>[
        new Divider(),
        new ListTile(
          onTap: () {
            // Navigator.of(
            //   context,
            // ).push(MaterialPageRoute(
            //     builder: (BuildContext context) => new DetailLowonganInstansi(
            //           judul: widget.judul,
            //           idLowongan: widget.idLowongan,
            //         )));
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
              new Text("Magang di : ${_namaAgency == null ? "" : _namaAgency}"),
          // trailing: new Icon(widget.iconData, color: widget.warna),
        ),
      ],
    ));
  }
}
