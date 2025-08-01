import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_puzzle_game/main.dart';

enum GridItemKind {
  BLANK,
  A,
  B,
  C,
}

extension GridItemKindExtensions on GridItemKind {
  Path get shape {
    switch (this) {
      case GridItemKind.BLANK:
        return Path();
      case GridItemKind.A:
        return Path()
          ..moveTo(0, 0)
          ..lineTo(1, 0)
          ..lineTo(1, 1)
          ..lineTo(0, 1)
          ..lineTo(0, 0);
      case GridItemKind.B:
        return Path()
          ..moveTo(0.5, 0)
          ..lineTo(1, 1)
          ..lineTo(0, 1)
          ..lineTo(0.5, 0);
      case GridItemKind.C:
        return Path()
          ..addOval(
            Rect.fromCircle(
              center: Offset(0.5, 0.5),
              radius: 0.5,
            ),
          );
    }
  }

  Color get color => switch(this){
    GridItemKind.BLANK => Colors.white,
    GridItemKind.A => Color.fromARGB(255, 255, 180, 180),
    GridItemKind.B => Color.fromARGB(255, 152, 249, 159),
    GridItemKind.C => Color.fromARGB(255, 107, 159, 255)
  };

  int get priority => switch(this){
    GridItemKind.BLANK => 1000,
    GridItemKind.A => 4,
    GridItemKind.B => 3,
    GridItemKind.C => 1
  };
} 

class GridItem{
  GridItemKind kind;

  GridItem(this.kind);

  static blank(){
    return GridItem(
      GridItemKind.BLANK
    );
  }


  static random(){
    return GridItem(
      GridItemKind.values[
        RANDOM_GENERATOR.nextInt(GridItemKind.values.length)
      ]
    );
  }

  void cycleKind(
    {bool cycleUp = true,}
  ){
    if (cycleUp){
      kind = switch (kind) {
        GridItemKind.BLANK => GridItemKind.A,
        GridItemKind.A => GridItemKind.B,
        GridItemKind.B => GridItemKind.C,
        GridItemKind.C => GridItemKind.BLANK,
      };
    } else {
      kind = switch (kind) {
        GridItemKind.BLANK => GridItemKind.C,
        GridItemKind.A => GridItemKind.BLANK,
        GridItemKind.B => GridItemKind.A,
        GridItemKind.C => GridItemKind.B,
      };
    }
  }

  GridItem copy(){
    return GridItem(
      kind
    );
  }
}