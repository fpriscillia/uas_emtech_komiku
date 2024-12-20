import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class KomikSaya extends StatefulWidget {
  const KomikSaya({super.key});

  @override
  State<StatefulWidget> createState() {
    return _KomikSayaState();
  }
}

class _KomikSayaState extends State<KomikSaya> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Komik Saya"),
      ),
      body: Text("daftar komik yg ditulis user, ada button Tambah Komik"),
    );
  }
}