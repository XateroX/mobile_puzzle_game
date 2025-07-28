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
    initRandomBoard();
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
}