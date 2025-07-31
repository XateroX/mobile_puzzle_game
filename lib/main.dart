import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_puzzle_game/data/game_rule.dart';
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
  final List<Rect> ruleRects = [];
  Offset? lastPositionOfPointer;
  int? selectedSquare;
  int? pressedRule;
  Offset? pressedRulePosition;
  Offset? pressedRuleOrigin;

  bool _shouldStart = false;
  bool _shouldPause = false;
  bool _shouldRestartPlay = false;
  bool _shouldIncrement = false;
  bool _shouldDecrement = false;

  bool gamePaused = true;

  int tickRate = 1;

  Timer? timer;

  @override
  void initState(){
    super.initState();
    // startTicks();

    // Duration of 1 second, but with repeat() and vsync,
    // Flutter gives you ~60 ticks per second
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(); // continuous loop
  } 

  void startTicks() {
    timer = Timer.periodic(
      Duration(milliseconds: (1000/(tickRate)).round()),
      (Timer timer) {gameState.tickGame();},
    );
    gamePaused = false;
  }

  void pauseTicks(){
    timer?.cancel();
    gamePaused = true;
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

  int? hitTestRules(
    Offset position,
    {List<int?> bannedValues=const [],}
  ) {
    for (int i = 0; i < ruleRects.length; i++) {
      if (
        ruleRects[i].contains(position) &&
        !bannedValues.contains(i)
      ) return i;
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
                  lastPositionOfPointer = event.localPosition;
                });
              },
              onEnter: (event){
                setState(() {
                  selectedSquare = hitTestBar(event.localPosition);
                  lastPositionOfPointer = event.localPosition;
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
                    int colInd = (selectedSquare! % gameState.gridDims.item1);
                    int rowInd = (selectedSquare! ~/ gameState.gridDims.item1);
                    gameState.grid[rowInd][colInd].cycleKind();
                    setState(() {});
                  }
                },
                onLongPressStart: (details) {
                  lastPositionOfPointer = details.localPosition;
                  int? pressingRule = hitTestRules(details.localPosition);
                  if (pressingRule!=null){
                    pressedRule = pressingRule;
                    pressedRuleOrigin = details.localPosition;
                  }
                  print("Long: $pressingRule");
                },
                onLongPressMoveUpdate: (details) {
                  lastPositionOfPointer = details.localPosition;
                  pressedRulePosition = details.localPosition - (pressedRuleOrigin??Offset(0,0));
                },
                onLongPressEnd: (details) {
                  lastPositionOfPointer = details.localPosition;
                  int? pressingRule = hitTestRules(details.localPosition, bannedValues:[pressedRule]);
                  if (
                    pressingRule != null
                  ){
                    GameRule pressingRuleValue = gameState.rules[pressingRule!].copy();
                    GameRule pressedRuleValue = gameState.rules[pressedRule!].copy();
                    if (pressedRule!=null){
                      gameState.rules[pressedRule!].ruleKindIndex = pressingRuleValue.ruleKindIndex;
                      gameState.rules[pressedRule!].kind = pressingRuleValue.kind;

                      gameState.rules[pressingRule!].ruleKindIndex = pressedRuleValue.ruleKindIndex;
                      gameState.rules[pressingRule!].kind = pressedRuleValue.kind;
                    }
                  }
                  pressedRule = null;
                  pressedRulePosition = null;
                },
                onHorizontalDragUpdate: (DragUpdateDetails details){
                  if (details.delta.dx>0){
                    _shouldStart = gamePaused ? true : false;
                    _shouldPause = gamePaused ? false : true;
                    print("should start = true");
                  } else if (details.delta.dx < 0) {
                    _shouldRestartPlay = true;
                  }
                },
                onVerticalDragUpdate: (DragUpdateDetails details){
                  if (details.delta.dy<0){
                    _shouldIncrement = true;
                    _shouldDecrement = false;
                  } else if (details.delta.dy>0) {
                    _shouldDecrement = true;
                    _shouldIncrement = false;
                  }
                },
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (_shouldRestartPlay){
                    gameState.restartLevel();
                    _shouldRestartPlay = false;
                  } else if (_shouldStart){
                    startTicks();
                    print("start ticks");
                    _shouldStart = false;
                  } else if (_shouldPause){
                    pauseTicks();
                    print("pause ticks");
                    _shouldPause = false;
                  }
                },
                onVerticalDragEnd: (DragEndDetails details) {
                  if (_shouldIncrement){
                    tickRate += 1;
                    tickRate = min(tickRate, 3);
                    pauseTicks();
                    startTicks();
                  } else if (_shouldDecrement){
                    tickRate -= 1;
                    tickRate = max(tickRate, 1);
                    pauseTicks();
                    startTicks();
                  }
                },
                child: CustomPaint(
                  size: Size(double.maxFinite, double.maxFinite),
                  painter: GameCanvas(
                    gameState: gameState,
                    squareRects: squareRects,
                    ruleRects: ruleRects,
                    pressedRule: pressedRule,
                    pressedRulePosition: pressedRulePosition,
                    lastPositionOfPointer: lastPositionOfPointer,
                    gamePaused: gamePaused,
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
