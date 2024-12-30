import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_emtech_comic/class/kategoriKomik.dart';
import 'package:uas_emtech_comic/class/komentar.dart';

class KomentarKomik extends StatefulWidget {
  final int comicId;

  const KomentarKomik({Key? key, required this.comicId}) : super(key: key);

  @override
  State<KomentarKomik> createState() => _UpdateComicState();
}

class _UpdateComicState extends State<KomentarKomik> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<Komentar>> listKomentar;
  final _komentarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    listKomentar = _loadComments();
  }

  Future<List<Komentar>> _loadComments() async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://ubaya.xyz/flutter/160721022/uas_komiku/commentlist.php"),
        body: {'id': widget.comicId.toString()},
      );
      if (response.statusCode == 200) {
        Map json = jsonDecode(response.body);
        if (json['result'] == 'success' && json['data'] != null) {
          return (json['data'] as List)
              .map((json) => Komentar.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to read API');
      }
    } catch (e) {
      throw Exception("Error fetching comments: $e");
    }
  }

  Future<void> _addComment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(
            "https://ubaya.xyz/flutter/160721022/uas_komiku/addcomment.php"),
        body: {
          'comic_id': widget.comicId.toString(),
          'reader_id': prefs.getString('user_id'),
          'comment': _komentarController.text,
        },
      );

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komentar berhasil ditambahkan!')),
        );
        setState(() {
          listKomentar = _loadComments();
          _komentarController.clear();
        });
      } else {
        throw Exception(jsonResponse['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komentar Komik'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _komentarController,
              decoration: const InputDecoration(labelText: 'Beri Komentar'),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Komentar tidak boleh kosong';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                _addComment();
              },
              child: const Text('Kirim Komentar'),
            ),
          ),
          SizedBox(height: 8),
          Center(
              child: Text("Komentar Pembaca",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          SizedBox(height: 8),
          Container(
            height: MediaQuery.of(context).size.height - 200,
            child: FutureBuilder<List<Komentar>>(
              future: listKomentar,
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
                  return const Center(child: Text("Belum ada komentar"));
                }
                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    final comment = comments[index];
                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      // color: Colors.deepPurple[100],
                      child: ListTile(
                        title: Text(
                          comment.reader_name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          comment.comment,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    );
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
