// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:mobile_puzzle_game/data/grid_item.dart';

enum RuleKind{
  BLANK,
  COLUMN,
  ROW,
}

enum EffectKind{
  MOVE_UP,
  MOVE_DOWN,
  MOVE_LEFT,
  MOVE_RIGHT,
  SWAP_UP,
  SWAP_DOWN,
  SWAP_LEFT,
  SWAP_RIGHT,
  DUPLICATE_UP,
  DUPLICATE_DOWN,
  DUPLICATE_LEFT,
  DUPLICATE_RIGHT,
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

  static GameRule random(){
    final random = Random();
    return GameRule(
      RuleKind.values[random.nextInt(RuleKind.values.length)],
      GridItemKind.values[random.nextInt(GridItemKind.values.length)],
      EffectKind.values[random.nextInt(EffectKind.values.length)],
      random.nextInt(RuleKind.values.length),
    );
  }
}