# tenpuzzle

Ten Puzzle application.




テンパズルは、1桁の数字4つと四則演算を使って、10を作るパズルです
"TEN PUZZLE" is a puzzle that uses four single-digit numbers and the four arithmetic operations to make ten.

例 2,4,7,8 => (8 - 7 + 4) × 2

| +| Addition |
| -| subtraction |
| ×| multiplication |
| /| division |
| (| Open parentheses |
| )| Closed parentheses |


複数の数字を続けても、1桁より大きな数字にはなりません。
Multiple numbers in a row cannot be larger than one digit.


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
・途中状態のセーブ
　候補文字列の表示
・継続時の不具合
　タイマーが止まらないことがあった

残件
・任意の数字によるプレイ
・ゲーム中のデザイン
　正解時の表示(ダイアログはやめて、画面に出したい)
・正解データを集約したい(Firebase )


Stateクラスのなかのbuild関数内では、うまくドラッグできた。

class _MyHomePageState extends State<MyHomePage> {


これを、ドラッグするWidgetを外に定義しようと考えた。

当初は 以下の様に、ドラッグさせたいWidgetをGestureDetectorに包んで、個別に移動処理を組み込もうと考えた。
しかし、これだと、setStateの度に Widgetが生成されるため、位置が毎回初期化されるのと同じことになり、動かなかった。

つまり、ドラッグさせたいWidget群と、その座標は別に管理にする必要がある。
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
このため、awaitで呼んでいた関数をリファクタリングなどで別の関数に移動すると、実行順序が変わる。


## Widgetは、keyの一致を持って一緒とみなしている。
 AnimateedPositionで、位置を移動していないのに更新されるものがあった。
 これは、x/yは更新していないが、z-index、つまりWidgte上の上下関係が変わっていた。
 このため位置は変わらないが移動が発生した。
 これを防ぐには、AnimatedPositionの連続性を絶つ必要があった。連続していなければ、前回差分からのアニメーションは発生しない。
 そのために、移動が発生しなかったWidgetのkeyを更新して、アニメーションを不要とした。




Thank you for 
Icon https://resizeappicon.com/
auto_size_text:https://pub.dev/packages/auto_size_text
Sound Effects:https://soundeffect-lab.info/
GitHub:https://github.com/flutter/flutter/issues/76393  ;-)
Qiita:https://qiita.com/sh-ogawa/items/94d560d0419433bf1e75


Source code:https://github.com/kanamoto/tenpuzzle/

