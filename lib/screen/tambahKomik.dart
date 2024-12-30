import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_emtech_comic/class/kategoriKomik.dart';

class TambahKomik extends StatefulWidget {
  const TambahKomik({Key? key}) : super(key: key);

  @override
  State<TambahKomik> createState() => _TambahKomikState();
}

class _TambahKomikState extends State<TambahKomik> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _tanggalRilisController = TextEditingController();
  final TextEditingController _pengarangController = TextEditingController();

  String? _selectedKategori;
  File? _selectedImage;
  final List<File> _selectedContent = [];

  List<KategoriKomik> listKategori = [];

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

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
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  Future<void> _pickContent() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedContent.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih gambar untuk poster komik')),
      );
      return;
    }

    if (_selectedContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih konten untuk komik')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();

      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/addcomic.php"),
        body: {
          'title': _judulController.text,
          'description': _deskripsiController.text,
          'release_date': _tanggalRilisController.text,
          'author_name': _pengarangController.text,
          'author_id': prefs.getString('user_id'),
          'category_id': _selectedKategori,
          'rating': "0",
          'gambar': base64Image,
        },
      );

      final jsonResponse = json.decode(response.body);

      if (jsonResponse['result'] == 'success') {
        // ID komik yang baru ditambahkan
        final comicId = jsonResponse['id'];

        // Kirim setiap konten yang dipilih ke server
        for (var content in _selectedContent) {
          final contentBytes = await content.readAsBytes();
          final contentBase64Image = base64Encode(contentBytes);

          final contentResponse = await http.post(
            Uri.parse("https://ubaya.xyz/flutter/160721022/uas_komiku/addcontent.php"),
            body: {
              'comic_id': comicId.toString(),
              'gambar': contentBase64Image,
            },
          );

          final contentJsonResponse = json.decode(contentResponse.body);

          if (contentJsonResponse['result'] != 'success') {
            throw Exception('Gagal menginput konten: ${contentJsonResponse['message']}');
          }
        }

        // Jika semua proses berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komik dan konten berhasil ditambahkan!')),
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
  void initState() {
    bacaKategori();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Komik'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                decoration: const InputDecoration(labelText: 'Deskripsi Komik'),
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
                decoration: const InputDecoration(
                  labelText: 'Tanggal Rilis (YYYY-MM-DD)',
                  suffixIcon: Icon(Icons.calendar_today), // Ikon kalender
                ),
                readOnly: true, // Mencegah input manual
                onTap: () async {
                  // Tampilkan DatePicker saat pengguna mengetuk TextFormField
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(), // Tanggal awal
                    firstDate: DateTime(2000), // Tanggal awal yang bisa dipilih
                    lastDate: DateTime(2100), // Tanggal akhir yang bisa dipilih
                  );

                  if (pickedDate != null) {
                    setState(() {
                      // Format tanggal yang dipilih menjadi 'YYYY-MM-DD'
                      _tanggalRilisController.text = pickedDate.toIso8601String().split('T').first;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal rilis tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pengarangController,
                decoration: const InputDecoration(labelText: 'Nama Pengarang'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama pengarang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: const InputDecoration(labelText: 'Kategori Komik'),
                items: listKategori.map((e) {
                  return DropdownMenuItem(
                    value: e.id.toString(),
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
              const SizedBox(height: 16.0),
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
                  child: _selectedImage == null
                      ? const Center(child: Text('Klik untuk memilih COVER'))
                      : Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
              Text('Konten'),
              GestureDetector(
                onTap: _pickContent,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedContent.isEmpty
                      ? const Center(child: Text('Klik untuk memilih KONTEN'))
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedContent.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                          _selectedContent[index],
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  child: const Text('Tambah Komik'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
