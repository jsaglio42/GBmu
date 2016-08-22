// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   other_registers.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/20 15:48:20 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 11:30:42 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'package:emulator/emulator.dart' as Emu;
import 'package:emulator/emulator_classes.dart';
import 'package:ft/ft.dart' as ft;

/*
 * Global Variable
 * [Addr cell, Value cell]
 */
final Map<ORegister, List<Html.TableCellElement>> _cells = _initTable();

/*
 * Internal Methods
 */
Map<ORegister, List<Html.TableCellElement>> _initTable()
{
  final Html.Element body = Html.querySelector("#debColOtherRegisters");
  assert(body != null, 'Could not find element in DOM');
  final Html.TableElement table = body.children?.first;
  assert(table != null, 'Could not table in element');
  final it = new ft.DoubleIterable(
      ft.iterEnumData(ORegister, ORegister.values),
      ft.iterTableRows(table, 1));
  var m = {};

  it.forEach((Map m2, List<Html.TableCellElement> cells){
    assert(cells.length == 3, 'Unexpected list length');
    cells[0].text = m2['string'];
    m[m2['value']] = <Html.TableCellElement>[cells[1], cells[2]];
  });
  return new Map<ORegister, List<Html.TableCellElement>>.unmodifiable(m);
}

void _onORegInfo(Map<ORegister, int> map) {
  print('debugger/other_registers:\_onORegInfo($map)');
  _cells.forEach((ORegister oreg, List<Html.TableCellElement> lst){
    if (!map.containsKey(oreg))
      lst[1]
        ..style.color = 'black';
    });
  map.forEach((ORegister oreg, int v) {
    /* Enums need to be REinstanciated after a SendPort */
    _cells[ORegister.values[oreg.index]][1]
      ..text = v.toRadixString(16).toUpperCase()
      ..style.color = 'blue';
  });
  return ;
}

/*
 * Exposed Methods
 */
void init(Emu.Emulator emu) {
  _cells.toString(); /* Tips to instanciate _cells */
  print('debugger/other_registers:\tinit()');
  emu.listener('ORegInfo').listen(_onORegInfo);
  return ;
}
