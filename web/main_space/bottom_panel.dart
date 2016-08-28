// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   bottom_panel.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 18:28:04 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/28 20:22:14 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

import './emulation_speed_codec.dart' as ESCodec;

/*
 * Global Variable
 */

var _speed = new _SpeedSlider();
Emulator.Emulator _emu;

/*
 * Internal Methods
 */

class _SpeedSlider {

  Html.Element _slider = Html.querySelector('#mainSpeedSlider');
  Html.Element _text = Html.querySelector('#mainSpeedText');

  String _formatter(num perc_num) {
    final double perc = perc_num.toDouble();
    final double speed = ESCodec.codec.decode(perc);
    final double clockPerSec = speed * GB_CPU_FREQ_DOUBLE;

    if (speed.isInfinite)
      return 'inf';
    else
      return '${clockPerSec.toStringAsFixed(2)} c/s\n'
        '${(speed * 100.0).toStringAsFixed(3)}%';
  }

  _SpeedSlider() {
    var constr = Js.context['Slider'];
    assert(constr != null, "Could not find `Slider` constructor");
    var param = new Js.JsObject.jsify({
      'formatter': _formatter,
      // 'tooltip': 'always',
      'id': 'mainSpeedSlider',

      'min': 0.0,
      'max': 1.0,
      'value': 0.5,

      'step': 1.0 / 1000.0,
      'ticks_snap_bounds': 1.0 / 1000.0 * 10.0,
      'precision': 16, //17 digits gives a no-loss conversion to string

      'ticks': [
        0.0,
        ESCodec.codec.encode(1.0 / GB_CPU_FREQ_DOUBLE),
        ESCodec.codec.encode(1.0),
        ESCodec.codec.encode(2.0),
        ESCodec.codec.encode(10.0),
        1.0
      ],
      'ticks_labels': ['', '1cps', '1x', '2x', '10x', 'infinity'],
      'ticks_positions': [
        (0.0 * 100.0),
        (ESCodec.codec.encode(1.0 / GB_CPU_FREQ_DOUBLE) * 100.0),
        (ESCodec.codec.encode(1.0) * 100.0),
        (ESCodec.codec.encode(2.0) * 100.0),
        (ESCodec.codec.encode(10.0) * 100.0),
        100
      ],
    });
    _slider = Html.querySelector('#mainSpeedSlider');
    _slider.classes.toggle('col-sm-10');

    assert(_text != null, "Could not find `text` in DOM");
    assert(param != null, "Could not build `Slider` parameter");
    var slider = new Js.JsObject(constr, ['#mainSpeedSlider', param]);
    assert(slider != null, "Could not build `Slider`");

    slider.callMethod('on', ['slide', _onSlide]);
    _emu.send('EmulationSpeed', <String, dynamic>{
      'speed': 1.0,
      'isInf': false,
    });
    _emu.listener('EmulationSpeed').forEach(_onSpeedUpdate);
    return ;
  }

  _onSpeedUpdate(map) {
    // Ft.log('main_space', '_onSpeedUpdate', map);
    final double speed = map['speed'];

    _text.text = '${speed.toStringAsFixed(2)}x';
    return ;
  }

  _onSlide(num perc_num) {
    final double perc = perc_num.toDouble();
    final speed = ESCodec.codec.decode(perc);
    _emu.send('EmulationSpeed', <String, dynamic>{
      'speed': speed,
      'isInf': speed.isInfinite
    });
    return ;
  }

}

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  Ft.log('main_space', 'init');
  _emu = emu;
  _speed.toString();
  return ;
}
