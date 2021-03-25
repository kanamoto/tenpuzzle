import 'package:flutter/material.dart';

class MeasureWidget extends StatelessWidget {

  final double _width;
  final double _height;

  MeasureWidget(this._width , this._height);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      child: CustomPaint(
        painter: MeasurePainter(_width , _height),
        child: Container(),
      ),
    );
  }
}

class MeasurePainter extends CustomPainter
{

  double _width = 0.0;
  double _height = 0.0;

  static const double _MEASURE_WIDTH  = 50.0;
  static const double _MEASURE_HEIGHT  = 50.0;

  static const double _MEASURE_LINE_WIDTH = 2.0;

  MeasurePainter(this._width , this._height);

  @override
  void paint(Canvas canvas, Size size) {

    var paint = Paint();

    // 四角（塗りつぶし）

    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.fill;//  .d.stroke;
    paint.strokeWidth = _MEASURE_LINE_WIDTH;
//    paint.color = Colors.cyan[700];//black54;
    paint.color = Colors.teal ; //Colors.black26;//.cyan[700];//black54;

    Size rectSize = Size(_MEASURE_WIDTH , _MEASURE_HEIGHT);
    for ( double x = 0 ; x < this._width ; x += rectSize.width ){
      for ( double y = 0 ; y < this._height ; y += rectSize.height ) {
        var path = Path();
        path.moveTo(x                  , y); // 左上
        path.lineTo(x                  , y + rectSize.height); // 左下
        path.lineTo(x + rectSize.width , y + rectSize.height); // 右下
        path.lineTo(x + rectSize.width , y ); // 右上
        path.close(); // パスを閉じる
        canvas.drawPath(path, paint);
      }
    }

    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = _MEASURE_LINE_WIDTH;
//    paint.color = Colors.cyan[300];//black54;
    paint.color = Colors.black12;// .cyan[300];//black54;

    for ( double x = 0 ; x < this._width ; x += rectSize.width ){
      for ( double y = 0 ; y < this._height ; y += rectSize.height ) {
        var path = Path();
        path.moveTo(x                  , y); // 左上
        path.lineTo(x                  , y + rectSize.height); // 左下
        path.lineTo(x + rectSize.width , y + rectSize.height); // 右下
        path.lineTo(x + rectSize.width , y ); // 右上
        path.close(); // パスを閉じる
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
