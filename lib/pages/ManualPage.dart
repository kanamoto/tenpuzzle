import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:tenpuzzle/model/GameModel.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/services.dart' show rootBundle;

class ManualPage extends StatefulWidget {

  final GameModel _gameModel;

  ManualPage(this._gameModel);

//   @override
//   Widget build(BuildContext context) {
//     return ManualWidget(_gameModel);
//   }
// }


  @override
  _ManualPageState createState() => _ManualPageState(this._gameModel);
}



class _ManualPageState extends State<ManualPage> {

  final GameModel _gameModel;

  String _manualHtmlString = "Loading...";

  _ManualPageState(this._gameModel);

  Future<String> loadAsset() async {
    String manualHtmlAssetsPath = FlutterI18n.translate(context, "manualhtml");
    return await rootBundle.loadString(manualHtmlAssetsPath);
  }
  @override
  void didChangeDependencies() {
    print('state = didChangeDependencies');
    super.didChangeDependencies();

    loadAsset().then((value){
      setState(() {
        _manualHtmlString = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text("Manual"),),
        body:
        Container(
          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
          width: double.infinity,
          height:double.infinity,
          child:
          SingleChildScrollView(
              child:
              Html(
                  data: _manualHtmlString,
                        padding: EdgeInsets.all(8.0),
                        onLinkTap: (url) {
                          print("Opening $url...");
                        },
                        customRender: (node, children) {
                          if (node is dom.Element) {
                            switch (node.localName) {
                              case "img": // using this, you can handle custom tags in your HTML
                                return Column(children: children);
                            }
                          }
                        },
                      ),
                    ),
        ),
    );
  }

  // ImageSourceMatcher classAndIdMatcher({String classToMatch, String idToMatch}) => (attributes, element) =>
  //     attributes["class"].contains(classToMatch) ||
  //     attributes["id"].contains(idToMatch);
  //
  // ImageRender classAndIdRender({String classToMatch, String idToMatch}) => (context, attributes, element) {
  //   if (attributes["class"].contains(classToMatch)) {
  //     return Image.asset(attributes["src"]);
  //   } else {
  //     return Image.network(
  //       attributes["src"],
  //       semanticLabel: attributes["longdesc"],
  //       width: attributes["width"],
  //       height: attributes["height"],
  //       color: context.style.color,
  //       frameBuilder: (ctx, child, frame, _) {
  //         if (frame == null) {
  //           return Text(attributes["alt"] ?? "", style: context.style.generateTextStyle());
  //         }
  //         return child;
  //       },
  //     );
  //   }
  // };
}