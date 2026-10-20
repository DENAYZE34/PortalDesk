// Virtual mouse control (on-screen left/right buttons, scroll wheel) has been removed.
// Touch input drives the remote cursor directly; this file now only keeps CursorPaint,
// which draws the remote cursor image and is shared with the desktop client.

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/model.dart';
import 'package:flutter_hbb/utils/image.dart';
import 'package:provider/provider.dart';

class FloatingMouse extends StatelessWidget {
  final FFI ffi;
  const FloatingMouse({
    super.key,
    required this.ffi,
  });

  @override
  Widget build(BuildContext context) => const Offstage();
}

class CursorPaint extends StatelessWidget {
  final double scale;
  CursorPaint({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    final cursorModel = Provider.of<CursorModel>(context);
    double hotx = cursorModel.hotx;
    double hoty = cursorModel.hoty;
    var image = cursorModel.image;
    if (image == null) {
      if (preDefaultCursor.image != null) {
        image = preDefaultCursor.image;
        hotx = preDefaultCursor.image!.width / 2;
        hoty = preDefaultCursor.image!.height / 2;
      }
    }
    if (image == null) {
      return const Offstage();
    }
    assert(scale > 0, 'scale should always be positive');
    if (scale <= 0) {
      return const Offstage();
    }
    return CustomPaint(
      painter: ImagePainter(image: image, x: -hotx, y: -hoty, scale: scale),
    );
  }
}
