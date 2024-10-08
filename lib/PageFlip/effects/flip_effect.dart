import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PageFlipEffect extends CustomPainter {
  PageFlipEffect({
    required this.amount,
    required this.image,
    this.backgroundColor,
    this.radius = 0.18,
    required this.isRightSwipe,
  }) : super(repaint: amount);

  final Animation<double> amount;
  final ui.Image image;
  final Color? backgroundColor;
  final double radius;
  final bool isRightSwipe;

//  @override
//   void paint(ui.Canvas canvas, ui.Size size) {
//     final pos = isRightSwipe ? 1.0 - amount.value : amount.value;
//     final movX = isRightSwipe ? pos : (1.0 - pos) * 0.85;
//     final calcR = (movX < 0.20) ? radius * movX * 5 : radius;
//     final wHRatio = 1 - calcR;
//     final hWRatio = image.height / image.width;
//     final hWCorrection = (hWRatio - 1.0) / 2.0;

//     final w = size.width.toDouble();
//     final h = size.height.toDouble();
//     final c = canvas;
//     final shadowXf = (wHRatio - movX);
//     final shadowSigma = isRightSwipe
//         ? Shadow.convertRadiusToSigma(8.0 + (32.0 * shadowXf))
//         : Shadow.convertRadiusToSigma(8.0 + (32.0 * (1.0 - shadowXf)));
//     final pageRect = isRightSwipe
//         ? Rect.fromLTRB(w, 0.0, w * movX, h)
//         : Rect.fromLTRB(0.0, 0.0, w * shadowXf, h);
//     if (backgroundColor != null) {
//       c.drawRect(pageRect, Paint()..color = backgroundColor!);
//     }
//     if (isRightSwipe ? amount.value != 0 : pos != 0) {
//       c.drawRect(
//         pageRect,
//         Paint()
//         //  ..color = Colors.black54
//         ..color = Colors.transparent
//           ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
//       );
//     }

//     final ip = Paint();
//     for (double x = 0; x < size.width; x++) {
//       final xf = (x / w);
//       final baseValue = isRightSwipe
//           ? math.sin(math.pi / 0.5 * (xf - (1.0 - pos)))
//           : math.cos(math.pi / 0.5 * (xf + pos));
//       final v = calcR * (baseValue + 1.1);
//       final xv = isRightSwipe ? (xf * wHRatio) - movX : (xf * wHRatio) + movX;
//       final sx = (xf * image.width);
//       final sr = Rect.fromLTRB(sx, 0.0, sx + 1.0, image.height.toDouble());
//       final yv = ((h * calcR * movX) * hWRatio) - hWCorrection;
//       final ds = (yv * v);
//       final dr = Rect.fromLTRB(xv * w, 0.0 - ds, xv * w + 1.1, h + ds);
//       c.drawImageRect(image, sr, dr, ip);
//     }
//   }

////
  // @override
  // void paint(ui.Canvas canvas, ui.Size size) {
  //   final w = size.width.toDouble();
  //   final h = size.height.toDouble();
  //   final c = canvas;
  //   final pos = isRightSwipe ? amount.value : 1.0 - amount.value;
  //   final offset = pos * w;

  //   // Draw the background if provided
  //   if (backgroundColor != null) {
  //     c.drawRect(Rect.fromLTWH(0.0, 0.0, w, h), Paint()..color = backgroundColor!);
  //   }

  //   final paint = Paint();
  //   final rect = isRightSwipe
  //       ? Rect.fromLTWH(offset, 0, w - offset, h)
  //       : Rect.fromLTWH(0, 0, w - offset, h);

  //   c.drawImageRect(image, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), rect, paint);

  //   final clippedRect = isRightSwipe
  //       ? Rect.fromLTWH(0, 0, offset, h)
  //       : Rect.fromLTWH(w - offset, 0, offset, h);

  //   c.save();
  //   c.clipRect(clippedRect);
  //   c.drawImageRect(image, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), Rect.fromLTWH(0, 0, w, h), paint);
  //   c.restore();
  // }
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final w = size.width.toDouble();
    final h = size.height.toDouble();
    final c = canvas;
    final pos = isRightSwipe ? amount.value : 1.0 - amount.value;
    final offset = pos * w;

    // Draw the background if provided
    if (backgroundColor != null) {
      c.drawRect(
          Rect.fromLTWH(0.0, 0.0, w, h), Paint()..color = backgroundColor!);
    }

    // Draw a blank page during the flip
    final blankRect = isRightSwipe
        ? Rect.fromLTWH(offset, 0, w - offset, h)
        : Rect.fromLTWH(0, 0, w - offset, h);

    c.drawRect(blankRect, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(PageFlipEffect oldDelegate) {
    return //oldDelegate.image != image ||
        oldDelegate.amount.value != amount.value;
  }
}
