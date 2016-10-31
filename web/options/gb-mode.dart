// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gb-mode.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/27 18:24:54 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/31 13:37:32 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;

import 'package:emulator/enums.dart';
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

/* CONSTANTS ******************************************************************/
const String __LOCAL_STORAGE_KEY_GAMEBOYMODE = 'option_gb_mode';
const GameBoyType __DEFAULT_GAMEBOYMODE = GameBoyType.Auto;

/* VARIABLES ******************************************************************/
Emulator.Emulator _emu;
GameBoyType __gameboyType;

/* PUBLIC API *****************************************************************/
GameBoyType get gameboyType => __gameboyType;

void init_gameBoyType(Emulator.Emulator emu)
{
  _emu = emu;
  _gameboyType =  _loadFromLocalStorage();
  new __GameBoyModeSlider();
}

/* PRIVATE ********************************************************************/
GameBoyType get _gameboyType => __gameboyType;

void set _gameboyType(GameBoyType gbt)
{
  if (gbt != __gameboyType)
  {
    __gameboyType = gbt;
    _emu.send('GameBoyTypeUpdate', gbt);
    Html.window.localStorage[__LOCAL_STORAGE_KEY_GAMEBOYMODE] = gbt.toString();
  }
}

GameBoyType _loadFromLocalStorage()
{
  final String prevValOpt =
    Html.window.localStorage[__LOCAL_STORAGE_KEY_GAMEBOYMODE];

  switch (prevValOpt)
  {
    case ('GameBoyType.DMG'): return GameBoyType.DMG;
    case ('GameBoyType.Color'): return GameBoyType.Color;
    default: return __DEFAULT_GAMEBOYMODE;
  }
}

String _gameboyTypeFormatter(GameBoyType gbt)
{
  switch(gbt)
  {
    case (GameBoyType.DMG) : return 'Game Boy Classic';
    case (GameBoyType.Color) : return 'Game Boy Color';
    default : return 'Auto';
  }
}

GameBoyType _gameboyTypeFromNum(num n)
{
    if (n < 0.33)
      return GameBoyType.DMG;
    else if (n < 0.66)
      return GameBoyType.Color;
    else
      return GameBoyType.Auto;
}

num _numFromGameBoyType(GameBoyType gbt)
{
  switch(gbt)
  {
    case (GameBoyType.DMG) : return 0.0;
    case (GameBoyType.Color) : return 0.5;
    default : return 1.0;
  }
}

String _gameboyTypeFormatterNum(num n) =>
  _gameboyTypeFormatter(_gameboyTypeFromNum(n));

/* SLIDER *********************************************************************/
class __GameBoyModeSlider {

  // CONSTUCTION ************************************************************ **
  __GameBoyModeSlider() {
    var constr = Js.context['Slider'];
    assert(constr != null, "Could not find `Slider` constructor");

    var param = new Js.JsObject.jsify({
      'formatter': _gameboyTypeFormatterNum,
      'min': 0.0,
      'max': 1.0,
      'step': 0.5,
      'value': _numFromGameBoyType(_gameboyType),
      'ticks_labels': ['Classic', 'Color', 'Auto'],
      'ticks': [0.0, 0.5, 1.0],
      'ticks_positions': [0, 50, 100],
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
