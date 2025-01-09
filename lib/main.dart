import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_emtech_comic/class/comic.dart';
import 'package:uas_emtech_comic/screen/bacaKomik.dart';
import 'package:uas_emtech_comic/screen/kategori.dart';
import 'package:uas_emtech_comic/screen/komiksaya.dart';
import 'package:uas_emtech_comic/screen/login.dart';
import 'package:http/http.dart' as http;
import 'package:uas_emtech_comic/screen/tambahKomik.dart';
import 'package:uas_emtech_comic/screen/updatekomik.dart';

String active_user = "";
Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String user_id = prefs.getString("user_id") ?? '';
  String user_name = prefs.getString("user_name") ?? '';
  return "$user_id//$user_name";
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '//')
      runApp(MyLogin());
    else {
      active_user = result;
      runApp(MyApp());
    }
  });
}

void doLogout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove("user_id");
  prefs.remove("user_name");
  main();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Komiku App'),
      routes: {
        'komiksaya': (context) => const KomikSaya(),
        'kategori': (context) => const Kategori(),
        'tambah': (context) => const TambahKomik(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.idCategory});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final int? idCategory;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Comic>> _comics;
  String _txtcari = "";

  @override
  void initState() {
    super.initState();
    _comics = getComic();
  }

  Future<List<Comic>> getComic() async {
    try {
      int? idcategory = widget.idCategory;
      final response = await http.post(
        Uri.parse(
            "https://ubaya.xyz/flutter/160721022/uas_komiku/comiclist.php"),
        body: idcategory == null
            ? {'cari': _txtcari}
            : {'cari': _txtcari, 'category_id': idcategory.toString()},
      );
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        if (json['result'] == 'success' && json['data'] != null) {
          return (json['data'] as List)
              .map((json) => Comic.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to read API');
      }
    } catch (e) {
      throw Exception("Error fetching comics: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          if (widget.idCategory == null)
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.search),
                labelText: 'Cari Judul...',
              ),
              onFieldSubmitted: (value) {
                setState(() {
                  _txtcari = value;
                  _comics = getComic();
                });
              },
            ),
          Container(
            height: MediaQuery.of(context).size.height - 100,
            child: FutureBuilder<List<Comic>>(
              future: _comics,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Jika terjadi error
                else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                // Jika data kosong
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Belum ada komik"));
                }
                final comics = snapshot.data!;
                return ListView.builder(
                  itemCount: comics.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    final comic = comics[index];
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Baca(comic: comic),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.deepPurple[100],
                          child: Column(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  child: Image.memory(
                                    base64Decode(comic
                                        .gambar!), // Decode base64 menjadi gambar
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )),
                              ListTile(
                                title: Text(comic.title,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  comic.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                );
              },
            ),
          )
        ],
      ),
      drawer: Drawer(
        elevation: 16.0,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(active_user.split('//')[1]),
              accountEmail: Text(active_user.split('//')[0]),
              currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150")),
            ),
            ListTile(
              title: const Text("Komik Saya"),
              leading: const Icon(Icons.book),
              onTap: () async {
                final result = Navigator.popAndPushNamed(context, "komiksaya");
                if (result != null) {
                  setState(() {
                    _comics = getComic();
                  });
                }
              },
            ),
            ListTile(
              title: const Text("Kategori Komik"),
              leading: const Icon(Icons.list),
              onTap: () {
                Navigator.popAndPushNamed(context, "kategori");
              },
            ),
            ListTile(
              title: const Text("Tambah Komik"),
              leading: const Icon(Icons.add_sharp),
              onTap: () async {
                final result = Navigator.popAndPushNamed(context, "tambah");
                if (result != null) {
                  setState(() {
                    _comics = getComic();
                  });
                }
              },
            ),
            ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout_outlined),
              onTap: () {
                doLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
