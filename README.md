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

・Flutterによるアプリケーションの作り方
・ウィジットの使い方
・ユーザー操作の受け取り方法
・画面遷移
・アニメーション
・音の鳴らし方
・データの永続化
・クラス間のデータ通信
・タイマー機能(クリア時間)
・クリア記録の保存

残件
・途中状態のセーブ
・任意の数字によるプレイ



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





## ファイルをimportしても、元の依存関係を継承するわけではない。必要な定義はファイル毎につどimportする。



## await /async

## awaitは、futureの実行を待つ。
関数にasyncをつけると中でawaitを呼べる。ただし、関数そのものは非同期となる。awaitで待つのは関数の中のみ。


