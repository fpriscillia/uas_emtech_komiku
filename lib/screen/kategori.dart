import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_emtech_comic/class/kategoriKomik.dart';

class Kategori extends StatefulWidget {
  const Kategori({super.key});

  @override
  State<StatefulWidget> createState() {
    return _KategoriState();
  }
}

class _KategoriState extends State<Kategori> {
  List<KategoriKomik> listKategori = [];

  Future<String> fetchData() async {
    final response = await http.get(Uri.parse(
        "https://ubaya.xyz/flutter/160721022/uas_komiku/categorylist.php"));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    Future<String> data = fetchData();
    data.then((value) {
      Map json = jsonDecode(value);
      for (var kategori in json['data']) {
        KategoriKomik k = KategoriKomik.fromJson(kategori);
        listKategori.add(k);
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    bacaData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Kategori Komik"),
      ),
      body: ListView.builder(
          itemCount: listKategori.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return ListTile(
              shape: Border(
                bottom: BorderSide(color: Colors.black12, width: 1.0),
              ),
              title: Text(listKategori[index].category_name),
              onTap: () {},
            );
          }),
    );
  }
}
