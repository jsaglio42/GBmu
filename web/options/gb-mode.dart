// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gb-mode.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/27 18:24:54 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/27 18:37:26 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

// CONSTANTS **************************************************************** **
const bool __DEFAULT_GAMEBOYMODE = true;

// VARIABLE ***************************************************************** **
final Html.Element _textGameBoyMode =
  Html.querySelector('.gameboy-mode-part.slider-text');
bool __gameBoyMode;

bool get _gameBoyMode => __gameBoyMode;

void set _gameBoyMode(bool b) {
  if (b != __gameBoyMode) {
    __gameBoyMode = b;
    _textGameBoyMode.text = _gameBoyModeFormatter(b);
    // TODO: Interact with emulator on game boy mode change
  }
}

String _gameBoyModeFormatter(bool b) =>
  b ? 'Color Game Boy' : 'Game Boy';

String _gameBoyModeFormatterNum(num n) =>
  _gameBoyModeFormatter(n > 0.5);

class __GameBoyModeSlider {

  // CONSTUCTION ************************************************************ **
  __GameBoyModeSlider() {
    var constr = Js.context['Slider'];
    assert(constr != null, "Could not find `Slider` constructor");

    var param = new Js.JsObject.jsify({
      'formatter': _gameBoyModeFormatterNum,
      'min': 0.0,
      'max': 1.0,
      'value': (__DEFAULT_GAMEBOYMODE ? 1.0 : 0.0),
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
  void _onSlide(num n) {
    _gameBoyMode = n > 0.5;
  }

}

// CONSTRUCTION ************************************************************* **
void init_gameBoyMode() {
  _gameBoyMode = __DEFAULT_GAMEBOYMODE;
  new __GameBoyModeSlider();
}
