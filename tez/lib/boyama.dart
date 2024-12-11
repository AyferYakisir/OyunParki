import 'package:flutter/material.dart';

void main() {
  runApp(BoyamaOyunuApp());
}

class BoyamaOyunuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boyama Oyunu',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BoyamaSayfasi(),
    );
  }
}

class BoyamaSayfasi extends StatefulWidget {
  @override
  _BoyamaSayfasiState createState() => _BoyamaSayfasiState();
}

class _BoyamaSayfasiState extends State<BoyamaSayfasi>
    with SingleTickerProviderStateMixin {
  Color secilenRenk = Colors.black;
  bool silgiModu = false;
  double kalemKalInligi = 5.0;
  List<DokunmaVerisi> dokunmaNoktalari = [];
  int resimIndex = 0;
  final List<String> resimler = [
    'https://boyamaonline.com/images/imgcolor/dort-duygusal-yildiz.jpg',
    'https://www.mustafakabul.com/FileUpload/op849513/Album/op849513_20231125132328.jpg',
    'https://st4.depositphotos.com/5966606/19950/v/450/depositphotos_199503762-stock-illustration-easy-coloring-drawings-animals-little.jpg',
    'https://boyamaonline.com/images/imgcolor/Normal-Sicak-Hava-Balonu-scaled.jpg',
    'https://boyamaonline.com/images/imgcolor/Ayi-cizimi.jpg',
  ];

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late double resimWidth;
  late double resimHeight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            dokunmaNoktalari.clear();
            resimIndex = (resimIndex + 1) % resimler.length;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void resimTamamla() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // AppBar removed
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                resimWidth = constraints.maxWidth - 20; // Padding adjustment
                resimHeight = constraints.maxHeight - 100; // Padding adjustment
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 5,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(resimler[resimIndex]),
                                  fit: BoxFit
                                      .contain, // Ensures images fit within the screen
                                ),
                              ),
                              width: resimWidth,
                              height: resimHeight,
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            RenderBox renderBox =
                                context.findRenderObject() as RenderBox;
                            Offset nokta =
                                renderBox.globalToLocal(details.globalPosition);

                            // Ensure the drawing stays within the inner content area of the container
                            if (nokta.dx >= 0 &&
                                nokta.dy >= 0 &&
                                nokta.dx <= resimWidth &&
                                nokta.dy <= resimHeight) {
                              if (silgiModu) {
                                dokunmaNoktalari.removeWhere((dokunmaVerisi) =>
                                    (dokunmaVerisi.nokta - nokta).distance <
                                    kalemKalInligi);
                              } else {
                                dokunmaNoktalari.add(DokunmaVerisi(
                                    nokta, secilenRenk, kalemKalInligi));
                              }
                            }
                          });
                        },
                        child: CustomPaint(
                          painter: BoyamaPainter(
                              dokunmaNoktalari, _scaleAnimation.value),
                          size: Size(resimWidth, resimHeight),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Renk Paleti:',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              renkPaleti(Colors.red),
              renkPaleti(Colors.green),
              renkPaleti(Colors.blue),
              renkPaleti(Colors.yellow),
              renkPaleti(Colors.orange),
              renkPaleti(Colors.purple),
              silgiButonu(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Kalem Kalınlığı: ${kalemKalInligi.toStringAsFixed(1)}',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Slider(
            min: 1.0,
            max: 20.0,
            value: kalemKalInligi,
            onChanged: (yeniDeger) {
              setState(() {
                kalemKalInligi = yeniDeger;
              });
            },
          ),
          ElevatedButton(
            onPressed: resimTamamla,
            child: Text('Tamamla'),
          ),
        ],
      ),
    );
  }

  Widget renkPaleti(Color renk) {
    return GestureDetector(
      onTap: () {
        setState(() {
          secilenRenk = renk;
          silgiModu = false;
        });
      },
      child: Container(
        margin: EdgeInsets.all(4),
        width: 40,
        height: 40,
        color: renk,
      ),
    );
  }

  Widget silgiButonu() {
    return GestureDetector(
      onTap: () {
        setState(() {
          silgiModu = true;
        });
      },
      child: Container(
        margin: EdgeInsets.all(4),
        width: 40,
        height: 40,
        color: Colors.white,
        child: Center(
          child: Icon(Icons.cleaning_services, color: Colors.black),
        ),
      ),
    );
  }
}

class BoyamaPainter extends CustomPainter {
  final List<DokunmaVerisi> dokunmaNoktalari;
  final double scale;

  BoyamaPainter(this.dokunmaNoktalari, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    for (var dokunma in dokunmaNoktalari) {
      paint.color = dokunma.renk;

      // Çizim verilerini ölçeklendiriyoruz
      double scaledX = dokunma.nokta.dx * scale;
      double scaledY = dokunma.nokta.dy * scale;
      double scaledKalinlik = dokunma.kalinlik * scale;

      canvas.drawCircle(
        Offset(scaledX, scaledY),
        scaledKalinlik, // Kalınlık da ölçeklendiriliyor
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DokunmaVerisi {
  final Offset nokta;
  final Color renk;
  final double kalinlik;

  DokunmaVerisi(this.nokta, this.renk, this.kalinlik);
}
