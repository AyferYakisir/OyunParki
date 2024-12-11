import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class SekillerleOgrenme extends StatefulWidget {
  @override
  _SekillerleOgrenmeState createState() => _SekillerleOgrenmeState();
}

class _SekillerleOgrenmeState extends State<SekillerleOgrenme> {
  FlutterTts flutterTts = FlutterTts();
  AudioPlayer audioPlayer = AudioPlayer();
  int seviye = 1;
  String hedefRenk = 'Kırmızı';
  String hedefSekil = 'Daire';
  bool kutlamaAnimasyonu = false;
  bool hataAnimasyonu = false;

  List<List<Map<String, dynamic>>> asamaNesneler = [
    [
      {'renk': Colors.red, 'sekil': 'Daire'},
      {'renk': Colors.blue, 'sekil': 'Kare'},
      {'renk': Colors.green, 'sekil': 'Daire'},
      {'renk': Colors.yellow, 'sekil': 'Kare'},
    ],
    [
      {'renk': Colors.blue, 'sekil': 'Daire'},
      {'renk': Colors.green, 'sekil': 'Üçgen'},
      {'renk': Colors.purple, 'sekil': 'Kare'},
      {'renk': Colors.orange, 'sekil': 'Daire'},
    ],
    [
      {'renk': Colors.yellow, 'sekil': 'Kare'},
      {'renk': Colors.red, 'sekil': 'Üçgen'},
      {'renk': Colors.green, 'sekil': 'Daire'},
      {'renk': Colors.blue, 'sekil': 'Kare'},
    ],
    [
      {'renk': Colors.pink, 'sekil': 'Daire'},
      {'renk': Colors.brown, 'sekil': 'Üçgen'},
      {'renk': Colors.cyan, 'sekil': 'Kare'},
      {'renk': Colors.lime, 'sekil': 'Daire'},
    ],
    [
      {'renk': Colors.indigo, 'sekil': 'Daire'},
      {'renk': Colors.amber, 'sekil': 'Üçgen'},
      {'renk': Colors.yellow, 'sekil': 'Kare'},
      {'renk': Colors.deepOrange, 'sekil': 'Kare'},
    ]
  ];

  List<Map<String, String>> gorevler = [
    {'renk': 'Kırmızı', 'sekil': 'Daire'},
    {'renk': 'Yeşil', 'sekil': 'Üçgen'},
    {'renk': 'Mavi', 'sekil': 'Kare'},
    {'renk': 'Pembe', 'sekil': 'Daire'},
    {'renk': 'Sarı', 'sekil': 'Kare'}
  ];

  @override
  void initState() {
    super.initState();
    _sesliGorev();
  }

  Future<void> _sesliGorev() async {
    await flutterTts.speak('Görev: $hedefRenk renkte bir $hedefSekil seçin');
  }

  Color _renkIsmineGoreRenk(String renkAdi) {
    switch (renkAdi) {
      case 'Kırmızı':
        return Colors.red;
      case 'Yeşil':
        return Colors.green;
      case 'Mavi':
        return Colors.blue;
      case 'Pembe':
        return Colors.pink;
      case 'Sarı':
        return Colors.yellow;
      default:
        return Colors.black;
    }
  }

  void _nesneyiSec(String secilenSekil, Color secilenRenk) {
    if (secilenSekil == hedefSekil &&
        secilenRenk == _renkIsmineGoreRenk(hedefRenk)) {
      _gosterGeriBildirim(true);
    } else {
      _gosterGeriBildirim(false);
    }
  }

  void _gosterGeriBildirim(bool dogruMu) {
    if (dogruMu) {
      setState(() {
        kutlamaAnimasyonu = true;
      });
      audioPlayer.play(AssetSource('sounds/alkis.mp3')); // Alkış sesi
    } else {
      setState(() {
        hataAnimasyonu = true;
      });
      audioPlayer.play(AssetSource('assets/sounds/hata.mp3')); // Hata sesi
    }

    Future.delayed(Duration(seconds: 2), () {
      if (dogruMu) {
        _sonrakiSeviye();
      } else {
        setState(() {
          hataAnimasyonu = false; // Hata animasyonunu kaldır
        });
      }
    });
  }

  void _sonrakiSeviye() async {
    if (seviye < 5) {
      setState(() {
        seviye++;
        hedefRenk = gorevler[seviye - 1]['renk']!;
        hedefSekil = gorevler[seviye - 1]['sekil']!;
        kutlamaAnimasyonu = false; // Kutlama animasyonunu kaldır
      });
      await _sesliGorev();
    } else {
      await flutterTts.speak(
          'Tebrikler! Tüm görevleri başarıyla tamamladınız! Oyun bitti.');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Köşe yuvarlama
          ),
          backgroundColor: Colors.deepPurple.shade50, // Arka plan rengi
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Tebrikler!',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Tüm görevleri başarıyla tamamladınız! Oyun bitti.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Buton rengi
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Buton köşe yuvarlama
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 12.0),
                  child: Text(
                    'Tamam',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 137, 227, 230),
              const Color.fromARGB(255, 117, 223, 137)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: Stack(
                children: [
                  Text(
                    'Görev: $hedefRenk renkte bir $hedefSekil seçin',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Center(
                    // Öğeleri ekranın ortasına yerleştiren widget
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: asamaNesneler[seviye - 1].map((nesne) {
                        return GestureDetector(
                          onTap: () =>
                              _nesneyiSec(nesne['sekil'], nesne['renk']),
                          child: Card(
                            color: const Color.fromARGB(255, 187, 227, 232)
                                .withOpacity(0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: Container(
                              width: 120, // Kart genişliği
                              height: 120, // Kart yüksekliği
                              child: Center(
                                child: nesne['sekil'] == 'Daire'
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: nesne['renk'],
                                          shape: BoxShape.circle,
                                        ),
                                        width: 100,
                                        height: 100,
                                      )
                                    : nesne['sekil'] == 'Kare'
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: nesne['renk'],
                                              shape: BoxShape.rectangle,
                                            ),
                                            width: 100,
                                            height: 100,
                                          )
                                        : CustomPaint(
                                            size: Size(100, 100),
                                            painter: TrianglePainter(
                                                color: nesne['renk']),
                                          ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Kutlama ve Hata Animasyonları
                  if (kutlamaAnimasyonu)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Doğru!',
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  if (hataAnimasyonu)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Yanlış!',
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
