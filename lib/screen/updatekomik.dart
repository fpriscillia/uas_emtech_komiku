import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_emtech_comic/class/kategoriKomik.dart';

class UpdateKomik extends StatefulWidget {
  final int comicId;

  const UpdateKomik({Key? key, required this.comicId}) : super(key: key);

  @override
  State<UpdateKomik> createState() => _UpdateComicState();
}

class _UpdateComicState extends State<UpdateKomik> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tanggalRilisController = TextEditingController();
  final _pengarangController = TextEditingController();
  int? _selectedKategori;
  File? _selectedPoster;
  String? _initialPoster;
  List<File> _selectedContents = [];
  bool _isLoading = false;
  List<KategoriKomik> listKategori = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadComicData();
    bacaKategori();
  }

  Future<void> _loadComicData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            "https://ubaya.xyz/flutter/160721022/uas_komiku/detailcomic.php"),
        body: {'id': widget.comicId.toString()},
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
          _initialPoster = data['gambar'].split(',')[1];
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

  Future<String> fetchKategori() async {
    final response = await http.get(Uri.parse(
        "https://ubaya.xyz/flutter/160721022/uas_komiku/categorylist.php"));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaKategori() {
    Future<String> data = fetchKategori();
    data.then((value) {
      Map json = jsonDecode(value);
      for (var kategori in json['data']) {
        KategoriKomik k = KategoriKomik.fromJson(kategori);
        listKategori.add(k);
      }
      setState(() {});
    });
  }

  Future<void> _pickCover() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedPoster = File(pickedFile.path);
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
      final posterBytes =
          _selectedPoster != null ? await _selectedPoster!.readAsBytes() : null;
      final posterBase64 = (posterBytes != null
          ? base64Encode(posterBytes)
          : (_initialPoster != null ? _initialPoster : null));

      final response = await http.post(
        Uri.parse(
            "https://ubaya.xyz/flutter/160721022/uas_komiku/updatecomic.php"),
        body: {
          'comic_id': widget.comicId.toString(),
          'title': _judulController.text,
          'description': _deskripsiController.text,
          'release_date': _tanggalRilisController.text,
          'author_name': _pengarangController.text,
          'category_id': _selectedKategori.toString(),
          'poster': posterBase64,
        },
      );

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['result'] == 'success') {
        // for (var content in _selectedContents) {
        //   final contentBytes = await content.readAsBytes();
        //   final contentBase64 = base64Encode(contentBytes);

        //   final contentResponse = await http.post(
        //     Uri.parse(
        //         "https://ubaya.xyz/flutter/160721022/uas_komiku/updatecontent.php"),
        //     body: {
        //       'comic_id': widget.comicId.toString(),
        //       'gambar': contentBase64,
        //     },
        //   );

        //   final contentJsonResponse = json.decode(contentResponse.body);
        //   if (contentJsonResponse['result'] != 'success') {
        //     throw Exception(
        //         'Error updating content: ${contentJsonResponse['message']}');
        //   }
        // }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komik berhasil diperbarui!')),
        );
        Navigator.pop(context, 'update');
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
                      decoration:
                          const InputDecoration(labelText: 'Judul Komik'),
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
                      maxLines: 3,
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
                          _tanggalRilisController.text =
                              date.toIso8601String().split('T').first;
                        }
                      },
                    ),
                    TextFormField(
                      controller: _pengarangController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Pengarang'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama pengarang tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<int>(
                      value: _selectedKategori,
                      decoration:
                          const InputDecoration(labelText: 'Kategori Komik'),
                      items: listKategori.map((e) {
                        return DropdownMenuItem(
                          value: e.id,
                          child: Text(e.category_name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedKategori = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Kategori harus dipilih';
                        }
                        return null;
                      },
                    ),
                    // Add more fields for category, author, poster, and content images
                    const SizedBox(height: 16),
                    Text('Cover'),
                    GestureDetector(
                      onTap: _pickCover,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _selectedPoster == null
                            ? (_initialPoster == null
                                ? const Center(
                                    child: Text('Klik untuk memilih COVER'))
                                : Image.memory(base64Decode(_initialPoster!),
                                    fit: BoxFit.cover))
                            : Image.file(_selectedPoster!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 20),
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
