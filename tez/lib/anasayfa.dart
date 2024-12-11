import 'package:flutter/material.dart';
import 'package:tez/eslestirme.dart';
import 'package:tez/harfSesOyunu.dart';
import 'package:tez/boyama.dart';
import 'package:tez/hikayeler.dart';
import 'package:tez/polis.dart';
import 'package:tez/puzzle.dart';
import 'package:tez/saymaOyunu.dart';
import 'package:tez/sekillerleOgren.dart';
import 'package:tez/cizimOyunu.dart';

class AnaSayfa extends StatelessWidget {
  final List<Map<String, String>> oyunlar = [
    {
      'isim': 'Şekillerle Öğrenme',
      'resim':
          'https://play-lh.googleusercontent.com/0PMPXtCoosso05B-xTMYmS6qRkS5pOybR7bQ09PuqHVnbmWYZqgjnPm4HoyPMUdV_GHo=w240-h480-rw'
    },
    {
      'isim': 'Sayma Oyunu',
      'resim':
          'https://i.ytimg.com/vi/LjjaURvY4d4/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLBKOF9w_yrCFihznkmbF8QAiXGBsA'
    },
    {
      'isim': 'Polis Oyunu',
      'resim':
          'https://img.lovepik.com/png/20231118/cartoon-police-emoji-vector-clipart-sticker_621972_wh860.png'
    },
    {
      'isim': 'Hayvan Seslerini Tanıma',
      'resim':
          'https://play-lh.googleusercontent.com/Ktusd1S75TgVSPiLb0F5guKttmHfzATtzhfA0QCSy8O6XI0U0As0baffbgPtDgUGGadM=w526-h296-rw'
    },
    {
      'isim': 'Puzzle',
      'resim':
          'https://ae03.alicdn.com/kf/Sa352f7e85a874630be929540175ce2dcP.jpg_640x640q90.jpg'
    },
    {
      'isim': 'Kart Eşleştir',
      'resim': 'https://www.rekoroyun.com/resim/300/kart-eslestirme-2.jpg'
    },
    {
      'isim': 'Boyama Oyunu',
      'resim':
          'https://play-lh.googleusercontent.com/m14J4zIEz2vOdyeTbk8s6HyxTdJz9xSlae5pj8UbFbjaaFR8Llinh-FtCIFGIVZ_UQ'
    },
    {
      'isim': 'Çizim Oyunu',
      'resim': 'https://www.rekoroyun.com/resim/300/panda-cizme.jpg'
    },
    {
      'isim': 'Okuma Hikayeleri',
      'resim':
          'https://storyspark.ai/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Flayer2.37f1bf15.webp&w=3840&q=75'
    },
  ];

  void _oyunuBaslat(BuildContext context, String oyunIsmi) {
    Widget oyunSayfasi;

    switch (oyunIsmi) {
      case 'Şekillerle Öğrenme':
        oyunSayfasi = SekillerleOgrenme();
        break;
      case 'Sayma Oyunu':
        oyunSayfasi = SaymaOyunu();
        break;
      case 'Polis Oyunu':
        oyunSayfasi = ObstacleAvoidanceGame();
        break;
      case 'Hayvan Seslerini Tanıma':
        oyunSayfasi = AnimalSoundGame();
        break;
      case 'Puzzle':
        oyunSayfasi = PuzzleHomePage();
        break;
      case 'Kart Eşleştir':
        oyunSayfasi = MatchingGame();
        break;
      case 'Boyama Oyunu':
        oyunSayfasi = BoyamaOyunuApp();
        break;
        case 'Çizim Oyunu':
        oyunSayfasi = DrawingPage();
        break;
      case 'Okuma Hikayeleri':
        oyunSayfasi = HikayeApp();
        break;
      default:
        oyunSayfasi =
            Scaffold(body: Center(child: Text('Oyun Sayfası Bulunamadı')));
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => oyunSayfasi),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 202, 195, 182),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: oyunlar.length,
          itemBuilder: (context, index) {
            final oyun = oyunlar[index];
            return GestureDetector(
              onTap: () => _oyunuBaslat(context, oyun['isim']!),
              child: Column(
                children: [
                  Expanded(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(oyun['resim']!),
                      radius: MediaQuery.of(context).size.width * 0.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    oyun['isim']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
