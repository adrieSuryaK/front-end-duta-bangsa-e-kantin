import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constans.dart';
import '../models/gambar.dart';

class ProdukDetailPage extends StatefulWidget {
  final Widget? child;
  final int id;
  final String judul;
  final String harga;
  final String hargax;
  final String deskripsi;
  final String thumbnail;

  const ProdukDetailPage(this.id, this.judul, this.harga, this.hargax,
      this.deskripsi, this.thumbnail,
      {Key? key, this.child})
      : super(key: key);

  @override
  _ProdukDetailPageState createState() => _ProdukDetailPageState();
}

class _ProdukDetailPageState extends State<ProdukDetailPage> {
  String userid = "";
  int jmlnotif = 0;
  List<Gambar> gambarlain = [];

  @override
  void initState() {
    super.initState();
    fetchGambar();
  }

  Future<List<Gambar>> fetchGambar() async {
    List<Gambar> usersList = [];
    var params = "/gambarlainbyid?id=" + widget.id.toString();
    var sUrl = Uri.parse(Palette.sUrl + params);
    try {
      var jsonResponse = await http.get(sUrl);
      if (jsonResponse.statusCode == 200) {
        final jsonItems =
            json.decode(jsonResponse.body).cast<Map<String, dynamic>>();
        usersList = jsonItems.map<Gambar>((json) {
          return Gambar.fromJson(json);
        }).toList();
        setState(() {
          gambarlain = usersList;
        });
      }
      // ignore: empty_catches
    } catch (e) {}
    return usersList;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Palette.bg1,
    ));
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(widget.judul, style: const TextStyle(color: Colors.white)),
        backgroundColor: Palette.bg1,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _body(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    List<NetworkImage> _listOfImages = <NetworkImage>[];
    _listOfImages = [];
    for (int i = 0; i < gambarlain.length; i++) {
      _listOfImages
          .add(NetworkImage(Palette.sUrl + gambarlain[i].images.toString()));
    }
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            // ignore: prefer_is_empty
            child: Image.network(Palette.sUrl + widget.thumbnail,
                fit: BoxFit.fitWidth),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: SelectableText(widget.judul),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: SelectableText(widget.harga),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                SelectableText(
                  "Deskripsi :",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SelectableText(widget.deskripsi),
          ),
        ],
      ),
    );
  }
}
