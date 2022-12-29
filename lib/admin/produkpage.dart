import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../constans.dart';
import '../models/kategori.dart';
import '../models/produk.dart';
import '../helper/dbhelper.dart';
import 'formprodukpage.dart';
import 'produkdetailpage.dart';

// ignore: use_key_in_widget_constructors
class ProdukPage extends StatefulWidget {
  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  DbHelper dbHelper = DbHelper();
  List<Kategori> kategorilist = [];
  List<Produk> produklist = [];
  final picker = ImagePicker();
  int jmlnotif = 0;

  @override
  void initState() {
    super.initState();
    fetchKategori();
    _cekStAll();
  }

  _cekStAll() async {
    var params = "/cekst";
    var sUrl = Uri.parse(Palette.sUrl + params);
    try {
      http.get(sUrl).then((response) {
        var res = response.body.toString().split("|");
        if (res[0] == "OK") {
          if (mounted) {
            setState(() {
              jmlnotif = int.parse(res[1]);
            });
          }
        }
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();
    kategorilist = [];
  }

  Future<List<Kategori>> fetchKategori() async {
    List<Kategori> usersList = [];
    var params = "/kategoribyproduk";
    var sUrl = Uri.parse(Palette.sUrl + params);
    try {
      var jsonResponse = await http.get(sUrl);
      if (jsonResponse.statusCode == 200) {
        final jsonItems =
            json.decode(jsonResponse.body).cast<Map<String, dynamic>>();

        usersList = jsonItems.map<Kategori>((json) {
          return Kategori.fromJson(json);
        }).toList();

        setState(() {
          kategorilist = usersList;
        });
      }
    } catch (e) {
      getkategori();
      usersList = kategorilist;
    }
    return usersList;
  }

  void deletekategori() async {
    await dbHelper.deletekategori();
  }

  getkategori() async {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<Kategori>> listFuture = dbHelper.getkategori();
      listFuture.then((_kategorilist) {
        if (mounted) {
          setState(() {
            kategorilist = _kategorilist;
          });
        }
      });
    });
  }

  Future _refresh() {
    return fetchKategori().then((_kategori) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/transaksiadmin', (Route<dynamic> route) => false);
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Stack(
                    children: [
                      const Icon(
                        Icons.notifications,
                        size: 28.0,
                      ),
                      Positioned(
                        top: 2,
                        right: 4,
                        child: jmlnotif > 0
                            ? Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  jmlnotif.toString(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const Text(''),
                      ),
                    ],
                  ),
                ),
              )),
        ],
        actionsIconTheme:
            const IconThemeData(size: 26.0, color: Colors.white, opacity: 10.0),
        backgroundColor: Palette.bg1,
      ),
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Stack(children: <Widget>[
          SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  produkbyKategori(),
                ]),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return const FormProdukPage();
          }));
        },
        //   tooltip: 'Tambah',
        //   child: const Icon(Icons.add),
        // ),
        tooltip: 'Tambah',
        // child: new IconTheme(
        // data: new IconThemeData(color: Colors.white),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Palette.bg1,
      ),
    );
  }

  Widget produkbyKategori() {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < kategorilist.length; i++)
            WidgetbyKategori(
                kategorilist[i].id, kategorilist[i].nama.toString(), i),
        ],
      ),
    );
  }
}

class WidgetbyKategori extends StatefulWidget {
  final Widget? child;
  final int id;
  final String kategori;
  final int warna;

  const WidgetbyKategori(this.id, this.kategori, this.warna,
      {Key? key, this.child})
      : super(key: key);

  @override
  _WidgetbyKategoriState createState() => _WidgetbyKategoriState();
}

class _WidgetbyKategoriState extends State<WidgetbyKategori> {
  DbHelper dbHelper = DbHelper();
  List<Produk> produklist = [];

  Future<List<Produk>> fetchProduk(String id) async {
    List<Produk> usersList = [];
    var params = "/produkbykategoriall?id=" + id;
    var sUrl = Uri.parse(Palette.sUrl + params);

    try {
      var jsonResponse = await http.get(sUrl);
      if (jsonResponse.statusCode == 200) {
        final jsonItems =
            json.decode(jsonResponse.body).cast<Map<String, dynamic>>();

        usersList = jsonItems.map<Produk>((json) {
          return Produk.fromJson(json);
        }).toList();

        setState(() {
          produklist = usersList;
        });
      }
    } catch (e) {
      getproduk(int.parse(id));
      usersList = produklist;
    }
    return usersList;
  }

  void deleteproduk(int id) async {
    await dbHelper.deleteproduk(id);
  }

  getproduk(int id) async {}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.only(right: 10.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Text(
                    widget.kategori,
                    style: const TextStyle(color: Colors.white),
                  ),
                  width: 200.0,
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0)),
                    color: Palette.colors[widget.warna],
                    boxShadow: [
                      BoxShadow(
                          color: Palette.colors[widget.warna], spreadRadius: 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder<List<Produk>>(
            future: fetchProduk(widget.id.toString()),
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

              return GridView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                ),
                children: snapshot.data!.map((e) {
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) {
                          return ProdukDetailPage(e.id, e.judul, e.harga,
                              e.hargax, e.deskripsi, e.thumbnail);
                        }));
                      },
                      // ignore: avoid_unnecessary_containers
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            // ignore: avoid_unnecessary_containers
                            Container(
                              child: AspectRatio(
                                aspectRatio: 1 / 1,
                                child: Image.network(Palette.sUrl + e.thumbnail,
                                    fit: BoxFit.fill),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(e.judul),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: Text(e.harga),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
