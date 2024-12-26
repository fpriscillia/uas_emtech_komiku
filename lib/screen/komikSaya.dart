import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_emtech_comic/class/comic.dart';
import 'package:uas_emtech_comic/screen/bacaKomik.dart';
import 'package:uas_emtech_comic/screen/updatekomik.dart';

class KomikSaya extends StatefulWidget {
  const KomikSaya({super.key});

  @override
  State<StatefulWidget> createState() {
    return _KomikSayaState();
  }
}

class _KomikSayaState extends State<KomikSaya> {
  late Future<List<Comic>> _comics;


  @override
  void initState() {
    _comics = getComic();
  }

  Future<List<Comic>>getComic() async {
    try {
      final response = await http.post(
          Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/comiclist.php"));
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        if (json['result'] == 'success' && json['data'] != null) {
          return (json['data'] as List).map((json) => Comic.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to read API');
      }
    }catch(e){
      throw Exception("Error fetching comics: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Komik Saya"),
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
            child: FutureBuilder<List<Comic>>(
              future: _comics,
              builder: (context,snapshot)
              {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Jika terjadi error
                else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                // Jika data kosong
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No comics available"));
                }
                final comics = snapshot.data!;
                return  ListView.builder(
                  itemCount: comics.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    final comic = comics[index];
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateKomic(
                                comicId: comic.id,
                              ),
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
                                  borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Image.memory(
                                    base64Decode(comic.gambar!), // Decode base64 menjadi gambar
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                              ),
                              ListTile(
                                title: Text(comic.title,
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    comic.description!),
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
    );
  }
}