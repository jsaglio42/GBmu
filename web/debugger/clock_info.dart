// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   clock_info.dart                                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 15:03:15 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 20:34:24 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'package:emulator/constants.dart';
import 'package:emulator/emulator.dart' as Emulator;

/*
 * Global Variable
 */

final Html.HtmlElement _time = Html.querySelector('#debClockTime');
final Html.HtmlElement _clock = Html.querySelector('#debClock');
final Html.HtmlElement _frames = Html.querySelector('#debClockFrames');

/*
 * Internal Methods
 */

void _onClockInfo(int clock) {
  final double tMs = clock.toDouble() / GB_CPU_FREQ_DOUBLE * MICROSEC_PER_SECOND;
  final double f = clock.toDouble() / GB_FRAME_PER_CLOCK_DOUBLE;

  print('debugger/clock_info:\t_onClockInfo($clock)');
  _clock.text = clock.toStringAsPrecision(9);
  _time.text = new Duration(microseconds: tMs.round()).toString();
  _frames.text = f.toStringAsPrecision(6);
  return ;
}

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  print('debugger/clock_info:\tinit()');
  _time.toString();
  _clock.toString();
  _frames.toString();
  assert(_time != null, 'Could not find label time');
  assert(_clock != null, 'Could not find label clock');
  assert(_frames != null, 'Could not find label frames');
  emu.listener('ClockInfo').listen(_onClockInfo);
  return ;
}
