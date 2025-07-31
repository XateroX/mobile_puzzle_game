import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_puzzle_game/data/game_rule.dart';
import 'package:mobile_puzzle_game/data/grid_item.dart';
import 'package:tuple/tuple.dart';

class GameState {
  List<GameRule> rules;
  List<List<GridItem>> grid;

  List<GameRule> currentLevelRules = [];
  List<List<GridItem>> currentLevelGrid = [];
  List<List<GridItem>> solutionGrid = [];

  Tuple2<int,int> gridDims = Tuple2(5,5);

  int gameTickSolutionAmount = 30;

  GameState({
    this.rules = const [],
    this.grid = const [],
  }){
    // grid = getBlankBoard();
    // rules = getRandomRules();
    generateLevel();
  }

  List<List<GridItem>> gridCopy(List<List<GridItem>> existingGrid){
    List<List<GridItem>> newGrid = [];
    for (List<GridItem> itemCol in existingGrid){
      newGrid.add([]);
      for (GridItem item in itemCol){
        newGrid.last.add(item.copy());
      }
    }
    return newGrid;
  }

  void generateLevel(){
    currentLevelGrid = getRandomBoard();
    currentLevelRules = getRandomRules();
    restartLevel();

    for (int i = 0; i < gameTickSolutionAmount; i++){
      tickGame();
    }

    solutionGrid = gridCopy(grid);
    restartLevel();
    for (int i = 0; i < 100; i++){
      int rule1Ind = Random().nextInt(rules.length);
      int rule2Ind = Random().nextInt(rules.length);

      GameRule rule1 = rules[rule1Ind].copy();
      GameRule rule2 = rules[rule2Ind].copy();

      rules[rule1Ind].ruleKindIndex = rule2.ruleKindIndex;
      rules[rule1Ind].kind = rule2.kind;

      rules[rule2Ind].ruleKindIndex = rule1.ruleKindIndex;
      rules[rule2Ind].kind = rule1.kind;
    }
    grid = getBlankBoard();
    currentLevelGrid = getBlankBoard();
    currentLevelRules = [];
    currentLevelRules.addAll(rules.map((rule)=>rule.copy()));
  }

  List<List<GridItem>> getBlankBoard(){
    return List.generate(gridDims.item1, (index) => List.generate(gridDims.item2, (index) => GridItem.blank()));
  }

  void initBlankRules(){
    rules = [];
  }

  List<List<GridItem>> getRandomBoard(){
    List<List<GridItem>> newGrid = List.generate(gridDims.item1, (index) => List.generate(gridDims.item2, (index) => GridItem.random()));
    return newGrid;
  }

  List<GameRule> getRandomRules(){
    List<GameRule> newRules = [];
    for (int colInd = 0; colInd < gridDims.item1; colInd++){
      newRules.add(GameRule.random(gridDims, RuleKind.COLUMN, null, colInd));
    }

    for (int rowInd = 0; rowInd < gridDims.item2; rowInd++){
      newRules.add(GameRule.random(gridDims, RuleKind.ROW, rowInd, null));
    }

    return newRules;
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

  void restartLevel(){
    grid = [];
    for (List<GridItem> itemCol in currentLevelGrid){
      grid.add([]);
      for (GridItem item in itemCol){
        grid.last.add(item.copy());
      }
    }
    rules = [];
    for (GameRule rule in currentLevelRules){
      rules.add(rule.copy());
    }
  }

  void tickGame(){
    print("TICK");
    List<List<GridItem>> nextOverallgameGrid = getBlankBoard();

    List<List<List<GridItem>>> gridNextList = [];
    for (var itemCol in grid) {
      for (var item in itemCol) {
        List<List<GridItem>> blankBoard = getBlankBoard();
        gridNextList.add(blankBoard);
      }
    }

    for (var itemCol in grid) {
      for (var item in itemCol) {
        if (item.kind!=GridItemKind.BLANK){
          int x = grid.indexOf(itemCol);
          int y = itemCol.indexOf(item);
          List<List<GridItem>> newGrid = _applyAllRulesForSquare(x,y, grid);
          gridNextList[gridDims.item1*x+y] = newGrid;
        }
      }
    }

    for (int x = 0; x < gridDims.item1; x++){
      for (int y = 0; y < gridDims.item2; y++){
        List<GridItem> nextInThisPosition = [];
        for (List<List<GridItem>> nextGrid in gridNextList){
          GridItem nextGridPositionOption = nextGrid[x][y].copy();
          if (nextGridPositionOption.kind!=GridItemKind.BLANK){
            nextInThisPosition.add(nextGridPositionOption);
          }
        }
        if (nextInThisPosition.length==1){
          nextOverallgameGrid[x][y] = nextInThisPosition.first.copy();
        } else if(nextInThisPosition.length > 1) {
          int highestPriority = nextInThisPosition.map(
            (item)=>item.kind.priority
          ).toList().reduce((a,b)=>max(a,b));
          nextOverallgameGrid[x][y] = switch (highestPriority) {
            1 => GridItem(GridItemKind.C),
            3 => GridItem(GridItemKind.B),
            4 => GridItem(GridItemKind.A),
            _ => GridItem(GridItemKind.BLANK),
          };
        }
      }
    }
    print("");
    grid = nextOverallgameGrid;
  }

  List<List<GridItem>> _applyAllRulesForSquare(
    int x, 
    int y,
    List<List<GridItem>> gridToApplyTo,
  ){
    List<List<GridItem>> newGrid = getBlankBoard();
    // for (var itemCol in gridToApplyTo) {
    //   newGrid.add([]);
    //   for (var item in itemCol) {
    //     newGrid.last.add(item.copy());
    //   }
    // }
    newGrid[x][y] = gridToApplyTo[x][y].copy();
    
    for (GameRule rule in rules){
      if (
        (
          (rule.kind==RuleKind.COLUMN && rule.ruleKindIndex==x) ||
          (rule.kind==RuleKind.ROW && rule.ruleKindIndex==y) 
        ) && 
        (
          rule.effector!=GridItemKind.BLANK &&
          rule.kind!=RuleKind.BLANK
        )
      ){
        if (rule.effector==gridToApplyTo[x][y].kind){
          newGrid = _applyGameRule(rule, newGrid);
          print("");
        }
      }
    }

    return newGrid;
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
      case EffectKind.CYCLE_UP:
        gridToApplyTo = _applyCycle(rule.kind,rule.ruleKindIndex,rule.effector,true,gridToApplyTo);
      case EffectKind.CYCLE_DOWN:
        gridToApplyTo = _applyCycle(rule.kind,rule.ruleKindIndex,rule.effector,false,gridToApplyTo);
      case EffectKind.DUPLICATE_UP:
        gridToApplyTo = _applyDuplicate(rule.kind,rule.ruleKindIndex,rule.effector,rule.effect.vector,gridToApplyTo);
      case EffectKind.DUPLICATE_DOWN:
        gridToApplyTo = _applyDuplicate(rule.kind,rule.ruleKindIndex,rule.effector,rule.effect.vector,gridToApplyTo);
      case EffectKind.DUPLICATE_LEFT:
        gridToApplyTo = _applyDuplicate(rule.kind,rule.ruleKindIndex,rule.effector,rule.effect.vector,gridToApplyTo);
      case EffectKind.DUPLICATE_RIGHT:
        gridToApplyTo = _applyDuplicate(rule.kind,rule.ruleKindIndex,rule.effector,rule.effect.vector,gridToApplyTo);
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
    List<List<GridItem>> gridNext = [];
    for (var itemRow in gridToApplyTo) {
      gridNext.add([]);
      for (var item in itemRow) {
        gridNext.last.add(item.copy());
      }
    }

    switch (ruleKind) {
      case RuleKind.ROW:
        for (int i = 0; i < gridToApplyTo.length; i++){
          if (gridToApplyTo[i][index].kind == itemKind){
            gridNext
            [
              (i+vector.item1)%gridToApplyTo.length
            ]
            [
              (index+vector.item2)%gridToApplyTo[(i+vector.item1)%gridToApplyTo.length].length
            ] = gridToApplyTo[i][index].copy();

            gridNext[i][index] = GridItem.blank();
          }
        }
        break;
      case RuleKind.COLUMN:
        for (int i = 0; i < gridToApplyTo[index].length; i++){
          if (gridToApplyTo[index][i].kind == itemKind){
            gridNext
            [
              (index+vector.item1)%gridToApplyTo.length
            ]
            [
              (i+vector.item2)%gridToApplyTo[(index+vector.item1)%gridToApplyTo.length].length
            ] = gridToApplyTo[index][i].copy();

            gridNext[index][i] = GridItem.blank();
          }
        }
        break;
      default:
    }

    return gridNext;
  }


  List<List<GridItem>> _applyDuplicate(
    RuleKind ruleKind,
    int index,
    GridItemKind itemKind,
    Tuple2<int,int> vector,
    List<List<GridItem>> gridToApplyTo,
  ){
    List<List<GridItem>> gridNext = [];
    for (var itemRow in gridToApplyTo) {
      gridNext.add([]);
      for (var item in itemRow) {
        gridNext.last.add(item.copy());
      }
    }

    switch (ruleKind) {
      case RuleKind.ROW:
        for (int i = 0; i < gridToApplyTo.length; i++){
          if (gridToApplyTo[i][index].kind == itemKind){
            gridNext
            [
              (i+vector.item1)%gridToApplyTo.length
            ]
            [
              (index+vector.item2)%gridToApplyTo[(i+vector.item1)%gridToApplyTo.length].length
            ] = gridToApplyTo[i][index].copy();
          }
        }
        break;
      case RuleKind.COLUMN:
        for (int i = 0; i < gridToApplyTo[index].length; i++){
          if (gridToApplyTo[index][i].kind == itemKind){
            gridNext
            [
              (index+vector.item1)%gridToApplyTo.length
            ]
            [
              (i+vector.item2)%gridToApplyTo[(index+vector.item1)%gridToApplyTo.length].length
            ] = gridToApplyTo[index][i].copy();
          }
        }
        break;
      default:
    }

    return gridNext;
  }


  List<List<GridItem>> _applyCycle(
    RuleKind ruleKind,
    int index,
    GridItemKind itemKind,
    bool cycleUp,
    List<List<GridItem>> gridToApplyTo,
  ){
    List<List<GridItem>> gridNext = [];
    for (var itemRow in gridToApplyTo) {
      gridNext.add([]);
      for (var item in itemRow) {
        gridNext.last.add(item.copy());
      }
    }

    switch (ruleKind) {
      case RuleKind.ROW:
        for (int i = 0; i < gridToApplyTo.length; i++){
          if (gridToApplyTo[i][index].kind == itemKind){
            gridNext[i][index] = gridToApplyTo[i][index].copy();
            gridNext[i][index].cycleKind(cycleUp:cycleUp);
          }
        }
        break;
      case RuleKind.COLUMN:
        for (int i = 0; i < gridToApplyTo[index].length; i++){
          if (gridToApplyTo[index][i].kind == itemKind){
            if (gridToApplyTo[index][i].kind == itemKind){
              gridNext[index][i] = gridToApplyTo[index][i].copy();
              gridNext[index][i].cycleKind(cycleUp:cycleUp);
            }
          }
        }
        break;
      default:
    }

    return gridNext;
  }
}