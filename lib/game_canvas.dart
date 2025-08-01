import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_puzzle_game/data/game_rule.dart';
import 'package:mobile_puzzle_game/data/game_state.dart';
import 'package:mobile_puzzle_game/data/grid_item.dart';

class GameCanvas extends CustomPainter {
  GameState gameState;
  final List<Rect> squareRects;
  final List<Rect> ruleRects;
  final int? pressedRule;
  final Offset? pressedRulePosition;
  Offset? lastPositionOfPointer;
  bool gamePaused;
  bool canSave;
  
  GameCanvas({
    required this.gameState,
    required this.squareRects,
    required this.ruleRects,
    required this.pressedRule,
    required this.pressedRulePosition,
    required this.lastPositionOfPointer,
    required this.gamePaused,
    required this.canSave,
  });

  void _drawGameGrid(
    Canvas canvas, 
    Size size,
    Offset canvasActualTopLeft,
    Size canvasActualSize,
    Offset overallTranslation,
  ){
    squareRects.removeWhere((e)=>true);
    // draw a grid of the game board using the gamestate.grid to get the values to use to draw each square
    double padding = canvasActualSize.width/30; // Padding between squares
    double squareWidth = (canvasActualSize.width / gameState.gridDims.item2) - padding;
    double squareHeight = (canvasActualSize.height / gameState.gridDims.item1) - padding;

    for (int i = 0; i < gameState.grid.length; i++) {
      for (int j = 0; j < gameState.grid[i].length; j++) {
        double xOffset = canvasActualTopLeft.dx + (squareWidth + padding) * i;
        double yOffset = canvasActualTopLeft.dy + (squareHeight + padding) * j;
        
        _drawGameSquare(
          canvas,
          squareWidth,
          squareHeight,
          canvasActualTopLeft,
          padding,
          i,
          j,
          overallTranslation,
        );

        _drawGameSquare(
          canvas,
          squareWidth,
          squareHeight,
          canvasActualTopLeft,
          padding,
          i,
          j,
          overallTranslation,
          solution: true,
        );
      }
    }
  }

  void _drawGameSquare(
    Canvas canvas,
    double squareWidth,
    double squareHeight,
    Offset canvasActualTopLeft,
    double padding,
    int xIndex,
    int yIndex,
    Offset overallTranslation,
    {bool solution=false,}
  ){
    List<List<GridItem>> gridToPullFrom = solution ? gameState.solutionGrid : gameState.grid;

    double scale = solution ? 0.25 : 0.8;
    double scaledSquareWidth = squareWidth * scale;
    double scaledSquareHeight = squareHeight * scale;
    double scaledXOffset = canvasActualTopLeft.dx + (squareWidth + padding) * xIndex + squareWidth/10;
    double scaledYOffset = canvasActualTopLeft.dy + (squareHeight + padding) * yIndex + squareHeight/10;

    Paint p = Paint()
      ..style = PaintingStyle.fill;
    Path scaledPath = gridToPullFrom[xIndex][yIndex].kind.shape.transform(Matrix4.diagonal3Values(scaledSquareWidth, scaledSquareHeight, 1.0).storage);
    canvas.save();
    canvas.translate(scaledXOffset + (squareWidth-scaledSquareWidth)/2, scaledYOffset + (squareHeight-scaledSquareHeight)/2);
    canvas.drawPath(
      scaledPath,
      p
        ..color = gridToPullFrom[xIndex][yIndex].kind.color.withAlpha(solution ? 175 : 255)
    );
    canvas.restore();

    if (gameState.initialGrid[xIndex][yIndex].kind==GridItemKind.BLANK){
      p = Paint()
        ..style = PaintingStyle.fill
        ..color = Color.fromARGB(100, 150,150,150);
    } else {
      p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Color.fromARGB(255, 235,235,235);
    }
    canvas.save();
    canvas.translate(scaledXOffset , scaledYOffset );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(squareWidth/2, squareHeight/2), 
        width: squareWidth, 
        height: squareHeight,
      ),
      p,
    );
    canvas.restore();

    if (!solution){
      squareRects.add(
        Rect.fromCenter(
          center: Offset(
            overallTranslation.dx + scaledXOffset + squareWidth/2, 
            overallTranslation.dy + scaledYOffset + squareHeight/2,
          ), 
          width: squareWidth, 
          height: squareHeight
        )
      );
    }
  }

  void _drawGameSquareWithExactPos(
    Canvas canvas,
    GridItemKind item,
    double squareWidth,
    double squareHeight,
    double xPos,
    double yPos,
  ){
    double scale = 0.5;
    double scaledSquareWidth = squareWidth * scale;
    double scaledSquareHeight = squareHeight * scale;

    Paint p = Paint()
      ..style = PaintingStyle.fill;
    Path scaledPath = item.shape.transform(Matrix4.diagonal3Values(scaledSquareWidth, scaledSquareHeight, 1.0).storage);
    canvas.save();
    canvas.translate(xPos + squareWidth/4, yPos + squareHeight/4);
    canvas.drawPath(
      scaledPath,
      p
        ..color = item.color
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    double aspectRatio = 1;

    Offset overallTranslation = Offset.zero;

    double scale = 1-1.5*(1/gameState.gridDims.item1);
    
    // centralise the grid on the screen
    canvas.save();
    canvas.translate((size.width-size.width*scale)/2, (size.height-size.height*scale)/2);
    overallTranslation += Offset((size.width-size.width*scale)/2, (size.height-size.height*scale)/2);
    // move it up to make space for the other buttons
    // canvas.translate(0,-(size.height-size.height*scale)/4);
    size = Size(size.width*scale, size.height*scale);

    double maxHeight = size.width * aspectRatio;
    double maxWidth = size.height * (1/aspectRatio);
    canvas.drawRect(
      Rect.fromLTWH(
        0, 
        (size.height - maxHeight)/2, 
        size.width, 
        maxHeight
      ), 
      Paint()..color = Color.fromARGB(255, 240, 240, 240)
    );

    if (!canSave){
      canvas.drawRect(
        Rect.fromLTWH(
          0, 
          (size.height - maxHeight)/2, 
          size.width, 
          maxHeight
        ), 
        Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = maxHeight/100
        ..color = Color.fromARGB(255, 0, 255, 123)
      );
    }

    _drawGameOverallUI(canvas, Offset(0, (size.height - maxHeight)/2), Size(size.width, maxHeight));

    _drawGameGrid(
      canvas, 
      size,
      Offset(0, (size.height - maxHeight)/2),
      Size(size.width, maxHeight),
      overallTranslation
    );

    _drawGameRules(
      canvas, 
      size,
      Offset(0, (size.height - maxHeight)/2),
      Size(size.width, maxHeight),
      overallTranslation,
    );

    canvas.translate(-(size.width-size.width*scale)/2, -(size.height-size.height*scale)/2);

    canvas.restore();
    // _drawAllRectHitboxes(canvas);
    // _drawPointer(canvas);
  }

  void _drawGameRules(
    Canvas canvas, 
    Size size,
    Offset canvasActualTopLeft,
    Size canvasActualSize,
    Offset overallTranslation,
  ){
    ruleRects.removeWhere((e)=>true);
    for (int i = 0; i < gameState.rules.length; i++) {
      GameRule rule = gameState.rules[i];
      if (rule.kind == RuleKind.COLUMN){
        double xPos = rule.ruleKindIndex*(canvasActualSize.width / gameState.gridDims.item1) + canvasActualTopLeft.dx; 
        double yPos = canvasActualTopLeft.dy;
        double cellWidth = canvasActualSize.width / gameState.gridDims.item1;
        double cellHeight = canvasActualSize.height / gameState.gridDims.item2;
        _drawRulesIcon(canvas, rule, xPos, yPos-cellHeight, cellWidth, overallTranslation, i);
        _drawRulesIcon(canvas, rule, xPos, yPos-cellHeight + (canvasActualSize.height+cellHeight), cellWidth, overallTranslation, i, provideBoundRect:false,); 
      }
      if (rule.kind == RuleKind.ROW){
        double xPos = canvasActualTopLeft.dx; 
        double yPos = rule.ruleKindIndex*(canvasActualSize.height / gameState.gridDims.item2) + canvasActualTopLeft.dy; 
        double cellWidth = canvasActualSize.width / gameState.gridDims.item1;
        double cellHeight = canvasActualSize.height / gameState.gridDims.item2;
        _drawRulesIcon(canvas, rule, xPos-cellWidth, yPos, cellWidth, overallTranslation, i);
        _drawRulesIcon(canvas, rule, xPos-cellWidth + (canvasActualSize.width+cellWidth), yPos, cellWidth, overallTranslation, i, provideBoundRect:false); 
      }
    }
  }

  void _drawRulesIcon(
    Canvas canvas,
    GameRule rule,
    double xPos,
    double yPos,
    double cellSize,
    Offset overallTranslation,
    int ruleIndex,
    {bool provideBoundRect=true,}
  ){
    if (gameState.rules.indexOf(rule) == pressedRule){
      xPos = xPos + (pressedRulePosition?.dx ?? 0);
      yPos = yPos + (pressedRulePosition?.dy ?? 0);
    }
    // canvas.drawRect(
    //   Rect.fromLTWH(
    //     xPos, 
    //     yPos, 
    //     cellSize, 
    //     cellSize
    //   ), 
    //   Paint()
    //     ..color = Colors.blue
    //     ..style = PaintingStyle.stroke
    // );
    _drawGameSquareWithExactPos(
      canvas,
      rule.effector,
      cellSize,
      cellSize,
      xPos,
      yPos,
    );
    _drawGameRuleEffect(
      canvas,
      rule.effect,
      rule.effector,
      cellSize,
      cellSize,
      xPos,
      yPos,
      overallTranslation,
      provideBoundRect:provideBoundRect,
    );
    if (rule.effector!=GridItemKind.BLANK){
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: ruleIndex.toString(),
          style: TextStyle(
            color: Colors.black, 
            fontSize: 10,
            fontWeight: FontWeight.bold
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(
          xPos+cellSize*0.5 - textPainter.width/2, 
          yPos+cellSize*0.1 - textPainter.height/2,
        )
      );
    }
  }

  void _drawGameRuleEffect(
    Canvas canvas,
    EffectKind effect,
    GridItemKind effector,
    double squareWidth,
    double squareHeight,
    double xPos,
    double yPos,
    Offset overallTranslation,
    {bool provideBoundRect=true,}
  ){
    Offset effectCenter = Offset(xPos+squareWidth/2,yPos+squareHeight/2);

    double scale = 0.31;
    double scaledSquareWidth = squareWidth * scale*(1/100);
    double scaledSquareHeight = squareHeight * scale*(1/100);

    Paint p = Paint()
      ..style = PaintingStyle.fill;
    Path scaledPath = effect.shape.transform(Matrix4.diagonal3Values(scaledSquareWidth, scaledSquareHeight, 1.0).storage);
    canvas.save();
    canvas.translate(effectCenter.dx-(squareWidth*scale)/2, effectCenter.dy-(squareHeight*scale)/2);

    if (effector!=GridItemKind.BLANK){
      canvas.drawPath(
        scaledPath,
        p
          ..color = Colors.black
      );
    }

    canvas.restore();
    if (provideBoundRect){
      ruleRects.add(
        Rect.fromCenter(
          center: Offset(
            overallTranslation.dx + effectCenter.dx, 
            overallTranslation.dy + effectCenter.dy,
          ), 
          width: squareWidth, 
          height: squareHeight
        )
      );
    }
  }

  void _drawAllRectHitboxes(Canvas canvas){
    for (Rect rect in squareRects){
      canvas.drawRect(rect, Paint()..color=Colors.green..style=PaintingStyle.stroke);
    }
    for (Rect rect in ruleRects){
      canvas.drawRect(rect, Paint()..color=Colors.red..style=PaintingStyle.stroke);
    }
  }

  void _drawPointer(Canvas canvas){
    canvas.drawCircle(lastPositionOfPointer??Offset(0,0), 10, Paint()..color=Colors.purple);
  }

  void _drawGameOverallUI(
    Canvas canvas, 
    Offset canvasActualTopLeft,
    Size size
  ){
    if (gamePaused){
      canvas.drawRect(
        Rect.fromCenter(
          center: canvasActualTopLeft + Offset(size.width/3, size.height/2), 
          width: size.width/4, 
          height: size.height*0.8
        ),
        Paint()..color=Colors.black.withAlpha(30)
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: canvasActualTopLeft + Offset(2*size.width/3, size.height/2), 
          width: size.width/4, 
          height: size.height*0.8
        ),
        Paint()..color=Colors.black.withAlpha(30)
      );
    }
  }

  @override
  bool shouldRepaint(covariant GameCanvas oldDelegate) {
    bool goingToRepaint = !gameState.equals(oldDelegate.gameState);
    // print(goingToRepaint);
    return true;//goingToRepaint;
  }
}