// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   registers.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/17 15:53:33 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/20 16:21:25 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'package:emulator/emulator.dart' as Emu;
import 'package:emulator/emulator_conf.dart';
import 'package:ft/ft.dart' as ft;

/*
 * Global Variable
 */
final Map<Register, Html.TableCellElement> _cells = _initTable();

/*
 * Internal Methods
 */
Map<Register, Html.TableCellElement> _initTable()
{
  final Html.Element body = Html.querySelector("#debColRegisters");
  assert(body != null, 'Could not find element in DOM');
  final Html.TableElement table = body.children?.first;
  assert(table != null, 'Could not table in element');
  final it = new ft.DoubleIterable(
      ft.iterEnumData(Register, Register.values),
      ft.iterTableRows(table, 1));
  var m = {};

  it.forEach((Map m2, List<Html.TableCellElement> cells){
    assert(cells.length == 2, 'Unexpected list length');
    cells[0].text = m2['string'];
    m[m2['value']] = cells[1];
  });
  return new Map<Register, Html.TableCellElement>.unmodifiable(m);
}

void _onRegInfo(Map<Register, int> map) {
  print('debugger/registers:\_onRegInfo($map)');
  _cells.forEach((Register reg, Html.TableCellElement elt){
    if (!map.containsKey(reg))
      elt
        ..style.color = 'black';
    });
  map.forEach((reg, v) {
    /* Enums need to be REinstanciated after a SendPort */
    _cells[Register.values[reg.index]]
      ..text = v.toRadixString(16).toUpperCase()
      ..style.color = 'blue';
  });
}

/*
 * Exposed Methods
 */
void init(Emu.Emulator emu) {
  _cells.toString(); /* Tips to instanciate _cells */
  print('debugger/registers:\tinit()');
  emu.listener('RegInfo').listen(_onRegInfo);
  return ;
}
