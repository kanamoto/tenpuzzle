import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter/services.dart' show rootBundle;

class ManualPage extends StatefulWidget {

  ManualPage();

  @override
  _ManualPageState createState() => _ManualPageState();
}



class _ManualPageState extends State<ManualPage> {

  String _manualHtmlString = "<h2>Loading...</h2>";

  _ManualPageState();

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
              style: {
                // tables will have the below background color
                "table": Style(
                  backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                ),
                // some other granular customizations are also possible
                "tr": Style(
                  border: Border(bottom: BorderSide(color: Colors.grey)),
                ),
                "th": Style(
                  padding: EdgeInsets.all(6),
                  backgroundColor: Colors.grey,
                ),
                "td": Style(
                  padding: EdgeInsets.all(6),
                  alignment: Alignment.topLeft,
                ),
                // text that renders h1 elements will be red
                "h1": Style(color: Colors.black),
              }
            )
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