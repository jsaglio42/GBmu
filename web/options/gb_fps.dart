// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   gb_fps.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/29 19:25:50 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/29 20:00:55 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

// CONSTANTS **************************************************************** **
const double __MIN_SCALE = 1.0;
const double __MAX_SCALE = 60.0;
const double __DEFAULT_SCALE = 30.0;
const String __LOCAL_STORAGE_KEY_FPS = 'option_fps';
const List<double> steps = const <double>[
  1.0, 15.0, 30.0, 60.0
];

// VARIABLE ***************************************************************** **
Emulator.Emulator _emu;
final Html.Element _text =
  Html.querySelector('.gameboy-fps-part.slider-text');
double __gbFps;

double get _gbFps => __gbFps;

void set _gbFps(double s) {
  if (s != _gbFps) {
    s = (s * 10.0).roundToDouble() / 10.0;
    __gbFps = s;
    Html.window.localStorage[__LOCAL_STORAGE_KEY_FPS] = s.toString();
    _text.text = '$s fps';
    _emu.send('FpsRequest', <String, double>{'fps': s});
  }
}

double _round(double s) {
  return (s * 10.0).roundToDouble() / 10.0;
}

class __Slider {

  // CONSTUCTION ************************************************************ **
  __Slider() {
    var constr = Js.context['Slider'];
    assert(constr != null, "Could not find `Slider` constructor");

    var param = new Js.JsObject.jsify({
      'formatter': _formatter,
      'min': __MIN_SCALE,
      'max': __MAX_SCALE,
      'value': _gbFps,
      'step': 0.1,
      'ticks_snap_bounds': 0.4,
      'ticks': steps,
      'ticks_labels': steps.map((double d) => '$d' + 'x'),
      'ticks_positions': steps.map((double d) => _posOfScale(d)),
    });

    assert(param != null, "Could not build `Slider` parameter");
    var slider = new Js.JsObject(constr, [
      '.gameboy-fps-part.slider-cont > .slider', param]);
    assert(slider != null, "Could not build `Slider`");

    // slider.callMethod('on', ['slide', _onSlide]);
    slider.callMethod('on', ['slideStop', _onSlide]);
  }

  // PRIVATE **************************************************************** **
  void _onSlide(num scale) {
    _gbFps = scale;
  }

  double _posOfScale(double d) =>
    (d - __MIN_SCALE) / (__MAX_SCALE - __MIN_SCALE) * 100.0;

  String _formatter(num scale) =>
    _round(scale).toString() + ' fps';

}

// CONSTRUCTION ************************************************************* **
void init_gameBoyFps(Emulator.Emulator emu) {
  final String prevValOpt =
    Html.window.localStorage[__LOCAL_STORAGE_KEY_FPS];
  double val;

  _emu = emu;
  if (prevValOpt != null) {
    val = double.parse(prevValOpt, (_) => __DEFAULT_SCALE);
    val = val.clamp(__MIN_SCALE, __MAX_SCALE);
  }
  else
    val = __DEFAULT_SCALE;
  _gbFps = val;
  new __Slider();
}
