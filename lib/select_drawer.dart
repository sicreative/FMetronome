import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart';
import 'common_helper.dart';
import 'db.dart';
import 'package:flutter/services.dart';

class TempoInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {



    try{


     int value = int.tryParse(newValue.text)!;

    if (value > 999)
      return oldValue;


    }catch(e){
      if (newValue.text.isNotEmpty)
        return oldValue;
    }


    return newValue;

  }

}

class SelectDrawer extends StatefulWidget {
  final BuildContext mothercontext;

  static int save_num_of_item = 0;

  SelectDrawer(this.mothercontext);

  @override
  _SelectDrawerState createState() => _SelectDrawerState();

// Callbacks for change requirement after user change the sorting parameters
  static List<void Function()?> _updateCallbacks = List.empty(growable: true);

  static int addCallback(void Function() callback) {
    _updateCallbacks.add(callback);
    return _updateCallbacks.length - 1;
  }

  static void removeCallback(int id) {
    if (_updateCallbacks.length > id) _updateCallbacks.removeAt(id);
  }

  static void _callUpdate() {
    for (int i = _updateCallbacks.length - 1; i >= 0; --i) {
      try {
        _updateCallbacks[i]!();
      } catch (e) {}
    }
  }
}

class _SelectDrawerState extends State<SelectDrawer> {
  var tempo = 30;
  var tempoCustom = false;
  var beat1 = 1;
  var beat2 = 0;
  var rhythm = 0;
  var tone = 0;


  final tempoEditingController = TextEditingController();
  final focusNode = FocusNode();




  void _updateTempo(int value) async {
    if (value == tempo) return;

    setState(() {
      tempo = value;
      tempoEditingController.text = tempo.toString();
    });


    _updateTempoFocus(tempo);
    _updatePrefDB('tempo', tempo);
  }

  void _updatePrefDB(String type, int value) async {
    Db.setPref(type, value);
    SelectDrawer._callUpdate();
  }

  void _retrievePref() async {


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
      tempoEditingController.text = tempo.toString();
    });



    _updateTempoFocus(tempo);


  }

  @override
  void initState() {
    super.initState();

    _retrievePref();





  }

  void _tempoOnTap(int value) {

      _updateTempo(value);



  }

  void _updateTempoFocus(int value){


    if (_tempoInList(value)) {


        focusNode.unfocus();

      if (tempoCustom)
        setState(() {

          tempoCustom = false;
        });


    }else {

        focusNode.requestFocus();



      if (!tempoCustom) {
        setState(() {

          tempoCustom = true;
        });
      }
    }
  }

  bool _tempoInList(int value){

    return -1!=tempoSelectorValue.indexOf(value);


  }

  void _beat1Update(int value){
    setState(() {
      this.beat1 = value;
    });
    _updatePrefDB('beat1', value);

  }

  void _beat2Update(int value){
    setState(() {
      this.beat2 = value;
    });

    _updatePrefDB('beat2', value);

  }

  void _rhythmUpdate(int value){
    setState(() {
      this.rhythm = value;
    });

    _updatePrefDB('rhythm', value);

  }

  void _toneUpdate(int value){
    setState(() {
      this.tone = value;
    });

    _updatePrefDB('tone', value);

  }

  @override
  Widget build(BuildContext context) {





    Widget? child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Spacer(flex: 2),
        Container(
          padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
          child:Text(AppLocalizations.of(context)!.tempo,
          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10), ),
        ),
        for (int j = 0; j < tempoSelectorValue.length; j+=3)
          Row(
            children: [
              for (int i = j; i < tempoSelectorValue.length && i < j+3 ; ++i)
                Container(
                  padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                  child: InkWell(
                    onTap: () {
                      _tempoOnTap(tempoSelectorValue[i]);
                    },
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: (tempo == tempoSelectorValue[i]
                                ? tempoSelectorColors[i]
                                : unselectedColor),
                            borderRadius: BorderRadius.circular(6)),
                        child: Container(
                            padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                            child: Text(
                              tempoSelectorValue[i].toString(),
                              style:TextStyle(color: drawerTextColor),
                            ))),
                  ),
                ),
            ],
          ),
          Container(
              padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
              child:TextField(

                controller: tempoEditingController,
                autocorrect: false,
                textAlign: TextAlign.center,
                style: TextStyle(color:tempoCustom?Colors.black:Colors.grey ),
                selectionHeightStyle: BoxHeightStyle.tight,
                selectionWidthStyle: BoxWidthStyle.tight,
                autofocus: false,
                focusNode: focusNode,
                decoration: InputDecoration(isDense: true,border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(0))),)

                inputFormatters: [TempoInputFormatter()],
                onTap: (){
                  setState(() {
                    tempoCustom = true;
                  });

                },
                onEditingComplete: (){
                  try{
                    String text = tempoEditingController.text;
                    int value = int.tryParse(text)!;
                    if (value>tempoMax)
                      value = tempoMax;
                    else if (value<tempoMin)
                      value = tempoMin;

                    _updateTempo(value);

                  }catch(e){

                  }
                },
                keyboardType:TextInputType.number ,),
                )
        Spacer(flex: 1),
        Container(
          padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
          child:Text(AppLocalizations.of(context)!.beat1,
          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10), ),
        ),
          Row(
            children: [
              for (int i = 0; i < 5 ; ++i)
               Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                      child: InkWell(
                      onTap: () {

                            _beat1Update(i);

                          },
                       child: DecoratedBox(
                          decoration: BoxDecoration(
                          color: ( beat1==i
                            ? beat1Color
                              : unselectedColor),
                        borderRadius: BorderRadius.circular(6)),
                        child: Container(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                              child: Text(
                                  i.toString(),
                                  style: TextStyle(color: drawerTextColor),
                      )
                )),
                    ),
              ),
            ],
        ),
          Row(
            children: [
              for (int i = 6; i < 10 ; ++i)
               Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                      child: InkWell(
                      onTap: () {

                            _beat1Update(i);

                          },
                       child: DecoratedBox(
                          decoration: BoxDecoration(
                          color: ( beat1==i
                            ? beat1Color
                              : unselectedColor),
                        borderRadius: BorderRadius.circular(6)),
                        child: Container(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                              child: Text(
                                  i.toString(),
                                  style: TextStyle(color: drawerTextColor),
                      ))),
                    ),
              ),
            ],
        ),
        Spacer(flex: 1),
        Container(
           padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
           child:Text(AppLocalizations.of(context)!.beat2,
           style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10), ),
         ),
          Row(
            children: [

              for (int i = 0; i < 5 ; ++i)
               Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                      child: InkWell(
                      onTap: () {

                            _beat2Update(i);

                          },
                       child: DecoratedBox(
                          decoration: BoxDecoration(
                          color: ( beat2==i
                            ? beat2Color
                              : unselectedColor),
                        borderRadius: BorderRadius.circular(6)),
                        child: Container(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                              child:Text(
                                  i.toString(),
                                  style: TextStyle(color: drawerTextColor),
                      )
                )),
                    ),
              ),
            ],
        ),

         Row(
            children: [
              for (int i = 6; i < 10 ; ++i)
               Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                      child: InkWell(
                      onTap: () {

                            _beat2Update(i);

                          },
                       child: DecoratedBox(
                          decoration: BoxDecoration(
                          color: ( beat2==i
                            ? beat2Color
                              : unselectedColor),
                        borderRadius: BorderRadius.circular(6)),
                        child: Container(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                              child: Text(
                                  i.toString(),
                                  style: TextStyle(color: drawerTextColor),
                      ))),
                    ),
              ),
            ],
        ),
        Spacer(flex: 1),
        Container(
              padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
              child:Text(AppLocalizations.of(context)!.rhythm,
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10), ),
            ),
                Row(
                   children: [

                     for (int i = 0; i < 5 ; ++i)
                      Container(
                           padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                             child: InkWell(
                             onTap: () {

                                     _rhythmUpdate(i);

                                 },
                              child: DecoratedBox(
                                 decoration: BoxDecoration(
                                 color: ( rhythm==i
                                   ? rhythmColor
                                     : unselectedColor),
                               borderRadius: BorderRadius.circular(6)),
                               child: Container(
                                     padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                                     child:  Image(image: AssetImage('assets/rhythm/$i.png'),height: 24,)
                       )),
                           ),
                     ),
                   ],
               ),
                Row(
                   children: [

                     for (int i = 5 ; i < 7 ; ++i)
                      Container(
                           padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                             child: InkWell(
                             onTap: () {

                                   _rhythmUpdate(i);

                                 },
                              child: DecoratedBox(
                                 decoration: BoxDecoration(
                                 color: ( rhythm==i
                                   ? rhythmColor
                                     : unselectedColor),
                               borderRadius: BorderRadius.circular(6)),
                               child: Container(
                                     padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                     child: Image(image: AssetImage('assets/rhythm/$i.png'),height: 24,)
                       )),
                           ),
                     ),


                   ],
               ),
               Container(
                        padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                          child: InkWell(
                          onTap: () {

                                _rhythmUpdate(7);

                              },
                           child: DecoratedBox(
                              decoration: BoxDecoration(
                              color: ( rhythm==7
                                ? rhythmColor
                                  : unselectedColor),
                            borderRadius: BorderRadius.circular(6)),
                            child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                  child: Image(image: AssetImage('assets/rhythm/7.png'),height: 24,)
                    )),
                        ),
                     ),
               Container(
                        padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                          child: InkWell(
                          onTap: () {

                                _rhythmUpdate(8);
                                
                              },
                           child: DecoratedBox(
                              decoration: BoxDecoration(
                              color: ( rhythm==8
                                ? rhythmColor
                                  : unselectedColor),
                            borderRadius: BorderRadius.circular(6)),
                            child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                  child: Image(image: AssetImage('assets/rhythm/8.png'),height: 24,)
                    )),
                        ),
                      ),

       Spacer(flex: 1),
       Container(
                     padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                     child:Text(AppLocalizations.of(context)!.tone,
                     style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10), ),
                   ),
       Row(
            children: [
              for (int i = 1; i < 5 ; ++i)
               Container(
                    padding: EdgeInsets.fromLTRB(4, 2, 3, 4),
                      child: InkWell(
                      onTap: () {

                            _toneUpdate(i);

                          },
                       child: DecoratedBox(
                          decoration: BoxDecoration(
                          color: ( tone==i
                            ? toneColor
                              : unselectedColor),
                        borderRadius: BorderRadius.circular(6)),
                        child: Container(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                              child: Text(
                                  i.toString(),
                                  style: TextStyle(color: drawerTextColor),
                      ))),
                    ),
              ),
            ],
        ),
        Spacer(flex: 2),


      ],
    );

    return Container(
        width: 200,
        child: Drawer(
          child: child,
        ));
  }
}
