import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_puzzle_game/data/game_rule.dart';
import 'package:mobile_puzzle_game/data/grid_item.dart';
import 'package:tuple/tuple.dart';

class GameState {
  List<GameRule> rules;
  List<List<GridItem>> grid;
  Tuple2<int,int> gridDims = Tuple2(5,5);

  GameState({
    this.rules = const [],
    this.grid = const [],
  }){
    initBlankBoard();
    initRandomRules();
  }


  void initBlankBoard(){
    grid = List.generate(gridDims.item1, (index) => List.generate(gridDims.item2, (index) => GridItem.blank()));
  }

  void initBlankRules(){
    rules = [];
  }

  void initRandomBoard(){
    grid = List.generate(gridDims.item1, (index) => List.generate(gridDims.item2, (index) => GridItem.random()));
  }

  void initRandomRules(){
    rules = [];
    for (int colInd = 0; colInd < gridDims.item1; colInd++){
      rules.add(GameRule.random(gridDims, RuleKind.COLUMN, null, colInd));
    }

    for (int rowInd = 0; rowInd < gridDims.item2; rowInd++){
      rules.add(GameRule.random(gridDims, RuleKind.ROW, rowInd, null));
    }
  }

  bool equals(GameState other) {
    // Compare grid dimensions
    if (gridDims.item1 != other.gridDims.item1 ||
        gridDims.item2 != other.gridDims.item2) {
      return false;
    }

    // Compare rules length and values
    if (rules.length != other.rules.length) return false;
    for (int i = 0; i < rules.length; i++) {
      if (rules[i] != other.rules[i]) return false;
    }

    // Compare grid contents
    if (grid.length != other.grid.length) return false;
    for (int x = 0; x < grid.length; x++) {
      if (grid[x].length != other.grid[x].length) return false;
      for (int y = 0; y < grid[x].length; y++) {
        if (grid[x][y] != other.grid[x][y]) return false;
      }
    }

    return true;
  }

  void tickGame(){
    print("TICK");

    List<List<GridItem>> gridNext = [];
    for (var itemRow in grid) {
      gridNext.add([]);
      for (var item in itemRow) {
        gridNext.last.add(item.copy());
      }
    }

    for (GameRule rule in rules) {
      if (rule.effector != GridItemKind.BLANK){
        gridNext = _applyGameRule(rule, gridNext);
      }
    }

    grid = gridNext;
  }

  List<List<GridItem>> _applyGameRule(
    GameRule rule, 
    List<List<GridItem>> gridToApplyTo,
  ){
    switch (rule.effect) {
      case EffectKind.MOVE_UP:
        gridToApplyTo = _applyMove(rule.kind,rule.ruleKindIndex,rule.effector,rule.effect.vector,gridToApplyTo);
      case EffectKind.MOVE_DOWN:
        gridToApplyTo = _applyMove(rule.kind,rule.ruleKindIndex,rule.effector,rule.effect.vector,gridToApplyTo);
      case EffectKind.MOVE_LEFT:
        gridToApplyTo = _applyMove(rule.kind,rule.ruleKindIndex,rule.effector,rule.effect.vector,gridToApplyTo);
      case EffectKind.MOVE_RIGHT:
        gridToApplyTo = _applyMove(rule.kind,rule.ruleKindIndex,rule.effector,rule.effect.vector,gridToApplyTo);
      case EffectKind.SWAP_UP:
        break;
      case EffectKind.SWAP_DOWN:
        break;
      case EffectKind.SWAP_LEFT:
        break;
      case EffectKind.SWAP_RIGHT:
        break;
      case EffectKind.DUPLICATE_UP:
        break;
      case EffectKind.DUPLICATE_DOWN:
        break;
      case EffectKind.DUPLICATE_LEFT:
        break;
      case EffectKind.DUPLICATE_RIGHT:
        break;
      default:
    }
    return gridToApplyTo;
  }

  List<List<GridItem>> _applyMove(
    RuleKind ruleKind,
    int index,
    GridItemKind itemKind,
    Tuple2<int,int> vector,
    List<List<GridItem>> gridToApplyTo,
  ){
    // NEED TO IMPLEMENT A 2 GRID SYSTEM, ONE FOR READ ONE FOR WRITE //
    switch (ruleKind) {
      case RuleKind.COLUMN:
        for (int i = 0; i < gridToApplyTo.length; i++){
          if (gridToApplyTo[i][index].kind == itemKind){
            gridToApplyTo
            [
              (i+vector.item2)%gridToApplyTo.length
            ]
            [
              (index+vector.item1)%gridToApplyTo[(i+vector.item1)%gridToApplyTo.length].length
            ].kind = gridToApplyTo[i][index].kind;

            gridToApplyTo[i][index].kind = GridItemKind.BLANK;
          }
        }
        break;
      case RuleKind.ROW:
        for (int i = 0; i < gridToApplyTo[index].length; i++){
          if (gridToApplyTo[index][i].kind == itemKind){
            gridToApplyTo
            [
              (index+vector.item2)%gridToApplyTo.length
            ]
            [
              (i+vector.item1)%gridToApplyTo[(index+vector.item1)%gridToApplyTo.length].length
            ].kind = gridToApplyTo[index][i].kind;

            gridToApplyTo[index][i].kind = GridItemKind.BLANK;
          }
        }
        break;
      default:
    }

    return gridToApplyTo;
  }
}