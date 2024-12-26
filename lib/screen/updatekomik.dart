import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateKomic extends StatefulWidget {
  final int comicId;

  const UpdateKomic({Key? key, required this.comicId}) : super(key: key);

  @override
  State<UpdateKomic> createState() => _UpdateComicState();
}

class _UpdateComicState extends State<UpdateKomic> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tanggalRilisController = TextEditingController();
  final _pengarangController = TextEditingController();
  String? _selectedKategori;
  File? _selectedPoster;
  List<File> _selectedContents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComicData();
  }

  Future<void> _loadComicData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/getcomic.php"),
        body: {'comic_id': widget.comicId.toString()},
      );

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['result'] == 'success') {
        final data = jsonResponse['data'];
        setState(() {
          _judulController.text = data['title'];
          _deskripsiController.text = data['description'];
          _tanggalRilisController.text = data['release_date'];
          _pengarangController.text = data['author_name'];
          _selectedKategori = data['category_id'];
          // Poster & contents should be displayed as a preview
        });
      } else {
        throw Exception(jsonResponse['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateComic() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final posterBytes = _selectedPoster != null ? await _selectedPoster!.readAsBytes() : null;
      final posterBase64 = posterBytes != null ? base64Encode(posterBytes) : null;

      // Update Comic Data
      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/updatecomic.php"),
        body: {
          'comic_id': widget.comicId.toString(),
          'title': _judulController.text,
          'description': _deskripsiController.text,
          'release_date': _tanggalRilisController.text,
          'author_name': _pengarangController.text,
          'author_id': prefs.getString('user_id'),
          'category_id': _selectedKategori,
          'poster': posterBase64,
        },
      );

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['result'] == 'success') {
        // Update Content Images
        for (var content in _selectedContents) {
          final contentBytes = await content.readAsBytes();
          final contentBase64 = base64Encode(contentBytes);

          final contentResponse = await http.post(
            Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/updatecontent.php"),
            body: {
              'comic_id': widget.comicId.toString(),
              'gambar': contentBase64,
            },
          );

          final contentJsonResponse = json.decode(contentResponse.body);
          if (contentJsonResponse['result'] != 'success') {
            throw Exception('Error updating content: ${contentJsonResponse['message']}');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komik berhasil diperbarui!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception(jsonResponse['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Komik'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul Komik'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tanggalRilisController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Rilis',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _tanggalRilisController.text = date.toIso8601String().split('T').first;
                  }
                },
              ),
              // Add more fields for category, author, poster, and content images
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateComic,
                child: const Text('Update Komik'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
