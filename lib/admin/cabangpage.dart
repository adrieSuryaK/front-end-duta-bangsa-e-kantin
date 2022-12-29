import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constans.dart';
import '../models/cabang.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'formcabang.dart';

class CabangPage extends StatefulWidget {
  final Widget? child;
  const CabangPage({Key? key, this.child}) : super(key: key);

  @override
  _CabangPageState createState() => _CabangPageState();
}

class _CabangPageState extends State<CabangPage> {
  Future<List<Cabang>>? cabanglist;
  List<Cabang> kategorilist = [];
  int idcabang = 0;
  String namacabang = "";
  String alamatcabang = "";
  String kotacabang = "";
  String propinsicabang = "";
  String kodeposcabang = "";
  String telpcabang = "";
  String emailcabang = "";
  double ukuranfont = 14.0;
  int li = 1;

  @override
  void initState() {
    super.initState();
    cabanglist = fetchCabang();
  }

  Future<List<Cabang>> fetchCabang() async {
    List<Cabang> usersList = [];
    var params = "/cabang";
    var sUrl = Uri.parse(Palette.sUrl + params);
    try {
      var jsonResponse = await http.get(sUrl);
      if (jsonResponse.statusCode == 200) {
        final jsonItems =
            json.decode(jsonResponse.body).cast<Map<String, dynamic>>();

        usersList = jsonItems.map<Cabang>((json) {
          return Cabang.fromJson(json);
        }).toList();
      }
      // ignore: empty_catches
    } catch (e) {}
    return usersList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Palette.menuOther,
                width: 1.0,
              ),
            ),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(color: Colors.white, spreadRadius: 1),
            ],
          ),
          child: const Text(
            'CABANG KANTIN',
            style: TextStyle(color: Colors.black),
          ),
        ),
        Expanded(
          child: li == 1 ? _widgetCabang() : _widgetDetail(),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return FormCabangPage();
          }));
        },
        tooltip: 'Tambah',
        // child: new IconTheme(
        // data: new IconThemeData(color: Colors.white),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Palette.bg1,
      ),
      // ),
    );
  }

  _hapusCabang(int id) async {
    var params = "/hapuscabang?id=" + id.toString();
    var sUrl = Uri.parse(Palette.sUrl + params);
    try {
      http.get(sUrl).then((response) {
        var res = response.body.toString();
        if (res == "OK") {
          setState(() {
            li = 1;
            cabanglist = fetchCabang();
          });
        }
      });
    } catch (e) {
      return null;
    }
  }

  Widget _widgetCabang() {
    return FutureBuilder<List<Cabang>>(
      future: cabanglist,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              children: const [
                CircularProgressIndicator(),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, i) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Palette.menuOther,
                    width: 1.0,
                  ),
                ),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.white, spreadRadius: 1),
                ],
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
                leading: const Icon(Icons.store),
                trailing: const Icon(Icons.keyboard_arrow_right),
                title: Text(snapshot.data![i].nama),
                subtitle: Text(
                    snapshot.data![i].alamat + '\n' + snapshot.data![i].telp),
                onTap: () {
                  setState(() {
                    idcabang = snapshot.data![i].id;
                    namacabang = snapshot.data![i].nama;
                    alamatcabang = snapshot.data![i].alamat;
                    kotacabang = snapshot.data![i].kota;
                    propinsicabang = snapshot.data![i].propinsi;
                    kodeposcabang = snapshot.data![i].kodepos;
                    telpcabang = snapshot.data![i].telp;
                    emailcabang = snapshot.data![i].email;
                    li = 2;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _widgetDetail() {
    return Column(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Palette.menuOther,
              width: 1.0,
            ),
          ),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Colors.white, spreadRadius: 1),
          ],
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
          leading: InkWell(
            onTap: () {
              setState(() {
                li = 1;
              });
            },
            child: const Icon(Icons.keyboard_arrow_left),
          ),
          trailing: InkWell(
            onTap: () {
              _hapusCabang(idcabang);
            },
            child: const Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
          title: InkWell(
            onTap: () {},
            child: Text(namacabang),
          ),
        ),
      ),
      Expanded(
        child: Column(children: <Widget>[
          Container(
            color: Colors.white,
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
              leading: const Text(''),
              // ignore: avoid_unnecessary_containers
              title: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ignore: avoid_unnecessary_containers
                    const SizedBox(
                      width: 100.0,
                      child: Text('Nama'),
                    ),
                    Expanded(
                      child: SelectableText(': ' + namacabang),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
              leading: const Text(''),
              // ignore: avoid_unnecessary_containers
              title: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ignore: avoid_unnecessary_containers
                    const SizedBox(
                      width: 100.0,
                      child: Text('Alamat'),
                    ),
                    Expanded(
                      child: SelectableText(': ' + alamatcabang),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
              leading: const Text(''),
              // ignore: avoid_unnecessary_containers
              title: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ignore: avoid_unnecessary_containers
                    const SizedBox(
                      width: 100.0,
                      child: Text('Kota'),
                    ),
                    Expanded(
                      child: SelectableText(': ' + kotacabang),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
              leading: const Text(''),
              // ignore: avoid_unnecessary_containers
              title: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ignore: avoid_unnecessary_containers
                    const SizedBox(
                      width: 100.0,
                      child: Text('Propinsi'),
                    ),
                    Expanded(
                      child: Text(': ' + propinsicabang),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
              leading: const Text(''),
              // ignore: avoid_unnecessary_containers
              title: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ignore: avoid_unnecessary_containers
                    const SizedBox(
                      width: 100.0,
                      child: Text('Telp'),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SelectableText(': ' + telpcabang + ' '),
                          InkWell(
                            onTap: () {
                              launch('tel://' + telpcabang);
                            },
                            child: const Icon(Icons.phone),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
              leading: const Text(''),
              // ignore: avoid_unnecessary_containers
              title: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ignore: avoid_unnecessary_containers
                    const SizedBox(
                      width: 100.0,
                      child: Text('Email'),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SelectableText(': ' + emailcabang + ' '),
                          InkWell(
                            onTap: () {
                              launch('mailto:' + emailcabang);
                            },
                            child: const Icon(Icons.email),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }
}
