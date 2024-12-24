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
  List<Content> _comicPages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    getContentList(widget.comicId);
  }

  Future<void> getContentList(int comicId) async {
    try {
      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/content.php"),
        body: {'comic_id': comicId.toString()},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['result'] == 'success') {
          setState(() {
            _comicPages = (jsonData['data'] as List).map((item) => Content.fromJson(item)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = jsonData['message'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load comic pages');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comicTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : ListView.builder(
                  itemCount: _comicPages.length,
                  itemBuilder: (context, index) {
                    final page = _comicPages[index];
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
                ),
    );
  }
}
