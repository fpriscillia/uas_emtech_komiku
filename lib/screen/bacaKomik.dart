import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_emtech_comic/class/comic.dart';
import 'package:uas_emtech_comic/class/content.dart';
import 'package:http/http.dart' as http;
import 'package:uas_emtech_comic/screen/komentarKomik.dart';

class Baca extends StatefulWidget {
  final Comic comic;

  const Baca({Key? key, required this.comic}) : super(key: key);

  @override
  State<Baca> createState() => _BacaState();
}

class _BacaState extends State<Baca> {
  List<Content> _comicPages = [];
  bool _isLoading = true;
  String? _errorMessage;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.comic.rating!;
    getContentList(widget.comic.id);
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
            _comicPages = (jsonData['data'] as List)
                .map((item) => Content.fromJson(item))
                .toList();
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

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double tempRating = 5;
        return AlertDialog(
          title: Text("Berikan Penilaian"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Seberapa kamu menyukai komik ini?"),
              SizedBox(height: 10),
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  tempRating = rating;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _submitRating(tempRating);
                });
                Navigator.pop(context);
              },
              child: Text("Kirim"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRating(double rating) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/rating.php"),
        body: {
          'comic_id': widget.comic.id.toString(),
          'reader_id': prefs.getString('user_id'),
          'rate': rating.toString(),
        },
      );
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating berhasil dikirimkan!')),
        );
        setState(() {
          _rating = double.parse(jsonResponse['new_rating'].toString());
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
        title: Text(widget.comic.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : ListView(
                  children: [
                    Image.memory(
                      base64Decode(widget.comic.gambar!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber),
                          Text(_rating.toString()),
                          SizedBox(width: 16),
                          IconButton(
                              iconSize: 20,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KomentarKomik(
                                      comicId: widget.comic.id,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.comment_rounded)),
                          SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () {
                              _showRatingDialog();
                            },
                            child: Text("Beri Nilai"),
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(100, 10),
                                padding: EdgeInsets.all(0)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.comic.description!,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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
                  ],
                ),
    );
  }
}
