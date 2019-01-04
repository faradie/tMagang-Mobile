import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ManajemenPemagang extends StatefulWidget {
  _ManajemenPemagangState createState() => _ManajemenPemagangState();
}

class _ManajemenPemagangState extends State<ManajemenPemagang> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Pemagang"),
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
    );
  }
}
