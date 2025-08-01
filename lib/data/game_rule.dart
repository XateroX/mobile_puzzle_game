// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'dart:ui';

import 'package:mobile_puzzle_game/data/grid_item.dart';
import 'package:mobile_puzzle_game/main.dart';
import 'package:mobile_puzzle_game/utils.dart';
import 'package:tuple/tuple.dart';

import 'package:arrow_path/arrow_path.dart';

enum RuleKind{
  BLANK,
  COLUMN,
  ROW,
}

enum EffectKind {
  MOVE_UP,
  MOVE_DOWN,
  MOVE_LEFT,
  MOVE_RIGHT,
  CYCLE_UP,
  CYCLE_DOWN,
  DUPLICATE_UP,
  DUPLICATE_DOWN,
  DUPLICATE_LEFT,
  DUPLICATE_RIGHT,
}

extension EffectKindExtension on EffectKind {
  Path get shape {
    switch (this) {
      // --- MOVE (simple arrow) ---
      case EffectKind.MOVE_UP:
        return _arrowUp();
      case EffectKind.MOVE_DOWN:
        return _arrowDown();
      case EffectKind.MOVE_LEFT:
        return _arrowLeft();
      case EffectKind.MOVE_RIGHT:
        return _arrowRight();

      // --- SWAP (double arrows) ---
      case EffectKind.CYCLE_UP:
        return _cycleUp();
      case EffectKind.CYCLE_DOWN:
        return _cycleDown();

      // --- DUPLICATE (arrow + plus) ---
      case EffectKind.DUPLICATE_UP:
        return _arrowPlusUp();
      case EffectKind.DUPLICATE_DOWN:
        return _arrowPlusDown();
      case EffectKind.DUPLICATE_LEFT:
        return _arrowPlusLeft();
      case EffectKind.DUPLICATE_RIGHT:
        return _arrowPlusRight();
    }
  }

  Tuple2<int,int> get vector {
    switch (this) {
      case EffectKind.MOVE_UP:
        return Tuple2( 0,-1);
      case EffectKind.MOVE_DOWN:
        return Tuple2( 0, 1);
      case EffectKind.MOVE_LEFT:
        return Tuple2(-1, 0);
      case EffectKind.MOVE_RIGHT:
        return Tuple2( 1, 0);
      case EffectKind.DUPLICATE_UP:
        return Tuple2( 0,-1);
      case EffectKind.DUPLICATE_DOWN:
        return Tuple2( 0, 1);
      case EffectKind.DUPLICATE_LEFT:
        return Tuple2(-1, 0);
      case EffectKind.DUPLICATE_RIGHT:
        return Tuple2( 1, 0);
      default:
        return Tuple2( 0, 0);
    }
  }
}

// Basic arrows:

Path _arrowUp() {
  final p = Path();
  p.moveTo(50, 10);
  p.lineTo(80, 60);
  p.lineTo(60, 60);
  p.lineTo(60, 90);
  p.lineTo(40, 90);
  p.lineTo(40, 60);
  p.lineTo(20, 60);
  p.close();
  return p;
}

Path _arrowDown() {
  final p = rotatePath(_arrowUp(), 180);
  return p;
}

Path _arrowLeft() {
  final p = rotatePath(_arrowUp(), 270);
  return p;
}

Path _arrowRight() {
  final p = rotatePath(_arrowUp(), 90);
  return p;
}

// Double arrows for SWAP:

Path _doubleArrowVertical() {
  Path down = _arrowDown();
  Rect downBounds = down.getBounds();
  Path up = _arrowUp();
  Rect upBounds = up.getBounds();

  final p = Path();
  p.addPath(down, Offset(-(downBounds.bottomRight.dx - downBounds.bottomLeft.dx)/2, 0));
  p.addPath(up, Offset((upBounds.bottomRight.dx - upBounds.bottomLeft.dx)/2, 0));
  return p;
}

Path _doubleArrowHorizontal() {
  Path left = _arrowLeft();
  Rect leftBounds = left.getBounds();
  Path right = _arrowRight();
  Rect rightBounds = right.getBounds();

  final p = Path();
  p.addPath(left, Offset(0, -(leftBounds.bottomRight.dy - leftBounds.topRight.dy)/2));
  p.addPath(right, Offset(0, (rightBounds.bottomRight.dy - rightBounds.topRight.dy)/2));
  return p;
}

// Paths for Cycling

Path _cycleUp() {
  final Path p = _plus();
  return p;
}

Path _cycleDown() {
  final Path p = _minus();
  return p;
}


// Duplicate: arrow + plus sign

Path _plus() {
  final p = Path();
  p.addRect(Rect.fromLTWH(45, 25, 10, 50)); // vertical bar
  p.addRect(Rect.fromLTWH(25, 45, 50, 10)); // horizontal bar
  return p;
}

Path _minus() {
  final p = Path();
  p.addRect(Rect.fromLTWH(25, 45, 50, 10)); // horizontal bar
  return p;
}

Path _arrowPlusUp() {
  Path arrow = _arrowUp();
  Rect arrowBounds = arrow.getBounds();
  Path plus = _plus();
  Rect plusBounds = plus.getBounds();

  final p = Path();
  p.addPath(arrow, Offset(0, 0));
  p.addPath(plus, Offset(1.5*(arrowBounds.bottomRight.dx - arrowBounds.bottomLeft.dx)/2, -(plusBounds.bottomRight.dy - plusBounds.topRight.dy)/2));
  return p;
}

Path _arrowPlusDown() {
  Path arrow = _arrowDown();
  Rect arrowBounds = arrow.getBounds();
  Path plus = _plus();
  Rect plusBounds = plus.getBounds();

  final p = Path();
  p.addPath(arrow, Offset(0, 0));
  p.addPath(plus, Offset(1.5*(arrowBounds.bottomRight.dx - arrowBounds.bottomLeft.dx)/2, -(plusBounds.bottomRight.dy - plusBounds.topRight.dy)/2));
  return p;
}

Path _arrowPlusLeft() {
  Path arrow = _arrowLeft();
  Rect arrowBounds = arrow.getBounds();
  Path plus = _plus();
  Rect plusBounds = plus.getBounds();

  final p = Path();
  p.addPath(arrow, Offset(0, 0));
  p.addPath(plus, Offset(1.5*(arrowBounds.bottomRight.dx - arrowBounds.bottomLeft.dx)/2, -(plusBounds.bottomRight.dy - plusBounds.topRight.dy)/2));
  return p;
}

Path _arrowPlusRight() {
  Path arrow = _arrowRight();
  Rect arrowBounds = arrow.getBounds();
  Path plus = _plus();
  Rect plusBounds = plus.getBounds();

  final p = Path();
  p.addPath(arrow, Offset(0, 0));
  p.addPath(plus, Offset(1.5*(arrowBounds.bottomRight.dx - arrowBounds.bottomLeft.dx)/2, -(plusBounds.bottomRight.dy - plusBounds.topRight.dy)/2));
  return p;
}


class GameRule{
  RuleKind kind;
  GridItemKind effector;
  EffectKind effect;
  int ruleKindIndex;
  
  GameRule(
    this.kind,
    this.effector,
    this.effect,
    this.ruleKindIndex,
  );

  static GameRule random(
    Tuple2<int,int> gridDims,
    RuleKind? ruleKind,
    int? rowInd,
    int? colInd,
  ){
    
    ruleKind = ruleKind ?? RuleKind.values[RANDOM_GENERATOR.nextInt(RuleKind.values.length)];
    GridItemKind gameItemKind = GridItemKind.values[RANDOM_GENERATOR.nextInt(GridItemKind.values.length)];
    EffectKind effectKind = EffectKind.values[RANDOM_GENERATOR.nextInt(EffectKind.values.length)];
    return GameRule(
      ruleKind,
      gameItemKind,
      effectKind,
      (rowInd!=null || colInd!=null) 
        ? (ruleKind==RuleKind.ROW ? rowInd! : colInd!)
        : (ruleKind==RuleKind.ROW ? RANDOM_GENERATOR.nextInt(gridDims.item2) : RANDOM_GENERATOR.nextInt(gridDims.item1)),
    );
  }

  GameRule copy(){
    return GameRule(
      kind,
      effector,
      effect,
      ruleKindIndex,
    );
  }
}