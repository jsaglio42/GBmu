// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   bottom_panel.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 18:28:04 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 20:36:01 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:html' as Html;

import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

/*
 * Global Variable
 */

/*
 * Internal Methods
 */

// void _onClockInfo(int clock) {
//   final double tMs = clock.toDouble() / GB_CPU_FREQ_DOUBLE * MICROSEC_PER_SECOND;
//   final double f = clock.toDouble() / GB_FRAME_PER_CLOCK_DOUBLE;

//   print('debugger/clock_info:\t_onClockInfo($clock)');
//   _clock.text = clock.toStringAsPrecision(6);
//   _time.text = new Duration(microseconds: tMs.round()).toString();
//   _frames.text = f.toStringAsPrecision(6);
//   return ;
// }

/*
 * Exposed Methods
 */

// TODO: Tout delete et refaire
class _LogScale {

  static final double LOWER_HALF_BASE = 10.0;
  static final double LOWER_HALF_EXP_MULTIPLE =
    (Math.log(GB_CPU_FREQ_DOUBLE) / Math.log(LOWER_HALF_BASE)) / 0.5;
  static final double LOWER_HALF_EXP_ADD = 0.0;
  static final double LOWER_HALF_EXPR_MULT =
    GB_CPU_FREQ_DOUBLE / (GB_CPU_FREQ_DOUBLE - 1.0);
  static final double LOWER_HALF_EXPR_ADD = -1.0;

  static final double UPPER_HALF_BASE = 10000.0;
  static final double UPPER_HALF_EXP_MULTIPLE = 1.0;
  static final double UPPER_HALF_EXP_ADD = 0.5;
  static final double UPPER_HALF_EXPR_MULT =
    GB_CPU_FREQ_DOUBLE / UPPER_HALF_BASE;
  static final double UPPER_HALF_EXPR_ADD = 0.0;

  final double percent;

  _LogScale(this.percent);

  double get value {
    double v;

    if (this.percent <= 0.5) {
      v = this.percent * LOWER_HALF_EXP_MULTIPLE + LOWER_HALF_EXP_ADD;
      v = Math.pow(LOWER_HALF_BASE, v);
      v = v * LOWER_HALF_EXPR_MULT + LOWER_HALF_EXPR_ADD;
    }
    else {
      v = this.percent * UPPER_HALF_EXP_MULTIPLE + UPPER_HALF_EXP_ADD;
      v = Math.pow(UPPER_HALF_BASE, v);
      v = v * UPPER_HALF_EXPR_MULT + UPPER_HALF_EXPR_ADD;
    }
    return v;
  }
}

class _SpeedSlider {

  Html.Element _slider = Html.querySelector('#mainSpeedSlider');
  _LogScale _valueLog = new _LogScale(0.5);

  String _formatter(num perc) {
    final double val = new _LogScale(perc).value;
    final double speed = val / GB_CPU_FREQ_DOUBLE * 100.0;

    if (perc < 100.0)
      return '${val.toStringAsFixed(2)} clocks/sec\n'
        '${speed.toStringAsFixed(6)}% speed';
    else
      return 'inf';
  }

  _SpeedSlider() {
    var constr = Js.context['Slider'];
    assert(constr != null, "Could not find `Slider` constructor");
    var param = new Js.JsObject.jsify({
      'formatter': _formatter,
      'min': 0.0,
      'max': 1.0,
      'step': 0.0001,
      'id': 'mainSpeedSlider',
      'value': _valueLog.percent,
    });
    _slider = Html.querySelector('#mainSpeedSlider');
    assert(param != null, "Could not build `Slider` parameter");
    var slider = new Js.JsObject(constr, ['#mainSpeedSlider', param]);
    assert(slider != null, "Could not build `Slider`");

    slider.callMethod('on', ['slide', _onSlide]);
    return ;
  }

  _onSlide(num v) {
    this._valueLog = new _LogScale(v);
    _emu.send('EmulationSpeed', _valueLog.value / GB_CPU_FREQ_DOUBLE);
    return ;
  }


}
var _speed = new _SpeedSlider();
Emulator.Emulator _emu;

void init(Emulator.Emulator emu) {
  print('debugger/bottom_panel:\tinit()');
  _emu = emu;
  _speed.toString();
  // emu.listener('ClockInfo').listen(_onClockInfo);
  return ;
}
