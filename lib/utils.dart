
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

Path rotatePath(Path path, double degrees, {Offset? pivot}) {
  final radians = degrees * pi / 180.0;

  // Compute pivot as center if not provided
  final bounds = path.getBounds();
  final cx = pivot?.dx ?? (bounds.left + bounds.width / 2);
  final cy = pivot?.dy ?? (bounds.top + bounds.height / 2);

  final matrix = Matrix4.identity()
    ..translate(cx, cy)
    ..rotateZ(radians)
    ..translate(-cx, -cy);

  return path.transform(matrix.storage);
}