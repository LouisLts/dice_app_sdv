import 'package:flutter/material.dart';
import 'dart:math';

class GamePage extends StatefulWidget {
  final int numberOfPlayers;

  const GamePage({super.key, required this.numberOfPlayers});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  List<int> _diceValues = [1, 1, 1];
  int _currentPlayer = 1;
  int _player1Score = 0;
  int _player2Score = 0;
  bool _isGameOver = false;
  bool _hasSixes = false;
  bool _isWinningRound = false;
  bool _isAnimating = false;
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Règles du 421'),
          content: const Text(
            'Le but du jeu est d\'être le premier joueur à atteindre 3 points.\n\n'
            '- Chaque joueur lance 3 dés.\n'
            '- Si vous obtenez la combinaison 4, 2 et 1 (dans n\'importe quel ordre), vous marquez un point.\n'
            '- Si vous obtenez un ou plusieurs 6, vous devez les relancer.\n'
            '- Le premier joueur à 3 points gagne la partie.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotateAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_animationController);
    _scaleAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _rollDice() {
    setState(() {
      _isAnimating = true;
    });
    _animationController.forward(from: 0).then((_) {
      setState(() {
        _diceValues = List.generate(3, (_) => Random().nextInt(6) + 1);
        _checkWinningCombination();
        _checkSixes();
        if (!_isWinningRound) {
          _nextPlayer();
        }
        _isAnimating = false;
      });
    });
  }

  void _rerollSixes() {
    setState(() {
      _isAnimating = true;
    });
    _animationController.forward(from: 0).then((_) {
      setState(() {
        for (int i = 0; i < _diceValues.length; i++) {
          if (_diceValues[i] == 6) {
            _diceValues[i] = Random().nextInt(6) + 1;
          }
        }
        _checkWinningCombination();
        _checkSixes();
        _isAnimating = false;
      });
    });
  }

  void _checkWinningCombination() {
    if (_diceValues.contains(4) &&
        _diceValues.contains(2) &&
        _diceValues.contains(1)) {
      setState(() {
        if (_currentPlayer == 1) {
          _player1Score++;
        } else {
          _player2Score++;
        }
        _isWinningRound = true;
        if (_player1Score == 3 || _player2Score == 3) {
          _isGameOver = true;
        }
      });
      _animationController.forward(from: 0);
    } else {
      _isWinningRound = false;
    }
  }

  void _checkSixes() {
    setState(() {
      _hasSixes = _diceValues.contains(6);
    });
  }

  void _nextPlayer() {
    setState(() {
      if (widget.numberOfPlayers == 2) {
        _currentPlayer = _currentPlayer == 1 ? 2 : 1;
      }
    });
  }

  void _resetGame() {
    setState(() {
      _diceValues = [1, 1, 1];
      _isGameOver = false;
      _isWinningRound = false;
      _hasSixes = false;
      _currentPlayer = 1;
      _player1Score = 0;
      _player2Score = 0;
    });
  }

  void _continueGame() {
    setState(() {
      _isWinningRound = false;
    });
  }

  void _debugWinningMove() {
    setState(() {
      _diceValues = [4, 2, 1];
      _checkWinningCombination();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int numberOfPlayers = widget.numberOfPlayers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('421'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => _showRulesDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Joueur $_currentPlayer',
                style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _diceValues.map((value) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: (!_hasSixes || value == 6)
                              ? _rotateAnimation.value
                              : 0,
                          child: ScaleTransition(
                            scale: _isWinningRound
                                ? _scaleAnimation
                                : const AlwaysStoppedAnimation(1),
                            child: Image.asset(
                              'assets/images/inverted-dice-$value.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              const Text(
                'Score :',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              Text(
                'Joueur 1 : $_player1Score',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              if (numberOfPlayers == 2)
                Text(
                  'Joueur 2 : $_player2Score',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              const SizedBox(height: 40),
              if (!_isGameOver && !_hasSixes && !_isWinningRound)
                ElevatedButton(
                  onPressed: _isAnimating ? null : _rollDice,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Lancer les dés'),
                ),
              if (_hasSixes && !_isGameOver && !_isWinningRound)
                ElevatedButton(
                  onPressed: _isAnimating ? null : _rerollSixes,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(
                    _diceValues.where((value) => value == 6).length == 1
                        ? 'Relancer le 6'
                        : 'Relancer les 6',
                  ),
                ),
              if (_isWinningRound && !_isGameOver)
                ElevatedButton(
                  onPressed: _isAnimating ? null : _continueGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Continuer'),
                ),
              if (_isGameOver)
                Column(
                  children: [
                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: Text(
                        _player1Score == 3
                            ? 'Le joueur 1 a gagné !'
                            : 'Le joueur 2 a gagné !',
                        style:
                            const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Rejouer'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _debugWinningMove,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Debug - Coup gagnant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
