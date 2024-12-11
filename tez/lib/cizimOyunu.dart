import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<Offset> points = [];
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/alfabe.tflite');
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      print('Model yüklenirken hata oluştu: $e');
    }
  }

  void recognizeDrawing() {
    if (!_isModelLoaded) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Model Yüklenmedi'),
          content: Text('Model henüz yüklenmedi. Lütfen tekrar deneyin.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tamam'),
            ),
          ],
        ),
      );
      return;
    }

    // Çizimi modele gönderme kodu
    final imageMatrix = convertDrawingToMatrix(points, 28, 28);
    var input = imageMatrix.reshape([1, 28, 28, 1]);
    var output = List.filled(26, 0.0).reshape([1, 26]);

    _interpreter!.run(input, output);
    int predictedIndex =
        output[0].indexOf(output[0].reduce((a, b) => max<double>(a, b)));

    String predictedLetter =
        String.fromCharCode(predictedIndex + 65); // A'nın ASCII değeri 65

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tanınan Harf'),
        content: Text('Çizilen harf: $predictedLetter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  List<List<double>> convertDrawingToMatrix(
      List<Offset> points, int width, int height) {
    List<List<double>> matrix =
        List.generate(width, (_) => List.generate(height, (_) => 0.0));

    for (var point in points) {
      if (point != Offset.zero) {
        int x = (point.dx / MediaQuery.of(context).size.width * width).toInt();
        int y =
            (point.dy / MediaQuery.of(context).size.height * height).toInt();
        if (x >= 0 && y >= 0 && x < width && y < height) {
          matrix[y][x] = 1.0; // Piksel değeri olarak 1.0 kullan
        }
      }
    }
    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Çizim Oyunu")),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            points.add(details.localPosition);
          });
        },
        onPanEnd: (details) => points.add(Offset.zero),
        child: CustomPaint(
          painter: DrawingPainter(points: points),
          child: Container(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: recognizeDrawing,
        child: Icon(Icons.check),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
