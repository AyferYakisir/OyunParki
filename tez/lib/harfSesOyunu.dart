import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimalSoundGame(),
    );
  }
}

class AnimalSoundGame extends StatefulWidget {
  @override
  _AnimalSoundGameState createState() => _AnimalSoundGameState();
}

class _AnimalSoundGameState extends State<AnimalSoundGame> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, String> _animalSounds = {
    '🐶': 'köpek.mp3',
    '🐱': 'kedi.mp3',
    '🐄': 'inek.mp3',
    '🦜': 'kus.mp3',
    '🐔': 'tavuk.mp3',
    '🦁': 'aslan.mp3',
    '🐒': 'maymun.mp3', // Maymun
    '🐸': 'kurbaga.mp3', // Kurbağa
    '🐍': 'yilan.mp3', // Yılan
  };

  List<String> _animalOptions = [];
  String _correctAnimal = '';
  String _message = 'Hayvan sesini dinleyin ve doğru hayvanı seçin!';
  List<Color> _frameColors = [];

  @override
  void initState() {
    super.initState();
    _prepareNextRound();
  }
  @override
void dispose() {
  _audioPlayer.dispose(); // Ses çalıcıyı temizle
  super.dispose();
}


  Future<void> _prepareNextRound() async {
    await _audioPlayer.stop(); // Önceki sesi durdur
    final random = Random();
    _animalOptions = _animalSounds.keys.toList();
    _animalOptions.shuffle();

    _correctAnimal = _animalOptions[random.nextInt(_animalOptions.length)];
    _frameColors =
        List.generate(_animalOptions.length, (_) => Colors.grey.shade300);

    setState(() {
      _message = 'Hayvan sesini dinleyin ve doğru hayvanı seçin!';
    });

    // Yeni hayvan sesini çal
    _playAnimalSound(_animalSounds[_correctAnimal]!);
  }

  void _playAnimalSound(String soundFile) {
    _audioPlayer.play(AssetSource(soundFile));
  }

  void _checkAnswer(String selectedAnimal, int index) {
    if (selectedAnimal == _correctAnimal) {
      setState(() {
        _frameColors[index] = Colors.green;
        _message = '🎉 Doğru cevap!';
      });
      Future.delayed(Duration(seconds: 1), _prepareNextRound);
    } else {
      setState(() {
        _frameColors[index] = Colors.red;
        _message = '❌ Yanlış cevap! Tekrar deneyin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 225, 193, 212),
              const Color.fromARGB(255, 238, 147, 189)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Card(
                elevation: 4,
                color: Colors.deepPurple.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      _message,
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: GridView.builder(
                  shrinkWrap:
                      true, // GridView'ın içeriğe göre küçülmesini sağlar
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _animalOptions.length,
                  itemBuilder: (context, index) {
                    final animal = _animalOptions[index];
                    return GestureDetector(
                      onTap: () => _checkAnswer(animal, index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _frameColors[index],
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
                            animal,
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
