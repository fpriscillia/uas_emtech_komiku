import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_emtech_comic/screen/kategori.dart';
import 'package:uas_emtech_comic/screen/komiksaya.dart';
import 'package:uas_emtech_comic/screen/login.dart';

String active_user = "";
Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String user_id = prefs.getString("user_id") ?? '';
  return user_id;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '')
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
      home: const MyHomePage(title: 'Komiku'),
      routes: {
        'komiksaya': (context) => const KomikSaya(),
        'kategori': (context) => const Kategori(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              labelText: 'Cari Judul...',
            ),
            onFieldSubmitted: (value) {
              // _txtcari = value;
              // bacaData();
            },
          ),
          Container(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (BuildContext ctxt, int index) {
                return GestureDetector(
                    onTap: () {},
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.deepPurple[100],
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              "https://kbob.github.io/images/sample-5.jpg",
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          ListTile(
                            title: Text("Judul Komik",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                "Deskripsi komik panjang sekali ini bisa sampai dua atau tiga baris loh ya."),
                          ),
                        ],
                      ),
                    ));
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
              accountName: Text("user_name"),
              accountEmail: Text("user_id"),
              currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150")),
            ),
            ListTile(
              title: const Text("Komik Saya"),
              leading: const Icon(Icons.book),
              onTap: () {
                Navigator.popAndPushNamed(context, "komiksaya");
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
