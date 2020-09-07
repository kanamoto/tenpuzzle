# tenpuzzle

Ten Puzzle application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Stateクラスのなかのbuild関数内では、うまくドラッグできた。

class _MyHomePageState extends State<MyHomePage> {


これを、ドラッグするWidgetを外に定義しようと考えた。

当初は 以下の様に、ドラッグさせたいWidgetをGestureDetectorに包んで、個別に移動処理を組み込もうと考えた。
しかし、これだと、setStateの度に Widgetが生成されるため、位置が毎回初期化されるのと同じことになり、動かなかった。

つまり、ドラッグさせたいWidget郡とと、その座標は別に管理にする必要がある。
buildはあくまで Windowsでいうところの WM_PAINT/onPaintであるので、
更新した座標を引き渡す、という動きになるのが正しい。

class DraggablePanelWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
      return GestureDetector(

      return GestureDetector(
          child : Stack( ...



