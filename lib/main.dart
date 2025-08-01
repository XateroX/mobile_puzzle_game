import 'dart:async';
import 'dart:math';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:mobile_puzzle_game/data/game_rule.dart';
import 'package:mobile_puzzle_game/data/game_state.dart';
import 'package:mobile_puzzle_game/data/grid_item.dart';
import 'package:mobile_puzzle_game/game_canvas.dart';
import 'package:mobile_puzzle_game/sound/audio_controller.dart';
import 'package:mobile_puzzle_game/sound/sound_state.dart';
import 'package:tuple/tuple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioController = AudioController();
  await audioController.initialize();
  // audioController.startMusic();

  SoundState soundState = SoundState(audioController:audioController);
 
  runApp(
     ChangeNotifierProvider<SoundState>(
      create: (_) => soundState,
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Puzzle Game',
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

  bool showMenu = false;

  GameState gameState = GameState();
  final List<Rect> squareRects = [];
  final List<Rect> ruleRects = [];
  Offset? lastPositionOfPointer;
  int? selectedSquare;
  int? pressedRule;
  Offset? pressedRulePosition;
  Offset? pressedRuleOrigin;

  bool _canSave = true;
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

  void startTicks(Function playSound) {
    timer = Timer.periodic(
      Duration(milliseconds: (1000/(tickRate)).round()),
      (Timer timer) {
        gameState.tickGame();
        playSound();
      },
    );
    gamePaused = false;
    if (_canSave){
      gameState.currentLevelGrid = gameState.gridCopy(gameState.grid);
      gameState.currentLevelRules = gameState.rules.map((rule)=>rule.copy()).toList();
      _canSave = false;
    }
  }

  void pauseTicks(Function playSound){
    timer?.cancel();
    gamePaused = true;

    gameState.checkForSolution();
    playSound();
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
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Menu',
                onPressed: () {
                  setState(() {
                    showMenu = !showMenu;
                  });
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Center(
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
                    onTapDown: (details) {
                      setState(() {
                        selectedSquare = hitTestBar(details.localPosition);
                        lastPositionOfPointer = details.localPosition;
                        Provider.of<SoundState>(context, listen:false).playClickSoundInteraction();
                      });
                    },
                    onTap: (){
                      if (
                        selectedSquare!=null &&
                        gamePaused == true && 
                        _canSave == true
                      ){
                        int colInd = (selectedSquare! % gameState.gridDims.item1);
                        int rowInd = (selectedSquare! ~/ gameState.gridDims.item1);
                        if (gameState.initialGrid[rowInd][colInd].kind!=GridItemKind.BLANK){
                          gameState.grid[rowInd][colInd].cycleKind();
                          setState(() {});
                        }
                      }
                    },
                    onLongPressStart: (details) {
                      if (gamePaused){
                        lastPositionOfPointer = details.localPosition;
                        int? pressingRule = hitTestRules(details.localPosition);
                        if (pressingRule!=null){
                          pressedRule = pressingRule;
                          pressedRuleOrigin = details.localPosition;
                        }
                        print("Long: $pressingRule");
                      }
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
                      if (details.delta.dx>0 && (details.delta.dx).abs()>(details.delta.dy).abs()){
                        _shouldStart = gamePaused ? true : false;
                        _shouldPause = gamePaused ? false : true;
                        print("should start = true");
                      } else if (details.delta.dx<0  && (details.delta.dx).abs()>(details.delta.dy).abs()) {
                        _shouldRestartPlay = true;
                      }
                    },
                    onVerticalDragUpdate: (DragUpdateDetails details){
                      if (details.delta.dy<0 && (details.delta.dy).abs()>(details.delta.dx).abs()){
                        _shouldIncrement = true;
                        _shouldDecrement = false;
                      } else if (details.delta.dy>0 && (details.delta.dy).abs()>(details.delta.dx).abs()) {
                        _shouldDecrement = true;
                        _shouldIncrement = false;
                      }
                    },
                    onHorizontalDragEnd: (DragEndDetails details) {
                      if (_shouldRestartPlay && gamePaused){
                        gameState.restartLevel();
                        _shouldRestartPlay = false;
                        _canSave = true;
                      } else if (_shouldStart){
                        startTicks(Provider.of<SoundState>(context, listen:false).playTickSound);
                        print("start ticks");
                        _shouldStart = false;
                      } else if (_shouldPause){
                        pauseTicks(Provider.of<SoundState>(context, listen:false).playPauseSound);
                        print("pause ticks");
                        _shouldPause = false;
                      }
                      Provider.of<SoundState>(context, listen:false).playClickSoundInteraction();
                    },
                    onVerticalDragEnd: (DragEndDetails details) {
                      if (_shouldIncrement){
                        tickRate += 1;
                        tickRate = min(tickRate, 3);
                        pauseTicks(Provider.of<SoundState>(context, listen:false).playPauseSound);
                        startTicks(Provider.of<SoundState>(context, listen:false).playTickSound);
                      } else if (_shouldDecrement){
                        tickRate -= 1;
                        tickRate = max(tickRate, 1);
                        pauseTicks(Provider.of<SoundState>(context, listen:false).playPauseSound);
                        startTicks(Provider.of<SoundState>(context, listen:false).playTickSound);
                      }
                      Provider.of<SoundState>(context, listen:false).playClickSoundInteraction();
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
                        canSave: _canSave,
                      ),
                    ),
                  ),
                )
              ), 
              showMenu ? Card(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: (){
                            tickRate += 1;
                            tickRate = min(tickRate, 3);
                            pauseTicks(Provider.of<SoundState>(context, listen:false).playPauseSound);
                            startTicks(Provider.of<SoundState>(context, listen:false).playTickSound);
                          }, 
                          child: Text("+")
                        ),
                        SizedBox(width: 10),
                        Text("Tick Rate: ${tickRate}"),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: (){
                            tickRate -= 1;
                            tickRate = max(tickRate, 1);
                            pauseTicks(Provider.of<SoundState>(context, listen:false).playPauseSound);
                            startTicks(Provider.of<SoundState>(context, listen:false).playTickSound);
                          }, 
                          child: Text("-")
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: gameState.gridDims.item1 < 10 ? () {
                            gameState.gridDims = Tuple2(gameState.gridDims.item1+1, gameState.gridDims.item2+1);
                            gameState.generateLevel();
                          } : null, 
                          child: Text("+")
                        ),
                        SizedBox(width: 10),
                        Text("Grid Size: ${gameState.gridDims.item1}x${gameState.gridDims.item1}"),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: gameState.gridDims.item1 > 2 ? () {
                            gameState.gridDims = Tuple2(gameState.gridDims.item1-1, gameState.gridDims.item2-1);
                            gameState.generateLevel();
                          } : null, 
                          child: Text("-")
                        ),
                      ],
                    ),
                  ],
                ),
              ) : Container()
            ]
          ),
        );
      }
    );
  }
}
