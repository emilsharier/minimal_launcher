import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:launcher_assist/launcher_assist.dart';
import 'package:minimal_launcher/individual_app.dart';
import 'package:page_transition/page_transition.dart';
import 'package:reorderables/reorderables.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RootWidget(),
      ),
    );

class RootWidget extends StatefulWidget {
  @override
  _RootWidgetState createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  List<IndividualApp> installedApps = [];
  int numberOfInstalledApps;
  String _timeString = 'Loading';
  String _searchValue = '';
  TextEditingController _controller;

  swapOrder(int a, int b) {
    setState(() {
      IndividualApp temp = installedApps[a];
      installedApps[a] = installedApps[b];
      installedApps[b] = temp;
    });
    // print(installedApps);
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);

    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    LauncherAssist.getAllApps().then((apps) {
      print('Getting app names');
      setState(() {
        for (var app in apps)
          installedApps
              .add(IndividualApp(label: app['label'], package: app['package']));
        installedApps.removeWhere((app) => app.label == 'minimal_launcher');
        numberOfInstalledApps = installedApps.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('Building');
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Widget header = Container(
      width: width,
      height: height / 2.5,
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Center(
        child: Container(
          width: width / 2,
          height: height / 6,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: Colors.white,
              width: 3.0,
            ),
          ),
          child: Center(
            child: AutoSizeText(
              _timeString,
              maxFontSize: 60,
              minFontSize: 35,
              style: TextStyle(
                letterSpacing: 2.0,
                color: Colors.white,
                fontFamily: 'Bebas',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    Widget customGrid = ReorderableWrap(
      buildDraggableFeedback: (_, __, wid) => Container(),
      header: header,
      children: installedApps.map((app) {
        return Container(
          height: 100.0,
          width: width / 2,
          padding: EdgeInsets.symmetric(
            horizontal: 30.0,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(),
          ),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              LauncherAssist.launchApp(app.package);
            },
            child: AutoSizeText(
              '${app.label}',
              minFontSize: 30.0,
              maxFontSize: 70.0,
              textAlign: TextAlign.center,
              // overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Bebas',
                letterSpacing: 2.0,
              ),
            ),
          ),
        );
      }).toList(),
      onReorder: (one, two) {
        swapOrder(one, two);
      },
    );

    var borderStyle = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
      ),
    );

    Widget bottomBar = Container(
      width: width,
      height: 70.0,
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      padding: EdgeInsets.all(10.0),
      child: Container(
        width: width,
        child: TextFormField(
          controller: _controller,
          onChanged: (value) {
            _getSearchResults(value.trim());
          },
          decoration: InputDecoration(
            prefix: Icon(
              Icons.search,
              color: Colors.white,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            enabledBorder: borderStyle,
            border: borderStyle,
            focusedBorder: borderStyle,
          ),
          cursorColor: Colors.white,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Bebas',
            letterSpacing: 2.0,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          (_searchValue.isEmpty)
              ? SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: 50.0,
                  ),
                  physics: BouncingScrollPhysics(),
                  child: customGrid,
                )
              : _getSearchList(width),
          Positioned(
            bottom: 0.0,
            child: bottomBar,
          ),
        ],
      ),
      // bottomNavigationBar: bottomBar,
    );
  }

  _getSearchList(double width) {
    List<IndividualApp> results = [];
    for (IndividualApp app in installedApps)
      if (app.label.toLowerCase().contains(_searchValue.toLowerCase()))
        results.add(app);
    print('Length of result set is ${results.length}\n results are : ');
    for (IndividualApp app in results) print(app.label);
    if (results.isEmpty)
      return Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Text(
            'EMPTY!',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Bebas',
              letterSpacing: 2.0,
              fontSize: 40.0,
            ),
          ),
        ),
      );
    else
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: 300.0,
          bottom: 70.0,
        ),
        child: Container(
          padding: MediaQuery.of(context).padding,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: results.map((app) {
              return Container(
                height: 100.0,
                width: width / 2,
                padding: EdgeInsets.symmetric(
                  horizontal: 30.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(),
                ),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => LauncherAssist.launchApp(app.package),
                  child: AutoSizeText(
                    '${app.label}',
                    textAlign: TextAlign.center,
                    minFontSize: 30.0,
                    maxFontSize: 70.0,
                    // overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Bebas',
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
  }

  _getSearchResults(String value) {
    setState(() {
      _searchValue = value;
      print("Search value is $_searchValue");
    });
  }
}
