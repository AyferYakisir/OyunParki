import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(PuzzleApp());
}

class PuzzleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çocuk Puzzle Oyunu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.lightBlue[50], // Arka plan rengi
      ),
      home: PuzzleHomePage(),
    );
  }
}

class PuzzleHomePage extends StatefulWidget {
  @override
  _PuzzleHomePageState createState() => _PuzzleHomePageState();
}

class _PuzzleHomePageState extends State<PuzzleHomePage> {
  late List<int> _puzzlePieces;
  late int _emptyIndex;
  int _level = 2; // Başlangıç seviyesi (2x2)

  @override
  void initState() {
    super.initState();
    _initPuzzle();
  }

  void _initPuzzle() {
    int size = _level * _level;
    _puzzlePieces = List.generate(size, (index) => index);
    _emptyIndex = size - 1; // Son parça boş
    _shufflePuzzle();
  }

  void _shufflePuzzle() {
    _puzzlePieces.shuffle(Random());
    while (_puzzlePieces.last != _level * _level - 1) {
      _puzzlePieces.shuffle(Random());
    }
  }

  void _movePiece(int index) {
    if (_isAdjacent(index, _emptyIndex)) {
      setState(() {
        _puzzlePieces[_emptyIndex] = _puzzlePieces[index];
        _puzzlePieces[index] = _level * _level - 1; // Boş parça
        _emptyIndex = index;

        if (_isSolved()) {
          _nextLevel();
        }
      });
    }
  }

  bool _isAdjacent(int index1, int index2) {
    final int size = _level;
    final int row1 = index1 ~/ size;
    final int col1 = index1 % size;
    final int row2 = index2 ~/ size;
    final int col2 = index2 % size;

    return (row1 == row2 && (col1 - col2).abs() == 1) ||
        (col1 == col2 && (row1 - row2).abs() == 1);
  }

  bool _isSolved() {
    for (int i = 0; i < _level * _level - 1; i++) {
      if (_puzzlePieces[i] != i) return false;
    }
    return true;
  }

  void _nextLevel() {
    if (_level < 4) {
      setState(() {
        _level++;
        _initPuzzle();
      });
    } else {
      // Oyun tamamlandı
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Tebrikler!', style: TextStyle(color: Colors.blue)),
            content: Text('Tüm seviyeleri tamamladınız!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _level = 2; // Başlangıca dön
                    _initPuzzle();
                  });
                },
                child: Text('Tamam', style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Çocuk Puzzle Oyunu'),
      ),
      body: Center(
        
        child: Container(
          width: _level * 150.0, 
          height: _level * 150.0, 
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _level,
              crossAxisSpacing: 4, 
              mainAxisSpacing: 4, 
            ),
            itemCount: _level * _level,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _movePiece(index),
                child: _buildPuzzlePiece(_puzzlePieces[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzlePiece(int value) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: value == _level * _level - 1 ? Colors.transparent : Colors.blue,
        borderRadius: BorderRadius.circular(10), // Köşe yuvarlama
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Gölge konumu
          ),
        ],
      ),
      child: Center(
        child: value == _level * _level - 1
            ? null
            : Text(
                '${value + 1}', // Burada sayılar 1'den başlıyor
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
