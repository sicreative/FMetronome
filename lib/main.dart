import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wakelock/wakelock.dart';


import 'select_drawer.dart';
import 'db.dart';

import 'common_helper.dart';

// Copyright 2021 SC Lee
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Vocabulary Card
///
/// A simple vocabulary flash card for learning new vocabulary
///

void main() {
  runApp(MaterialApp(
    title: 'VocabularyCard',
    initialRoute: '/',
    routes: {
      '/': (context) => MainApp(),
    },
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('en', ''),
      const Locale.fromSubtags(
          languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    ],
    theme: ThemeData.light(),
  ));
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainAppStatefulWidget(title: 'F_metronome');
  }
}

class MainAppStatefulWidget extends StatefulWidget {
  MainAppStatefulWidget({Key? key, this.title}) : super(key: key);

  final String? title;
  final Duration duration = Duration(seconds: 2);

  final aCache = AudioCache(respectSilence: true);

  final Color nextIconColor = Colors.green;

  final int selectedIconFadeInMs = 500;
  final int selectedIconRemainMs = 3000;
  final int selectedIconFadeOutMs = 500;
  final Color selectedIconCorrectColor = Colors.green;
  final Color selectedIconWrongColor = Colors.red;

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainAppStatefulWidget>
    with SingleTickerProviderStateMixin {
  // for drawer update callback [dispose]
  int? _drawerCallbackID;

  bool _metronome_playing = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  var tempo = 30;
  var tempoCustom = false;
  var beat1 = 1;
  var beat2 = 0;
  var beat_count = 0;
  var rhythm = 0;
  var rhythm_count = 0;
  var tone = 1;



  void _updatePref() async {
    final tempo = await Db.getPref('tempo');
    final beat1 = await Db.getPref('beat1');
    final beat2 = await Db.getPref('beat2');
    final rhythm = await Db.getPref('rhythm');
    final tone = await Db.getPref('tone');

    setState(() {
      this.tempo = tempo;
      this.beat1 = beat1;
      this.beat2 = beat2;
      this.rhythm = rhythm;
      this.tone = tone;
    });

    beat_count = 0;
    rhythm_count = 0;
  }

  @override
  void initState() {
    super.initState();

    // Build Animation Controller
    //
    // Each choose have their own AnimationController as various offset speed applied
    // make cards slide out as like a sequence from top to down.

    _controller = AnimationController(
        value: 0.25,
        vsync: this,
        duration: Duration(milliseconds: 600),
        lowerBound: 0,
        upperBound: 0.5);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    _updatePref();

    _drawerCallbackID = SelectDrawer.addCallback(() {
      _updatePref();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_drawerCallbackID != null)
      SelectDrawer.removeCallback(_drawerCallbackID!);
    super.dispose();
  }

  Future<bool> _tick() async {
    int factor = 0;
    bool silent = false;

    if (rhythm == 0) {
      factor = 60;
    } else if (rhythm == 1) {
      factor = 30;
    } else if (rhythm == 2) {
      factor = 30;
      if (rhythm_count == 0) silent = true;

      if (rhythm_count >= 1) rhythm_count = -1;
    } else if (rhythm == 3) {
      factor = 20;
    } else if (rhythm == 4) {
      factor = 20;
      if (rhythm_count == 1) silent = true;
      if (rhythm_count >= 2) rhythm_count = -1;
    } else if (rhythm == 5) {
      factor = 15;
    } else if (rhythm == 6) {
      factor = 15;
      if (rhythm_count == 0 || rhythm_count == 2) silent = true;
      if (rhythm_count >= 3) rhythm_count = -1;
    } else if (rhythm == 7) {
      if (rhythm_count == 0 || rhythm_count == 1)
        factor = 45;
      else
        factor = 30;

      if (rhythm_count == 3 || rhythm_count == 6) silent = true;

      if (rhythm_count >= 6) rhythm_count = -1;
    } else if (rhythm == 8) {
      if (rhythm_count == 4 || rhythm_count == 5)
        factor = 45;
      else
        factor = 30;

      if (rhythm_count == 0 || rhythm_count == 3) silent = true;

      if (rhythm_count >= 6) rhythm_count = -1;
    }

    ++rhythm_count;

    int ms = (factor * 1000 / tempo).toInt();

    setState(() {
      ++beat_count;
      if (beat_count > (beat1 + beat2)) beat_count = 1;
    });

    if (!silent) {
      if (beat1 != 0 && (beat_count == 1 || beat_count == beat1 + 1))
        await widget.aCache.play('tone/tone$tone\_a.wav');
      else
        await widget.aCache.play('tone/tone$tone\_b.wav');
    }

    _controller.duration = Duration(milliseconds: (ms / 2).toInt());

    if (_animation.status == AnimationStatus.completed)
      _controller.reverse();
    else
      _controller.forward();
    //else ller.reverse();

    await Future.delayed(Duration(milliseconds: ms));

    if (!_metronome_playing)
      _controller.animateTo(0.25, duration: Duration(milliseconds: 500));

    return _metronome_playing;
  }

  _metronomeTrigger() {
    setState(() {
      _metronome_playing = !_metronome_playing;
    });

    if (_metronome_playing) {
      beat_count = 0;
      Wakelock.toggle(enable: true);
      Future.doWhile(() => _tick());
    }else{
      Wakelock.toggle(enable: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        appBar: AppBar(
          leadingWidth: 100,
          title: Text(
            AppLocalizations.of(context)!.main_appbar_title,
            style: appbarTitleStyle,
          ),
          iconTheme: IconThemeData(color: appbarForegroundColor),
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: Icon(appbarTitleDrawerIcon),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          }),
          backgroundColor: appbarBackgroundColor,
        ),
        drawer: SelectDrawer(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 64,
                        color: Colors.black),
                    children: [
                      if (beat1 > 0)
                        TextSpan(
                          text: beat_count > beat1 ? '$beat1' : '$beat_count',
                          style: TextStyle(
                              shadows: (beat_count == 1 && beat1 > 0)
                                  ? [
                                      Shadow(
                                          color: Colors.red.shade900,
                                          offset: Offset(2, 2),
                                          blurRadius: 5)
                                    ]
                                  : null,
                              color: (beat_count == 1 && beat1 > 0)
                                  ? Colors.red
                                  : null),
                        ),
                      if (beat2 > 0)
                        TextSpan(children: [
                          TextSpan(text: ':', style: TextStyle(fontSize: 32)),
                          TextSpan(
                              text: beat_count > beat1
                                  ? (beat_count - beat1).toString()
                                  : '0',
                              style: TextStyle(
                                  shadows: (beat_count == beat1 + 1)
                                      ? [
                                          Shadow(
                                              color: Colors.red.shade900,
                                              offset: Offset(2, 2),
                                              blurRadius: 5)
                                        ]
                                      : null,
                                  color: (beat_count == beat1 + 1)
                                      ? Colors.red
                                      : null)),
                        ]),
                    ]),
              ),
              Container(
                height:  orientation == Orientation.landscape ? (MediaQuery.of(context).size.height/1.7) : (MediaQuery.of(context).size.height*2/3),
                width:  MediaQuery.of(context).size.width,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(

                        child: Image(
                          image: AssetImage('assets/clock/board.png'),
                          height: MediaQuery.of(context).size.height/2,
                        )),
                    RotationTransition(
                      turns: _animation,
                      child: Image(
                        image: AssetImage('assets/clock/needle.png'),
                        height: MediaQuery.of(context).size.height*2/3,
                      ),
                    ),
                    Positioned(
                      bottom: orientation == Orientation.landscape ? MediaQuery.of(context).size.height/3 : 32,
                      right:orientation == Orientation.landscape ? MediaQuery.of(context).size.width/4 : null,
                      child: IconButton(
                          iconSize: 64,
                          onPressed: _metronomeTrigger,
                          icon: Icon(_metronome_playing
                              ? Icons.play_disabled
                              : Icons.play_arrow)),
                    ),
                  ],
                ),
              ),
              Spacer(flex: 2),
            ],
          ),
        ),
      );
    });
  }
}
