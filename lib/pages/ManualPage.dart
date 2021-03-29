import 'dart:core';

import 'package:flutter/material.dart';
import 'package:tenpuzzle/model/GameModel.dart';

class ManualPage extends StatelessWidget {

  final GameModel _gameModel;

  ManualPage(this._gameModel);

  @override
  Widget build(BuildContext context) {
    return ManualWidget(_gameModel);
  }
}

class ManualWidget extends StatelessWidget {

  final GameModel _gameModel;

  ManualWidget(this._gameModel);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text("Acknowledgments"),),
        body:
        Container(
          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
          width: double.infinity,
          height:double.infinity,
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
            Text('ten puzzle.'),
            Text('Yasuhide Kanamoto'),
            Text('Source code:https://github.com/kanamoto/tenpuzzle/'),
            Divider(color: Colors.grey),
            Text('Acknowledgments.'),
            Text('https://flutter.dev/'),
            Text('AppIcon       :https://resizeappicon.com/'),
            Text('auto_size_text:https://pub.dev/packages/auto_size_text'),
            Text('assets_audio_player:https://pub.dev/packages/assets_audio_player'),
            Text('Sound Effects :https://soundeffect-lab.info/'),
            Text('StackOverflow :54545102'),
            Text('    Q: https://stackoverflow.com/users/11020422/aembe'),
            Text('    A: https://stackoverflow.com/users/11324471/pranav'),
            Text('GitHub:https://github.com/flutter/flutter/issues/76393  ;-)'),
          ]),
        ),
    );
  }
}