import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class QfDeployment extends StatefulWidget {
  QfDeployment({this.kImportant, this.namaUser, this.nim, this.judulLowongan});
  final String judulLowongan, nim, namaUser;
  final List<double> kImportant;
  @override
  _QfDeploymentState createState() => _QfDeploymentState();
}

class _QfDeploymentState extends State<QfDeployment> {
  var rate;
  List<double> _rw = List(7);
  List<double> _rw2 = List(15);
  List<double> _importance = List(15);
  List<Map<String, dynamic>> myMaps = List(15);
  @override
  void initState() {
    super.initState();
    //rata-rata
    num sum = 0;
    widget.kImportant.forEach((num e) {
      sum += e;
    });
    rate = sum / 35 * 100;

    //relative weight
    for (var i = 0; i < _rw.length; i++) {
      _rw[i] = widget.kImportant[i] / sum * 100;
    }
    // print("ikirw $_rw");

    //importance from weight
    // for (var i = 0; i < _kInt.length; i++) {
    //   print("ikilhos $i ${_kInt[i]}");
    // }
    List<List<double>> _tInt = [
      [0, 9, 0, 0, 0, 9, 9, 0, 0, 0, 0, 3, 1, 9, 0],
      [9, 0, 0, 9, 1, 3, 3, 3, 0, 3, 9, 3, 1, 0, 3],
      [3, 0, 9, 3, 3, 0, 1, 0, 1, 0, 1, 3, 9, 0, 0],
      [0, 0, 3, 1, 0, 0, 0, 0, 0, 3, 0, 1, 1, 1, 0],
      [0, 0, 0, 9, 1, 1, 1, 1, 3, 3, 9, 0, 3, 0, 9],
      [1, 0, 0, 9, 0, 0, 0, 9, 3, 1, 9, 3, 0, 0, 0],
      [0, 0, 0, 0, 9, 0, 0, 3, 0, 0, 0, 0, 1, 0, 0],
    ];

    for (var i = 0; i < 15; i++) {
      var value = 0.0;
      for (var n = 0; n < _tInt.length; n++) {
        value += _tInt[n][i] * _rw[n];
      }
      _importance[i] = value;
    }
    // print("col $_importance");

    num sum2 = 0;
    _importance.forEach((num e) {
      sum2 += e;
    });
    for (var i = 0; i < _rw2.length; i++) {
      _rw2[i] = _importance[i] / sum2 * 100;
    }

    // print("cekkk : $_rw2");
    //relative weight
    // for (var i = 0; i < _rw.length; i++) {
    //   _rw[i] = widget.kImportant[i] / sum * 100;
    // }

    for (var i = 0; i < 15; i++) {
      myMaps[i] = <String, dynamic>{
        "kode": "T${i + 1}",
        "rw2": _rw2[i],
        "weight": _importance[i]
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Pengembangan"),
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
      body: ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "${widget.namaUser}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "${widget.nim}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "${widget.judulLowongan}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey),
            ),
          ),
          SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Hasil Magang",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "Integritas : ${widget.kImportant[0] / 5 * 100}%",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "Keahlian : ${widget.kImportant[1] / 5 * 100}%",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "Komunikasi : ${widget.kImportant[2] / 5 * 100}%",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "Kerjasama : ${widget.kImportant[3] / 5 * 100}%",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "Pengembangan Diri : ${widget.kImportant[4] / 5 * 100}%",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "Penggunaan Teknologi : ${widget.kImportant[5] / 5 * 100}%",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "Bahasa Inggris : ${widget.kImportant[6] / 5 * 100}%",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey),
            ),
          ),
          new Divider(),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "Rata-rata : $rate%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          new Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(
                "${rate >= 50.0 ? "Kompeten" : "Belum Kompeten"}".toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            child: new Text(
              "Prioritas Pengembangan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Container(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.grey,
                );
              },
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: myMaps.length == null ? 1 : myMaps.length+1,
              itemBuilder: (context, index) {
                if (index == 0) {
                    // return the header
                    return new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        new Text("Kode"),
                        new Text("Importance"),
                        new Text("Relative Weight"),
                      ],
                    );
                }
                index -= 1;
                return new ListTile(
                  leading: new Text("${myMaps[index]["kode"]}"),
                  title: new Text("${myMaps[index]["weight"].toStringAsFixed(3)}"),
                  trailing: new Text("${myMaps[index]["rw2"].toStringAsFixed(3)}"),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
