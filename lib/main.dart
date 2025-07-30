import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_puzzle_game/data/game_state.dart';
import 'package:mobile_puzzle_game/game_canvas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  GameState gameState = GameState();
  final List<Rect> squareRects = [];
  int? selectedSquare;

  Timer? timer;

  @override
  void initState(){
    super.initState();
    timer = Timer.periodic(
      Duration(milliseconds: 1000),
      (Timer timer) {gameState.tickGame();},
    );

    // Duration of 1 second, but with repeat() and vsync,
    // Flutter gives you ~60 ticks per second
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(); // continuous loop
  } 

  @override
  void dispose(){
    super.dispose();
    timer?.cancel();
    _controller.dispose();
  }

  int? hitTestBar(Offset position) {
    for (int i = 0; i < squareRects.length; i++) {
      if (squareRects[i].contains(position)) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          body: Center(
            child: MouseRegion(
              onHover: (event) {
                setState(() {
                  selectedSquare = hitTestBar(event.localPosition);
                });
              },
              onEnter: (event){
                setState(() {
                  selectedSquare = hitTestBar(event.localPosition);
                });
              },
              onExit: (event){
                setState(() {
                  selectedSquare = null;
                });
              },
              child: GestureDetector(
                onTap: (){
                  if (selectedSquare!=null){
                    int rowInd = (selectedSquare! % gameState.gridDims.item1);
                    int colInd = (selectedSquare! ~/ gameState.gridDims.item1);
                    gameState.grid[rowInd][colInd].cycleKind();
                    setState(() {});
                  }
                },
                onHorizontalDragStart: (DragStartDetails details){

                },
                onLongPress: (){
                  // gameState.
                },
                child: CustomPaint(
                  size: Size(double.maxFinite, double.maxFinite),
                  painter: GameCanvas(
                    gameState: gameState,
                    squareRects: squareRects
                  ),
                ),
              ),
            )
          ),
        );
      }
    );
  }
}
