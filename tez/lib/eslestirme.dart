import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MatchingGame());
}

class MatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eşleştirme Oyunu',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 20),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 4;
  List<List<String>> levels = [
    ['🔴', '🔵', '🟢', '🟡', '🔴', '🔵', '🟢', '🟡'],
    ['🐶', '🐱', '🐦', '🐠', '🐶', '🐱', '🐦', '🐠', '🦁', '🐼', '🦁', '🐼'],
    ['🍎', '🍌', '🍊', '🍇', '🥑', '🍒', '🍎', '🍌', '🍊', '🍇', '🥑', '🍒'],
  ];

  List<bool> isRevealed = [];
  int score = 0;
  int? firstCardIndex;
  int? secondCardIndex;
  int currentLevel = 0;
  Timer? timer;
  int elapsedTime = 0; // Geçen süre
  int bestTime = 0; // En iyi süre başlangıç değeri

  @override
  void initState() {
    super.initState();
    fetchBestTime();
    startNewLevel();
  }

  void startNewLevel() {
    isRevealed = List.filled(levels[currentLevel].length, false);
    levels[currentLevel].shuffle(Random());
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime++;
      });
    });
  }

  Future<void> saveTime(int time) async {
    final url = Uri.parse('http://192.168.69.112/oyunApis/eslestirmeTime.php');
    final response = await http.post(url, body: {
      'sure': time.toString(),
    });

    if (response.statusCode == 200) {
      print('Süre başarıyla kaydedildi: ${response.body}');
    } else {
      print('Süre kaydedilemedi: ${response.body}');
    }
  }

  Future<void> fetchBestTime() async {
    final url =
        Uri.parse('http://192.168.69.112/oyunApis/getEslestirmeTime.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] && data['data'] != null) {
        setState(() {
          bestTime = int.tryParse(data['data']['sure'].toString()) ??
              999; // Varsayılan olarak 999
        });
      } else {
        print('Veri alınamadı veya geçersiz format: ${response.body}');
      }
    } else {
      print('API isteği başarısız: ${response.statusCode}');
    }
  }

  void showCongratulationsDialog() async {
    await saveTime(elapsedTime); // Süreyi kaydet
    await fetchBestTime(); // Yeni en iyi süreyi al

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tebrikler!', style: TextStyle(color: Colors.green)),
          content: Text(
              'Tüm seviyeleri tamamladınız. En iyi süreniz: $bestTime saniye',
              style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text('Yeniden Başlat',
                  style: TextStyle(color: Colors.orange)),
            )
          ],
        );
      },
    );
  }

  void resetGame() {
    score = 0;
    currentLevel = 0;
    elapsedTime = 0; // Süreyi sıfırla
    startNewLevel();
  }

  void showGameOverDialog() async {
    await saveTime(elapsedTime); // Süreyi kaydet
    fetchBestTime(); // En iyi süreyi al

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Oyun Bitti!', style: TextStyle(color: Colors.red)),
          content: Text(
              'Süreniz: $elapsedTime saniye. En iyi süreniz: $bestTime saniye',
              style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text('Yeniden Başlat',
                  style: TextStyle(color: Colors.orange)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade200,
              const Color.fromARGB(255, 234, 221, 179)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(50),
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$elapsedTime',
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
              ),
            ),
            Positioned(
              top: 100,
              right: 20,
              child: Text(
                'Rekor: $bestTime',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: levels[currentLevel].length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => revealCard(index),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color.fromARGB(255, 188, 160, 119),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(255, 204, 159, 110)
                                          .withOpacity(1),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isRevealed[index] ||
                                      index == firstCardIndex ||
                                      index == secondCardIndex
                                  ? Text(
                                      levels[currentLevel][index],
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Image.network(
                                      'https://www.ankasanat.com/zig-brushables-2-renk-tonu-firca-uclu-marker-kalem-070-pure-orange-sanat-malzemeleri-zig-indirimli-51496-23-B.jpg',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void revealCard(int index) {
    if (firstCardIndex == null) {
      setState(() {
        firstCardIndex = index;
      });
    } else if (secondCardIndex == null && index != firstCardIndex) {
      setState(() {
        secondCardIndex = index;
      });
      checkForMatch();
    }
  }

  void checkForMatch() {
    if (levels[currentLevel][firstCardIndex!] ==
        levels[currentLevel][secondCardIndex!]) {
      setState(() {
        score++;
        isRevealed[firstCardIndex!] = true;
        isRevealed[secondCardIndex!] = true;
      });
    } else {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          isRevealed[firstCardIndex!] = false;
          isRevealed[secondCardIndex!] = false;
        });
      });
    }

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        firstCardIndex = null;
        secondCardIndex = null;
        if (isRevealed.every((revealed) => revealed)) {
          if (currentLevel < levels.length - 1) {
            currentLevel++;
            startNewLevel();
          } else {
            showCongratulationsDialog();
          }
        }
      });
    });
  }
}
