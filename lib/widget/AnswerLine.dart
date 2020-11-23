import 'dart:ui';

import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';

class AnswerLineWidget extends StatelessWidget {

  final Offset _from;
  final Offset _to;

  AnswerLineWidget(this._from , this._to);

  @override
  Widget build(BuildContext context) {
    return  CustomPaint(
 //       size: Size.infinite,
        painter: AnswerLinePainter(_from , _to),
        child: Container(),
      );
  }
}

class AnswerLinePainter extends CustomPainter
{
  final Offset _from;
  final Offset _to;

  AnswerLinePainter(this._from , this._to);

  @override
  void paint(Canvas canvas, Size size) {

    // var paint = Paint();
    //
    // paint.color = Colors.black54;
    // var path = Path();
    // path.moveTo(_from.dx , _from.dy);
    // path.lineTo(_to.dx , _to.dy);
    // path.close();
    // canvas.drawPath(path, paint);
      final paint = Paint()
        ..color = Colors.white60//.black54
        ..strokeWidth = 2;
      final paintSide = Paint()
        ..color = Colors.redAccent //.black54
        ..strokeWidth = 4;
      canvas.drawLine(_from, _to, paintSide);
      canvas.drawLine(_from, _to, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

