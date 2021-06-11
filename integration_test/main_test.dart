//https://dart.dev/null-safety#known-issues

import 'dart:developer' as developer;
import 'package:f_metronome/common_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:f_metronome/main.dart';

class MainTestApp extends MainApp {
  static BuildContext? context;

  @override
  Widget build(BuildContext context) {
    MainTestApp.context = context;
    return MainAppStatefulWidget(title: 'FMetronome');
  }
}

Widget getDecorateBoxChild(WidgetTester tester, int pos) {
  final DecoratedBoxFinder = find.byType(DecoratedBox);
  expect(DecoratedBoxFinder, findsWidgets);
  final DecorateBoxList = tester.widgetList(DecoratedBoxFinder);
  return ((DecorateBoxList.elementAt(pos) as DecoratedBox).child as Container)
      .child!;
}

Decoration getDecorateBoxDecorate(WidgetTester tester, int pos) {
  final DecoratedBoxFinder = find.byType(DecoratedBox);
  expect(DecoratedBoxFinder, findsWidgets);
  final DecorateBoxList = tester.widgetList(DecoratedBoxFinder);
  return ((DecorateBoxList.elementAt(pos) as DecoratedBox).decoration);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("f_metronome", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      title: 'Metronome',
      initialRoute: '/',
      routes: {
        '/': (context) => MainTestApp(),
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', 'TW'),
      ],
      theme: ThemeData.light(),
    ));
    await tester.pumpAndSettle();


    final playButtonFinder = find.byIcon(Icons.play_arrow);
    expect(playButtonFinder, findsOneWidget);


    await tester.tap(playButtonFinder);

    await tester.pumpAndSettle();

    final playdisableButtonFinder = find.byIcon(Icons.play_disabled);
    expect(playdisableButtonFinder, findsOneWidget);

    await tester.tap(playdisableButtonFinder);

    await tester.pumpAndSettle();


    final playdisableButtonFinderTapped = find.byIcon(Icons.play_disabled);
    expect(playdisableButtonFinderTapped, findsNothing);


    final IconHeadlineFinder = find.byIcon(Icons.view_headline);

    expect(IconHeadlineFinder, findsOneWidget);


    await tester.tap(IconHeadlineFinder);

    await tester.pumpAndSettle();





    final DecoratedBoxFinder = find.byType(DecoratedBox);
    expect(DecoratedBoxFinder, findsWidgets);

    final DecorateBoxList = tester.widgetList(DecoratedBoxFinder);

    final State = find.byType(MainAppStatefulWidget);

    expect(State, findsOneWidget);

    for (int i = 0; i < DecorateBoxList.length; ++i) {
      if (!((DecorateBoxList.elementAt(i) as DecoratedBox).child is Container))
        continue;

      Widget child =
          ((DecorateBoxList.elementAt(i) as DecoratedBox).child as Container)
              .child!;
      if (child.runtimeType == Text) {
        if ((getDecorateBoxDecorate(tester, i) as BoxDecoration).color ==
            unselectedColor) {
          await tester.tap(DecoratedBoxFinder.at(i));
          await tester.pumpAndSettle();
        }

        expect(
            (getDecorateBoxDecorate(tester, i) as BoxDecoration).color !=
                unselectedColor,
            true);

        continue;
      }


    }
  });
}
