// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   debug.dart                                         :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/27 11:08:37 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/04 18:23:19 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;

// http://blog.sethladd.com/2013/12/compile-time-dead-code-elimination-with.html
// const _enabled = const String.fromEnvironment('FTLOG') != null;
const _enabled = false;

DateTime now() => new DateTime.now();

String locStr(String locFunc, {List p: null}) {
  final String paramsStr =
    p != null ? p.map((p) => p.toString()).join(', ') : '';

  return '$locFunc($paramsStr)';
}

String loc2Str(String locClass, String locFunc, {List p: null, int width: 0}) {
  final String spacer = ' ' *  Math.max(1, width - locClass.length) ;
  final String paramsStr =
    p != null ? p.map((p) => p.toString()).join(', ') : '';

  return '$locClass$spacer$locFunc($paramsStr)';
}

String timestamp() {
  final n = now();
  final f = (int v, int w) => v.toString().padLeft(w, '0');

  return (new StringBuffer()
      ..write('${f(n.hour, 2)}:')
      ..write('${f(n.minute, 2)}:')
      ..write('${f(n.second, 2)}.')
      ..write('${f(n.millisecond, 3)}'))
      .toString();
}

String timedLoc2Str(String locClass, String locFunc, [List params]) {
  return timestamp() + ' ' + loc2Str(locClass, locFunc, p: params, width: 17);
}

void log(String locClass, String locFunc, [List params]) {
  if (_enabled)
    print(timedLoc2Str(locClass, locFunc, params));
  return ;
}

void logerr(String locClass, String locFunc, [List params]) {
  Js.context['console'].callMethod('error', [
    timedLoc2Str(locClass, locFunc, params)]);
  return ;
}

void logwarn(String locClass, String locFunc, [List params]) {
  Js.context['console'].callMethod('warn', [
    timedLoc2Str(locClass, locFunc, params)]);
  return ;
}

String typeStr(var v)
  => v.runtimeType.toString();
