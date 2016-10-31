// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gb-mode.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/27 18:24:54 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/31 11:34:55 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

// CONSTANTS **************************************************************** **
const String __LOCAL_STORAGE_KEY_GAMEBOYMODE = 'option_gb_mode';
const GameBoyType __DEFAULT_GAMEBOYMODE = GameBoyType.Color;

/* PUBLIC API *****************************************************************/
GameBoyType get gameboyType => __gameboyType;

void init_gameBoyType() {
  final String prevValOpt =
    Html.window.localStorage[__LOCAL_STORAGE_KEY_GAMEBOYMODE];

  print(prevValOpt);
  switch (prevValOpt)
  {
    case ('GameBoyType.DMG'): _gameboyType = GameBoyType.DMG; break;
    case ('GameBoyType.Color'): _gameboyType = GameBoyType.Color; break;
    default: _gameboyType = __DEFAULT_GAMEBOYMODE; break;
  }
  new __GameBoyModeSlider();
}

/* PRIVATE ********************************************************************/
GameBoyType __gameboyType;

GameBoyType get _gameboyType => __gameboyType;
void set _gameboyType(GameBoyType gbt) {
  if (gbt != __gameboyType)
  {
    __gameboyType = gbt;
    Html.window.localStorage[__LOCAL_STORAGE_KEY_GAMEBOYMODE] = gbt.toString();
  }
}

/* Slider *********************************************************************/
class __GameBoyModeSlider {

  // CONSTUCTION ************************************************************ **
  __GameBoyModeSlider() {
    var constr = Js.context['Slider'];
    assert(constr != null, "Could not find `Slider` constructor");

    var param = new Js.JsObject.jsify({
      'formatter': _gameboyTypeFormatterNum,
      'min': 0.0,
      'max': 1.0,
      'value': _numFromGameBoyType(_gameboyType),
      'ticks_labels': ['Classic', 'Color'],
      'ticks': [0.0, 1.0],
      'ticks_positions': [0, 100],
    });

    assert(param != null, "Could not build `Slider` parameter");
    var slider = new Js.JsObject(constr, [
      '.gameboy-mode-part.slider-cont > .slider', param]);
    assert(slider != null, "Could not build `Slider`");

    slider.callMethod('on', ['slide', _onSlide]);
    slider.callMethod('on', ['slideStop', _onSlide]);
  }

  // PRIVATE **************************************************************** **
  void _onSlide(num n)
  {
    _gameboyType = _gameboyTypeFromNum(n);
    return ;
  }

}

/* Misc ***********************************************************************/
String _gameboyTypeFormatter(GameBoyType gbt)
{
  switch(gbt)
  {
    case (GameBoyType.DMG) : return 'Game Boy Classic';
    case (GameBoyType.Color) : return 'Game Boy Color';
    default : assert(false, 'Invalid Gameboy Type');
  }
}

GameBoyType _gameboyTypeFromNum(num n)
{
    if (n < 0.5)
      return GameBoyType.DMG;
    else
      return GameBoyType.Color;
}

num _numFromGameBoyType(GameBoyType gbt)
{
  switch(gbt)
  {
    case (GameBoyType.DMG) : return 0.0;
    case (GameBoyType.Color) : return 1.0;
    default : assert(false, 'Invalid Gameboy Type');
  }
}

String _gameboyTypeFormatterNum(num n) =>
  _gameboyTypeFormatter(_gameboyTypeFromNum(n));
