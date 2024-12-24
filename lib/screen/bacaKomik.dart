import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uas_emtech_comic/class/content.dart';
import 'package:http/http.dart' as http;

class Baca extends StatefulWidget {
  final int comicId;
  final String comicTitle;

  const Baca({Key? key, required this.comicId, required this.comicTitle}) : super(key: key);

  @override
  State<Baca> createState() => _BacaState();
}

class _BacaState extends State<Baca> {
  late Future<List<Content>> _comicPages;

  @override
  void initState() {
    _comicPages = getContentList(widget.comicId);
  }

  Future<List<Content>> getContentList(int comicId) async {
    final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/content.php"),
        body: {'comic_id': widget.comicId.toString()});

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['result'] == 'success') {
        return (jsonData['data'] as List)
            .map((item) => Content.fromJson(item))
            .toList();
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      throw Exception('Failed to load comic pages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comicTitle),
      ),
      body: FutureBuilder<List<Content>>(
        future: _comicPages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pages found'));
          } else {
            final pages = snapshot.data!;
            return ListView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(page.gambar!.split(',').last),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
