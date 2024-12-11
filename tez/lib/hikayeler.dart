import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(HikayeApp());
}

class HikayeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hikaye Uygulaması',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HikayeSecimSayfasi(),
    );
  }
}

class Hikaye {
  final String id;
  final String baslik;
  final String foto_url;
  final String icerik;

  Hikaye({
    required this.id,
    required this.baslik,
    required this.foto_url,
    required this.icerik,
  });

  factory Hikaye.fromJson(Map<String, dynamic> json) {
    return Hikaye(
      id: json['id'],
      baslik: json['baslik'],
      foto_url: json['foto_url'],
      icerik: json['icerik'],
    );
  }
}

class HikayeSecimSayfasi extends StatefulWidget {
  @override
  _HikayeSecimSayfasiState createState() => _HikayeSecimSayfasiState();
}

class _HikayeSecimSayfasiState extends State<HikayeSecimSayfasi> {
  late Future<List<Hikaye>> _hikayeler;

  @override
  void initState() {
    super.initState();
    _hikayeler = fetchHikayeler();
  }

  Future<List<Hikaye>> fetchHikayeler() async {
    final response = await http
        .get(Uri.parse('http://192.168.69.112/oyunApis/gethikayeler.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Hikaye.fromJson(json)).toList();
    } else {
      throw Exception('Hikayeler yüklenemedi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hikaye Seçimi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Hikaye>>(
          future: _hikayeler,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Hata: ${snapshot.error}'));
            } else {
              final hikayeler = snapshot.data!;
              return Swiper(
                itemCount:
                    hikayeler.length.clamp(0, 5), // Maksimum 5 hikaye göster
                itemBuilder: (context, index) {
                  final hikaye = hikayeler[index];
                  return HikayeKart(hikaye: hikaye);
                },
                autoplay: false,
                layout: SwiperLayout.STACK,
                itemWidth: MediaQuery.of(context).size.width * 0.8,
                itemHeight: MediaQuery.of(context).size.height * 0.6,
                pagination: SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                    activeColor: Colors.white,
                    color: Colors.grey,
                  ),
                ),
                control: null,
              );
            }
          },
        ),
      ),
    );
  }
}

class HikayeKart extends StatelessWidget {
  final Hikaye hikaye;

  HikayeKart({required this.hikaye});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HikayeDetaySayfasi(hikaye: hikaye),
          ),
        );
      },
      child: Card(
        elevation: 10,
        shadowColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color.fromARGB(255, 255, 255, 255),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        color: Colors.yellow.shade50,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                hikaye.foto_url,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                hikaye.baslik,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lobster',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HikayeDetaySayfasi extends StatelessWidget {
  final Hikaye hikaye;

  HikayeDetaySayfasi({required this.hikaye});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(hikaye.baslik, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple, width: 4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(
                      hikaye.foto_url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                  child: Text(
                    hikaye.icerik,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
