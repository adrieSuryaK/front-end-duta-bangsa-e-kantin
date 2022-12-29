import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constans.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helper/dbhelper.dart';
import 'package:sqflite/sqflite.dart';
import '../login.dart';
import '../models/produk.dart';
import '../models/keranjang.dart';
import 'notifikasipage.dart';
import 'produkdetailpage.dart';

// ignore: use_key_in_widget_constructors
class Favorite extends StatefulWidget {
  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  DbHelper dbHelper = DbHelper();
  bool login = false;
  String userid = "";
  List<Produk> produklist = [];
  List<Keranjang> keranjanglist = [];
  int jmlnotif = 0;

  @override
  void initState() {
    super.initState();
    getkeranjang();
    cekLogin();
  }

  Future<List<Keranjang>> getkeranjang() async {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<Keranjang>> listFuture = dbHelper.getkeranjang();
      listFuture.then((_keranjanglist) {
        if (mounted) {
          setState(() {
            keranjanglist = _keranjanglist;
          });
        }
      });
    });
    return keranjanglist;
  }

  cekLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      login = prefs.getBool('login') ?? false;
      userid = prefs.getString('username') ?? "";
    });
    fetchProdukFav();
    _cekSt();
  }

  _cekSt() async {
    if (userid == "") {
    } else {
      var params = "/cekstbyuserid?userid=" + userid;
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
  }

  _removeFav(String idproduk) async {
    var params = "/removefavorite?userid=" + userid + "&idproduk=" + idproduk;
    var sUrl = Uri.parse(Palette.sUrl + params);
    try {
      http.get(sUrl).then((response) {
        var res = response.body.toString();
        if (res == "OK") {
          fetchProdukFav();
        }
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<List<Produk>> fetchProdukFav() async {
    List<Produk> usersList = [];
    var params = "/produkfavorite?userid=" + userid;
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
      // ignore: empty_catches
    } catch (e) {}
    return usersList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          Row(
            children: [
              Padding(
                  padding: login == false
                      ? const EdgeInsets.only(right: 15.0)
                      : const EdgeInsets.only(right: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/keranjangusers', (Route<dynamic> route) => false);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            size: 28.0,
                          ),
                          Positioned(
                            top: 2,
                            right: 4,
                            child: keranjanglist.isNotEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      keranjanglist.length.toString(),
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
              login == false
                  ? const Text('')
                  : Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) {
                            return const NotifikasiPage();
                          }));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 5),
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
          ),
        ],
        actionsIconTheme:
            const IconThemeData(size: 26.0, color: Colors.white, opacity: 10.0),
        backgroundColor: Palette.bg1,
      ),
      body: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 1)),
        builder: (c, s) => s.connectionState == ConnectionState.done
            ? login
                ? _favorite()
                : _belumlogin()
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  saveKeranjang(Keranjang _keranjang) async {
    Database db = await dbHelper.database;
    var batch = db.batch();
    db.execute(
        'insert into keranjang(idproduk,judul,harga,hargax,thumbnail,jumlah,userid,idcabang) values(?,?,?,?,?,?,?,?)',
        [
          _keranjang.idproduk,
          _keranjang.judul,
          _keranjang.harga,
          _keranjang.hargax,
          _keranjang.thumbnail,
          _keranjang.jumlah,
          _keranjang.userid,
          _keranjang.idcabang
        ]);
    batch.commit();
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/keranjangusers', (Route<dynamic> route) => false);
  }

  Widget _favorite() {
    return GridView(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
      ),
      children: produklist.map((e) {
        return Card(
          margin: const EdgeInsets.all(10),
          // ignore: avoid_unnecessary_containers
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return ProdukDetailPage(e.id, e.judul, e.harga, e.hargax,
                          e.deskripsi, e.thumbnail, false);
                    }));
                  },
                  // ignore: avoid_unnecessary_containers
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Image.network(Palette.sUrl + e.thumbnail),
                            GestureDetector(
                              onTap: () {
                                _removeFav(e.id.toString());
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 5.0, right: 5.0),
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Palette.menuOther,
                                        width: 1.0,
                                      ),
                                    ),
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.white, spreadRadius: 1),
                                    ],
                                  ),
                                  child: const Icon(Icons.favorite,
                                      color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(e.judul),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Text(e.harga),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) {
                        return ProdukDetailPage(e.id, e.judul, e.harga,
                            e.hargax, e.deskripsi, e.thumbnail, false);
                      }));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 5.0, right: 5.0, bottom: 5.0),
                      height: 40.0,
                      child: const Center(
                        child: Text('Pilih',
                            style: TextStyle(color: Colors.white)),
                      ),
                      decoration: BoxDecoration(
                        color: Palette.bg2,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(color: Colors.blue, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //Image.network(Palette.sUrl + e.thumbnail),
        );
      }).toList(),
    );
  }

  Widget _belumlogin() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Container(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Segera login agar kamu bisa menandai berbagai macam barang favoritmu',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          width: double.infinity,
                          height: 40.0,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 60.0,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return const Login('');
                              }));
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Palette.bg1,
                                textStyle: const TextStyle(fontSize: 14)),
                            child: const Text('LOGIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
