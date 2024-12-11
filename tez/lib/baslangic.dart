import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:tez/anasayfa.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int firstNumber = 0;
  int secondNumber = 0;
  int correctAnswer = 0;
  String userAnswer = "";

  @override
  void initState() {
    super.initState(); // Ekranın yatay moda sabitlenmesi
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _generateMathProblem();
  }

  void _generateMathProblem() {
    setState(() {
      // Rastgele toplama veya çıkarma işlemi oluştur
      firstNumber = Random().nextInt(10) + 1;
      secondNumber = Random().nextInt(10) + 1;
      correctAnswer = firstNumber + secondNumber; // Toplama işlemi
    });
  }

  void _checkAnswer() {
    if (int.tryParse(userAnswer) == correctAnswer) {
      Navigator.pop(context); // Diyalog kapatılır
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ParentInfoPage()),
      );
    } else {
      setState(() {
        userAnswer = "";
        _generateMathProblem(); // Yanlış cevap verildiğinde yeni soru üret
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ayıcık animasyonu
                Image.network(
                  'https://i.pinimg.com/originals/27/9a/37/279a3784afd830bbdc8c01659a6e7d2d.gif', // Ayıcık animasyonu URL'i
                  height: 150,
                ),
                SizedBox(height: 20),
                // Play arrow ikonu
                IconButton(
                  icon: Icon(Icons.play_arrow, size: 50, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AnaSayfa(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = Offset(1.0, 0.0); // Sağa kayma
                          var end = Offset.zero;
                          var tween = Tween(begin: begin, end: end);
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Ebeveyn tanıma butonu
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.lock, color: Colors.red, size: 30),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Ebeveyn Doğrulama'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$firstNumber + $secondNumber = ?'),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: [
                                for (var i = 1; i <= 9; i++)
                                  _numberButton('$i'),
                                _numberButton('0'),
                                IconButton(
                                  icon: Icon(Icons.backspace),
                                  onPressed: () {
                                    setState(() {
                                      userAnswer = userAnswer.isNotEmpty
                                          ? userAnswer.substring(
                                              0, userAnswer.length - 1)
                                          : "";
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: _checkAnswer,
                          child: Text("Onayla"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberButton(String number) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          userAnswer += number;
        });
      },
      child: Text(number),
    );
  }
}

class ParentInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ebeveyn Bilgilendirme Sayfası'),
      ),
      body: Center(
        child: Text('Ebeveyn Bilgileri'),
      ),
    );
  }
}
