import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

enum GridItemKind {
  BLANK,
  A,
  B,
  C,
}

class GridItem{
  GridItemKind kind;
  Path get shape {
    switch (kind) {
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

  Color get color => switch(kind){
    GridItemKind.BLANK => Colors.white,
    GridItemKind.A => Color.fromARGB(255, 255, 180, 180),
    GridItemKind.B => Color.fromARGB(255, 152, 249, 159),
    GridItemKind.C => Color.fromARGB(255, 107, 159, 255)
  };

  GridItem(this.kind);

  static blank(){
    return GridItem(
      GridItemKind.BLANK
    );
  }


  static random(){
    Random random = Random();
    return GridItem(
      GridItemKind.values[
        random.nextInt(GridItemKind.values.length)
      ]
    );
  }
}

class Math {
}