// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   options.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/10 17:43:59 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/03 22:40:10 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

import './emulation_speed_codec.dart' as ESCodec;
import './gb-mode.dart';
import './gb_fps.dart';
import '../canvas.dart' as C;

/*
 * Global Variable
 */
const String __LOCAL_STORAGE_KEY_EMUSPEED = 'option_emu_speed';
const double __DEFAULT_EMUSPEED = 1.0;
Emulator.Emulator _emu;
var _jqElt;

class _Step {

  final String name;
  final double speed;
  final double location;

  const _Step(this.name, double s, [double loc])
    : speed = s
    , location = loc == null ? s : loc;

}

const List<_Step> _steps = const <_Step>[
  const _Step('', 0.0),
  const _Step('1cps', 1.0 / GB_CPU_FREQ_DOUBLE, 5.0 / GB_CPU_FREQ_DOUBLE),
  const _Step('1lps', GB_CLOCK_PER_LINE_DOUBLE / GB_CPU_FREQ_DOUBLE),
  const _Step('1fps', GB_CLOCK_PER_FRAME_DOUBLE / GB_CPU_FREQ_DOUBLE),
  const _Step('10%', 0.10),
  const _Step('1x', 1.0),
  const _Step('2x', 2.0),
  const _Step('4x', 4.0),
  const _Step('8x', 8.0),
  const _Step('16x', 16.0),
  const _Step('infinity', double.INFINITY),
];

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
    else if (speed > 2.0)
      return '${(speed).toStringAsFixed(2)}x';
    else
      return '${clockPerSec.toStringAsFixed(2)} clock per sec '
        '${(speed * 100.0).toStringAsFixed(3)}%';
  }

  _SpeedSlider(double speed) {
    var constr = Js.context['Slider'];
    assert(constr != null, "Could not find `Slider` constructor");
    var param = new Js.JsObject.jsify({
      'formatter': _formatter,
      // 'tooltip': 'always',
      'id': 'mainSpeedSlider',

      'min': 0.0,
      'max': 1.0,
      'value': ESCodec.codec.encode(speed),

      'step': 1.0 / 1000.0,
      'ticks_snap_bounds': 1.0 / 1000.0 * 10.0,
      'precision': 16, //17 digits gives a no-loss conversion to string

      'ticks': _steps.map((_Step s) => ESCodec.codec.encode(s.speed)),
      'ticks_labels': _steps.map((_Step s) => s.name),
      'ticks_positions': _steps.map((_Step s) =>
          100.0 * ESCodec.codec.encode(s.location)),
    });
    _slider = Html.querySelector('#mainSpeedSlider');

    assert(_text != null, "Could not find `text` in DOM");
    assert(param != null, "Could not build `Slider` parameter");
    var slider = new Js.JsObject(constr, ['#mainSpeedSlider', param]);
    assert(slider != null, "Could not build `Slider`");

    _jqElt = slider;

    slider.callMethod('on', ['slideStop', _onSlide]);

    _emu.send('EmulationSpeed', <String, dynamic>{
      'speed': speed,
      'isInf': speed.isInfinite,
    });
    _emu.listener('EmulationSpeed').forEach(_onSpeedUpdate);
    return ;
  }

  _onSpeedUpdate(map) {
    final double speed = map['speed'];

    _text.text = 'Speed ${speed.toStringAsFixed(2)}x';
    return ;
  }

  _onSlide(num perc_num) {
    final double perc = perc_num.toDouble();
    final speed = ESCodec.codec.decode(perc);

    Html.window.localStorage[__LOCAL_STORAGE_KEY_EMUSPEED] = speed.toString();
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

void onOpen()
{
  onOpen_gameBoyType();
  onOpen_speed();
  C.onOpen_scale();
  C.onOpen_smooth();
  onOpen_gameBoyFps();
}

void onClose()
{

}

void init(Emulator.Emulator emu) {
  final String prevValOpt =
    Html.window.localStorage[__LOCAL_STORAGE_KEY_EMUSPEED];
  double val;

  Ft.log('options.dart', 'init', [emu]);

  _emu = emu;

  if (prevValOpt != null) {
    val = double.parse(prevValOpt, (_) => __DEFAULT_EMUSPEED);
    if (val.isFinite) {
      if (val < 10.0)
        val = val.clamp(1.0, 10.0);
      else
        val = double.INFINITY;
    }
  }
  else
    val = __DEFAULT_EMUSPEED;
  new _SpeedSlider(val);
  init_gameBoyType(emu);
  init_gameBoyFps(emu);
  return ;
}

void onOpen_speed() {
  _jqElt.callMethod('relayout', []);
}
