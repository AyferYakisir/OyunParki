import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: ObstacleAvoidanceGame(),
  ));
}

class ObstacleAvoidanceGame extends StatefulWidget {
  @override
  _ObstacleAvoidanceGameState createState() => _ObstacleAvoidanceGameState();
}

class _ObstacleAvoidanceGameState extends State<ObstacleAvoidanceGame> {
  double playerPosition = 0.0; // Oyuncunun yatay pozisyonu
  List<Offset> obstaclePositions = []; // Engel pozisyonları
  double screenWidth = 0.0;
  int score = 0;
  Timer? timer;
  Random random = Random();
  Timer? scoreTimer;
  int timerDuration = 200; // Başlangıç süresi
  int highestScore = 0; // En yüksek skor
  bool isNewHighScore = false; // Yeni rekor durumu
  bool gameOver = false; // Oyun bitiş durumu

  @override
  void initState() {
    super.initState();
    _startGame();
    _getHighestScore(); // En yüksek skoru al
    scoreTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _getHighestScore(); // Her 2 saniyede bir en yüksek skoru kontrol et
    });
  }

  void _startGame() {
    obstaclePositions.clear();
    score = 0;
    playerPosition = screenWidth / 2 - 10;
    timer = Timer.periodic(Duration(milliseconds: timerDuration), (timer) {
      _updateObstacles();
      _checkCollision();
    });
  }

  void _updateObstacles() {
    setState(() {
      if (obstaclePositions.length < 4) {
        double randomX = random.nextDouble() * (screenWidth - 50);
        obstaclePositions.add(Offset(randomX, 0));
      }

      for (int i = 0; i < obstaclePositions.length; i++) {
        obstaclePositions[i] =
            Offset(obstaclePositions[i].dx, obstaclePositions[i].dy + 10.0);
      }

      obstaclePositions
          .removeWhere((pos) => pos.dy > MediaQuery.of(context).size.height);
      score++;

      // Timer süresini kısaltma
      if (timerDuration > 50) {
        timerDuration -= 50; // Her güncellemede süreyi azalt
        timer?.cancel(); // Mevcut timer'ı iptal et
        timer = Timer.periodic(Duration(milliseconds: timerDuration), (timer) {
          _updateObstacles();
          _checkCollision();
        });
      }
    });
  }

  void _checkCollision() {
    const double tolerance = 10.0; // Tolerans mesafesi

    for (Offset obstacle in obstaclePositions) {
      bool isHorizontalCollision =
          playerPosition + 30 > obstacle.dx && // Oyuncu genişliği (30)
              playerPosition < obstacle.dx + 30; // Engel genişliği (30)

      bool isVerticalCollision = obstacle.dy + 30 >=
              MediaQuery.of(context).size.height - 10 && // Engel boyutu (30)
          obstacle.dy <= MediaQuery.of(context).size.height - 5;

      if (isHorizontalCollision && isVerticalCollision) {
        _gameOver();
      }
    }
  }

  void _gameOver() {
    timer?.cancel();
    _saveScore(score); // Skoru kaydet
    setState(() {
      gameOver = true; // Oyun bitiş durumu
    });
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        isNewHighScore = false; // Animasyonu gizle
        gameOver = false; // Oyun durumu sıfırlanır
      });
    });
  }

  void _saveScore(int score) async {
    final response = await http.post(
      Uri.parse('http://192.168.69.112/oyunApis/savePolisSkor.php'),
      body: {'skor': score.toString()},
    );

    if (response.statusCode == 200) {
      print('Skor kaydedildi.');
    } else {
      print('Skor kaydedilemedi.');
    }

    // Yeni rekor kontrolü
    if (score > highestScore) {
      setState(() {
        isNewHighScore = true; // Yeni rekor durumu
      });
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          isNewHighScore = false; // Animasyonu gizle
        });
      });
    } else {
      _showGameOverDialog(); // Rekor kırılmadıysa dialog göster
    }
  }

  void _getHighestScore() async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.69.112/oyunApis/getPolisSkor.php'), // API URL'sini güncelleyin
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          highestScore = int.tryParse(data['en_yuksek_skor'].toString()) ??
              0; // Dönüştürme
        });
      }
    } else {
      print('En yüksek skor alınamadı.');
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      playerPosition += details.delta.dx; // Kullanıcının sürükleme hareketi
      if (playerPosition < 0) playerPosition = 0;
      if (playerPosition > screenWidth - 50) playerPosition = screenWidth - 50;
    });
  }

  void _showGameOverDialog() {
    timer?.cancel();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[800],
          title: Text(
            'Oyun Bitti!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Skorunuz: $score',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Tekrar başlamak için "Tamam" butonuna basın.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: Text(
                'Tamam',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (gameOver) {
            _startGame(); // Oyun yeniden başlatılır
          }
        },
        child: Stack(
          children: [
            // Arka plan
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[200]!, Colors.green[200]!],
                ),
              ),
            ),
            // Oyuncu (Yeşil Araba Emoji)
            Positioned(
              bottom: 50,
              left: playerPosition,
              child: GestureDetector(
                onPanUpdate: _onPanUpdate, // Sürükleme hareketi
                child: Text(
                  '🚘', // Yeşil araba emoji (Oyuncu)
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            // Engeller (Kırmızı Araba Emojileri)
            ...obstaclePositions.map((pos) {
              return Positioned(
                top: pos.dy,
                left: pos.dx,
                child: Text(
                  '🚔', // Kırmızı araba emoji (Engel)
                  style: TextStyle(fontSize: 30),
                ),
              );
            }).toList(),
            // Skor bilgisi
            Positioned(
              top: 40,
              left: 20,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Text(
                  'Skor: $score',
                  key: ValueKey<int>(
                      score), // Skor değeri değiştikçe animasyon olur
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: isNewHighScore
                    ? Text(
                        'Yeni Rekor: $highestScore',
                        key: ValueKey<int>(highestScore),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      )
                    : Text(
                        'Rekor: $highestScore',
                        key: ValueKey<int>(highestScore),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            // Oyun bittiğinde gösterilecek mesaj
          ],
        ),
      ),
    );
  }
}
