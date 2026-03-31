import 'package:flutter/cupertino.dart';

class ZigZagClipper extends CustomClipper<Path> {
  const ZigZagClipper({this.zigHeight = 4.0, this.count = 7});

  final double zigHeight;
  final int count;

  @override
  Path getClip(Size size) {
    final double z = zigHeight;
    final double w = size.width;
    final double h = size.height;
    final double tw = w / count;

    final p = Path();

    p.moveTo(0, z);
    for (int i = 0; i < count; i++) {
      p.lineTo(tw * (i + 0.5), 0);
      p.lineTo(tw * (i + 1), z);
    }

    p.lineTo(w, h - z);

    for (int i = count; i > 0; i--) {
      p.lineTo(tw * (i - 0.5), h);
      p.lineTo(tw * (i - 1), h - z);
    }

    p.lineTo(0, z);
    p.close();

    return p;
  }

  @override
  bool shouldReclip(ZigZagClipper old) =>
      old.zigHeight != zigHeight || old.count != count;
}