import 'dart:math';
import 'package:flutter/material.dart';

class SaymaOyunu extends StatefulWidget {
  @override
  _SaymaOyunuState createState() => _SaymaOyunuState();
}

class _SaymaOyunuState extends State<SaymaOyunu> with TickerProviderStateMixin {
  List<String> _hayvanlar = ['🐱', '🐶', '🐦', '🐰', '🐢', '🐼', '🐷'];
  List<String> _meyveler = ['🍎', '🍌', '🍉', '🍓', '🍍'];
  List<String> _araclar = ['🚗', '🚲', '🚂', '✈️', '🚢'];

  List<String> _ekrandakiObjeler = [];
  String _sorulanObje = '';
  int _dogruSayi = 0;
  int _puan = 0;
  int _sayac = 0;
  Map<int, Color> _cerceveRenkleri = {};

  // Kategorilerin sırasını kontrol edecek bir liste
  List<List<String>> _kategoriler = [];
  int _kategoriIndex = 0;

  @override
  void initState() {
    super.initState();
    _kategoriler = [
      _hayvanlar,
      _meyveler,
      _araclar,
    ];
    _yeniTur();
  }

  void _yeniTur() {
    final random = Random();

    // Şu anki kategori
    List<String> kategori = _kategoriler[_kategoriIndex];

    // Ekranda görünecek objeyi seç
    _ekrandakiObjeler = List.generate(
      random.nextInt(10) + 5, // 5-14 kadar obje
      (_) => kategori[random.nextInt(kategori.length)],
    );

    // Sorulacak objeyi seç
    _sorulanObje = _ekrandakiObjeler[random.nextInt(_ekrandakiObjeler.length)];
    _dogruSayi = _ekrandakiObjeler.where((obje) => obje == _sorulanObje).length;

    _sayac = 0;
    _cerceveRenkleri.clear();
    _kategoriIndex =
        (_kategoriIndex + 1) % _kategoriler.length; // Kategoriyi değiştir

    setState(() {});
  }

  void _objeyeTikla(String obje, int index) {
    // Puan 100'e ulaştıysa, oyunu bitir
    if (_puan >= 100) {
      _oyunBitti();
      return;
    }

    if (obje == _sorulanObje) {
      setState(() {
        _cerceveRenkleri[index] = Colors.green;
        _sayac++;
        if (_sayac == _dogruSayi) {
          _puan += 10;
          // Eğer puan 100'e ulaşırsa, oyunu bitir
          if (_puan >= 100) {
            _oyunBitti();
            return;
          }
          Future.delayed(Duration(seconds: 1), _yeniTur);
        }
      });
      _animasyonGoster(_sayac);
    } else {
      setState(() {
        _cerceveRenkleri[index] = Colors.red;
        _puan -= 5;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _cerceveRenkleri.remove(index);
        });
      });
    }
  }

  void _animasyonGoster(int sayi) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: value,
                child: Text(
                  '$sayi',
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            );
          },
          onEnd: () => Navigator.pop(context),
        ),
      ),
    );
  }

  // Method to show game over dialog
  void _oyunBitti() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Oyun Bitti!'),
        content: Text('Tebrikler, Skorunuz 100 oldu!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _puan = 0;
                _kategoriIndex = 0;
                _yeniTur(); // Reset the game
              });
            },
            child: Text('Yeniden Başlat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sayma Oyunu",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.lightBlue[50],
        child: Column(
          children: [
            SizedBox(height: 10),
            Text(
              "Skor: $_puan",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "$_sorulanObje'den kaç tane var?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _ekrandakiObjeler.length,
                itemBuilder: (context, index) {
                  String obje = _ekrandakiObjeler[index];
                  return GestureDetector(
                    onTap: () => _objeyeTikla(obje, index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: _cerceveRenkleri[index] ?? Colors.grey[300]!,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          obje,
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
