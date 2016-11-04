// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   clock_info.dart                                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 15:03:15 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/04 12:27:26 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:math' as Math;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

/*
 * Global Variable
 */

final Html.HtmlElement _time = Html.querySelector('#debClockTime');
final Html.HtmlElement _clock = Html.querySelector('#debClock');
final Html.HtmlElement _lines = Html.querySelector('#debClockLines');
final Html.HtmlElement _frames = Html.querySelector('#debClockFrames');

/*
 * Internal Methods
 */

void _onClockInfo(int clock) {
  final double tMs = clock.toDouble() / GB_CPU_FREQ_DOUBLE * MICROSECONDS_PER_SECOND_DOUBLE;
  final double l = clock.toDouble() / GB_CLOCK_PER_LINE_DOUBLE;
  final double f = clock.toDouble() / GB_CLOCK_PER_FRAME_DOUBLE;

  _time.text = new Duration(microseconds: tMs.round()).toString();
  _clock.text = _intToString(clock);
  _lines.text = _doubleToString(l, 1);
  _frames.text = _doubleToString(f, 3);
  return ;
}

String _intToString(int i) {
  String s = "";

  while (true) {
    if (i >= 1000)
      s = " " + (i % 1000).toString().padLeft(3, '0') + s;
    else {
      return i.toString() + s;
    }
    i = (i / 1000) ~/ 1;
  }
}

String _doubleToString(double d, int prec) {
  String s = _intToString(d ~/ 1);
  int precVal = Math.pow(10, prec);

  s += '.';
  s += ((d * precVal).round() % precVal).toString().padLeft(prec, '0');
  return s;
}

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  Ft.log('clock_info.dart', 'init', [emu]);
  assert(_time != null, 'Could not find label time');
  assert(_clock != null, 'Could not find label clock');
  assert(_frames != null, 'Could not find label frames');
  emu.listener('ClockInfo').listen(_onClockInfo);
  return ;
}
