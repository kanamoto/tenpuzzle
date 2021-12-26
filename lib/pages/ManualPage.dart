import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tenpuzzle/peripheral/Log.dart';
import 'package:url_launcher/url_launcher.dart';

class ManualPage extends StatefulWidget {

  final String _resourcePath;

  ManualPage(this._resourcePath);

  @override
  _ManualPageState createState() => _ManualPageState(_resourcePath);
}

class ManualPageConst {
  static const PREFIX_LOCAL_RESOURCE_ID = "resourceId:";
}

class _ManualPageState extends State<ManualPage> {

  String _manualHtmlString = "<h2>Loading...</h2>";

  String _resourcePath;

  ScrollController _scrollController = ScrollController();

  _ManualPageState(this._resourcePath);

  Future<String> loadAsset(String resourcePath) async {
    Log.print("_resourcePath:$resourcePath");

    String manualHtmlAssetsPath = FlutterI18n.translate(context, resourcePath);
    return await rootBundle.loadString(manualHtmlAssetsPath);
  }
  @override
  void didChangeDependencies() {
    Log.print('state = didChangeDependencies');
    super.didChangeDependencies();

    loadAsset(_resourcePath).then((value){
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
              controller: _scrollController,
              child:
              Html(
                  data: _manualHtmlString,
              onLinkTap: (url, context, attributes, element) => _launchURL(url),
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

  void _launchURL(String url) async {
    Log.print("url:$url");

    String urlStr = url.trim();
    if  (urlStr.startsWith(ManualPageConst.PREFIX_LOCAL_RESOURCE_ID) == true){
      _resourcePath = urlStr.substring(ManualPageConst.PREFIX_LOCAL_RESOURCE_ID.length).trim();
      Log.print("url to ressourceId:$_resourcePath");

      loadAsset(_resourcePath).then((value){
        setState(() {
          _scrollController.jumpTo(0);
          _manualHtmlString = value;
        });
      });


      // Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => ManualPage(resourceId))
      // );
    }else {
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
    }
  }
}