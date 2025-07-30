import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_puzzle_game/data/game_rule.dart';
import 'package:mobile_puzzle_game/data/game_state.dart';
import 'package:mobile_puzzle_game/data/grid_item.dart';

class GameCanvas extends CustomPainter {
  GameState gameState;
  final List<Rect> squareRects;
  
  GameCanvas({
    required this.gameState,
    required this.squareRects,
  });

  void _drawGameGrid(
    Canvas canvas, 
    Size size,
    Offset canvasActualTopLeft,
    Size canvasActualSize,
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
  ){
    double scale = 0.8;
    double scaledSquareWidth = squareWidth * scale;
    double scaledSquareHeight = squareHeight * scale;
    double scaledXOffset = canvasActualTopLeft.dx + (squareWidth + padding) * xIndex + (squareWidth - scaledSquareWidth) / 2;
    double scaledYOffset = canvasActualTopLeft.dy + (squareHeight + padding) * yIndex + (squareHeight - scaledSquareHeight) / 2;

    Paint p = Paint()
      ..style = PaintingStyle.fill;
    Path scaledPath = gameState.grid[yIndex][xIndex].kind.shape.transform(Matrix4.diagonal3Values(scaledSquareWidth, scaledSquareHeight, 1.0).storage);
    canvas.save();
    canvas.translate(scaledXOffset + (squareWidth-scaledSquareWidth)/2, scaledYOffset + (squareHeight-scaledSquareHeight)/2);
    canvas.drawPath(
      scaledPath,
      p
        ..color = gameState.grid[yIndex][xIndex].kind.color
    );
    canvas.restore();

    p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Color.fromARGB(255, 235,235,235);
    canvas.save();
    canvas.translate(scaledXOffset + (squareWidth-scaledSquareWidth)/2, scaledYOffset + (squareHeight-scaledSquareHeight)/2);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(scaledSquareWidth/2, scaledSquareHeight/2), 
        width: squareWidth, 
        height: squareHeight,
      ),
      p,
    );
    canvas.restore();

    squareRects.add(
      Rect.fromCenter(
        center: Offset(
          scaledXOffset + 1.5*squareWidth, 
          scaledYOffset + 2*squareHeight,
        ), 
        width: squareWidth, 
        height: squareHeight
      )
    );
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

    double scale = 1-1.5*(1/gameState.gridDims.item1);
    // centralise the grid on the screen
    canvas.translate((size.width-size.width*scale)/2, (size.height-size.height*scale)/2);
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

    _drawGameGrid(
      canvas, 
      size,
      Offset(0, (size.height - maxHeight)/2),
      Size(size.width, maxHeight)
    );

    _drawGameRules(
      canvas, 
      size,
      Offset(0, (size.height - maxHeight)/2),
      Size(size.width, maxHeight),
    );

    canvas.translate(-(size.width-size.width*scale)/2, -(size.height-size.height*scale)/2);
  }

  void _drawGameRules(
    Canvas canvas, 
    Size size,
    Offset canvasActualTopLeft,
    Size canvasActualSize,
  ){
    for (int i = 0; i < gameState.rules.length; i++) {
      GameRule rule = gameState.rules[i];
      if (rule.kind == RuleKind.COLUMN){
        double xPos = rule.ruleKindIndex*(canvasActualSize.width / gameState.gridDims.item1) + canvasActualTopLeft.dx; 
        double yPos = canvasActualTopLeft.dy;
        double cellWidth = canvasActualSize.width / gameState.gridDims.item1;
        double cellHeight = canvasActualSize.height / gameState.gridDims.item2;
        _drawRulesIcon(canvas, rule, xPos, yPos-cellHeight, cellWidth);
        _drawRulesIcon(canvas, rule, xPos, yPos-cellHeight + (canvasActualSize.height+cellHeight), cellWidth); 
      }
      if (rule.kind == RuleKind.ROW){
        double xPos = canvasActualTopLeft.dx; 
        double yPos = rule.ruleKindIndex*(canvasActualSize.height / gameState.gridDims.item2) + canvasActualTopLeft.dy; 
        double cellWidth = canvasActualSize.width / gameState.gridDims.item1;
        double cellHeight = canvasActualSize.height / gameState.gridDims.item2;
        _drawRulesIcon(canvas, rule, xPos-cellWidth, yPos, cellWidth);
        _drawRulesIcon(canvas, rule, xPos-cellWidth + (canvasActualSize.width+cellWidth), yPos, cellWidth); 
      }
    }
  }

  void _drawRulesIcon(
    Canvas canvas,
    GameRule rule,
    double xPos,
    double yPos,
    double cellSize,
  ){
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
    if (rule.effector!=GridItemKind.BLANK) {
      _drawGameRuleEffect(
        canvas,
        rule.effect,
        cellSize,
        cellSize,
        xPos,
        yPos,
      );
    }
  }

  void _drawGameRuleEffect(
    Canvas canvas,
    EffectKind effect,
    double squareWidth,
    double squareHeight,
    double xPos,
    double yPos,
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
    canvas.drawPath(
      scaledPath,
      p
        ..color = Colors.black
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GameCanvas oldDelegate) {
    bool goingToRepaint = !gameState.equals(oldDelegate.gameState);
    // print(goingToRepaint);
    return true;//goingToRepaint;
  }
}