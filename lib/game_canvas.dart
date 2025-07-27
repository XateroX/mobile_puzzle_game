import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_puzzle_game/data/game_rule.dart';
import 'package:mobile_puzzle_game/data/game_state.dart';

class GameCanvas extends CustomPainter {
  GameState gameState;
  
  GameCanvas({
    required this.gameState
  });

  void _drawGameGrid(
    Canvas canvas, 
    Size size,
    Offset canvasActualTopLeft,
    Size canvasActualSize,
  ){
    // draw a grid of the game board using the gamestate.grid to get the values to use to draw each square
    double padding = canvasActualSize.width/30; // Padding between squares
    double squareWidth = (canvasActualSize.width / gameState.gridDims.item2) - padding;
    double squareHeight = (canvasActualSize.height / gameState.gridDims.item1) - padding;

    for (int i = 0; i < gameState.grid.length; i++) {
      for (int j = 0; j < gameState.grid[i].length; j++) {
        double xOffset = canvasActualTopLeft.dx + (squareWidth + padding) * j;
        double yOffset = canvasActualTopLeft.dy + (squareHeight + padding) * i;
        
        // Paint p = Paint()
        //   ..style = PaintingStyle.fill;
        // canvas.drawRect(
        //   Rect.fromLTWH(
        //     xOffset, 
        //     yOffset, 
        //     squareWidth, 
        //     squareHeight
        //   ), 
        //   p
        //     ..color = gameState.grid[i][j].color
        // );
        double scale = 0.8;
        double scaledSquareWidth = squareWidth * scale;
        double scaledSquareHeight = squareHeight * scale;
        double scaledXOffset = canvasActualTopLeft.dx + (squareWidth + padding) * j + (squareWidth - scaledSquareWidth) / 2;
        double scaledYOffset = canvasActualTopLeft.dy + (squareHeight + padding) * i + (squareHeight - scaledSquareHeight) / 2;
        
        Paint p = Paint()
          ..style = PaintingStyle.fill;
        Path scaledPath = gameState.grid[i][j].shape.transform(Matrix4.diagonal3Values(scaledSquareWidth, scaledSquareHeight, 1.0).storage);
        canvas.save();
        canvas.translate(scaledXOffset, scaledYOffset);
        canvas.drawPath(
          scaledPath,
          p
            ..color = gameState.grid[i][j].color
        );
        canvas.restore();
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    double aspectRatio = 1;

    double scale = 1-1.5*(1/gameState.gridDims.item1);
    canvas.translate((size.width-size.width*scale)/2, (size.height-size.height*scale)/2);
    size = Size(size.width*scale, size.height*scale);

    double maxHeight = size.width * aspectRatio;
    canvas.drawRect(
      Rect.fromLTWH(
        0, 
        (size.height - maxHeight)/2, 
        size.width, 
        maxHeight
      ), 
      Paint()..color = Color.fromARGB(255, 230, 230, 230)
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
        canvas.drawRect(
          Rect.fromLTWH(
            xPos, 
            yPos-cellHeight, 
            cellWidth, 
            cellHeight
          ), 
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill
        );
        canvas.drawRect(
          Rect.fromLTWH(
            xPos, 
            yPos-cellHeight + (canvasActualSize.height+cellHeight), 
            cellWidth, 
            cellHeight
          ), 
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill
        );
      }
      if (rule.kind == RuleKind.ROW){
        double xPos = canvasActualTopLeft.dx; 
        double yPos = rule.ruleKindIndex*(canvasActualSize.height / gameState.gridDims.item2) + canvasActualTopLeft.dy; 
        double cellWidth = canvasActualSize.width / gameState.gridDims.item1;
        double cellHeight = canvasActualSize.height / gameState.gridDims.item2;
        canvas.drawRect(
          Rect.fromLTWH(
            xPos-cellWidth, 
            yPos, 
            cellWidth, 
            cellHeight
          ), 
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill
        );
        canvas.drawRect(
          Rect.fromLTWH(
            xPos-cellWidth + (canvasActualSize.width+cellWidth), 
            yPos, 
            cellWidth, 
            cellHeight
          ), 
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill
        );      
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}