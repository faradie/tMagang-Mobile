import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tempat_magang/user_page/internprofil.dart';

final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);

class ManajemenPemagang extends StatefulWidget {
  ManajemenPemagang({this.idCollege});
  final String idCollege;
  _ManajemenPemagangState createState() => _ManajemenPemagangState();
}

class _ManajemenPemagangState extends State<ManajemenPemagang> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Mahasiswa"),
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: new Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
        ),
        // actions: <Widget>[
        //   new FlatButton(
        //     child: new Icon(Icons.search, color: Colors.white),
        //     onPressed: () {},
        //   )
        // ],
      ),
      body: new Container(
        child: ListMhs(
          id: widget.idCollege,
        ),
      ),
    );
  }
}

class ListMhs extends StatefulWidget {
  ListMhs({this.id});
  final String id;
  @override
  ListMhsState createState() {
    return new ListMhsState();
  }
}

class ListMhsState extends State<ListMhs> {
  DateTime dateNow = DateTime.now();

  Future getMagang() async {
    var firestore = Firestore.instance;
    print("ini widget ${widget.id}");
    QuerySnapshot qn = await firestore
        .collection('users')
        .where('data.collegeId', isEqualTo: '${widget.id}')
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
                child: new Text("Belum ada data Mahasiswa..."),
              );
            } else {
              print("banyak data ${snapshot.data.length}");
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  return new TilePemagang(
                    userId: snapshot.data[index].data["uid"],
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

class TilePemagang extends StatefulWidget {
  TilePemagang({this.userId, this.no});

  final String userId, no;

  @override
  TilePemagangState createState() {
    return new TilePemagangState();
  }
}

class TilePemagangState extends State<TilePemagang> {
  var name, agency;
  String _namaUser, _nimNya;
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
          _nimNya = name["studentIDNumber"];
          // _statusUser = data.documents[0].data['isActive'];
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
            Navigator.of(
              context,
            ).push(MaterialPageRoute(
                builder: (BuildContext context) => new InternProfil(
                      id: widget.userId,
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
          subtitle: new Text("NIM : ${_nimNya == null ? "" : _nimNya}"),
          // trailing: new Icon(widget.iconData, color: widget.warna),
        ),
      ],
    ));
  }
}
