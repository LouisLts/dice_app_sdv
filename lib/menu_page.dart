import 'package:flutter/material.dart';
import 'dart:math';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _generateBubbles();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateBubbles() {
    for (int i = 0; i < 50; i++) {
      _bubbles.add(Bubble());
    }
  }

  void _popBubble(Offset position) {
    setState(() {
      _bubbles.removeWhere((bubble) {
        final bubblePosition = Offset(bubble.x, bubble.y);
        final distance = (bubblePosition - position).distance;
        return distance < bubble.radius;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bubble 421'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GestureDetector(
          onTapDown: (details) => _popBubble(details.localPosition),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  for (var bubble in _bubbles) {
                    bubble.updatePosition(MediaQuery.of(context).size);
                  }
                  return CustomPaint(
                    painter: BubblePainter(_bubbles),
                    size: MediaQuery.of(context).size,
                  );
                },
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.casino,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/game', arguments: 1);
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('1 Bubble-Joueur'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/game', arguments: 2);
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('2 Bubble-Joueurs'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Bubble {
  double x;
  double y;
  double radius;
  double speed;
  double direction;

  Bubble({
    this.x = 0,
    this.y = 0,
    this.radius = 0,
    this.speed = 0,
    this.direction = 0,
  }) {
    Random random = Random();
    x = random.nextDouble() * 400;
    y = random.nextDouble() * 800;
    radius = random.nextDouble() * 20 + 10;
    speed = random.nextDouble() * 2 + 1;
    direction = random.nextDouble() * 2 * pi;
  }

  void updatePosition(Size screenSize) {
    x += speed * cos(direction);
    y += speed * sin(direction);

    if (x < 0 || x > screenSize.width) {
      direction = pi - direction;
    }
    if (y < 0 || y > screenSize.height) {
      direction = -direction;
    }
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;

  BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bubble.x, bubble.y), bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
