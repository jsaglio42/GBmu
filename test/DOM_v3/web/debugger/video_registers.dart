// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   video_registers.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/20 15:06:36 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/20 15:45:05 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'package:emulator/emulator.dart' as Emu;
import 'package:emulator/emulator_conf.dart';
import 'package:ft/ft.dart' as ft;

/*
 * Global Variable
 * [Addr cell, Value cell]
 */
final Map<VRegister, List<Html.TableCellElement>> _cells = _initTable();

/*
 * Internal Methods
 */
Map<VRegister, List<Html.TableCellElement>> _initTable()
{
  final Html.Element body = Html.querySelector("#debColVideoRegisters");
  assert(body != null, 'Could not find element in DOM');
  final Html.TableElement table = body.children?.first;
  assert(table != null, 'Could not table in element');
  final it = new ft.DoubleIterable(
      ft.iterEnumData(VRegister, VRegister.values),
      ft.iterTableRows(table, 1));
  var m = {};

  it.forEach((Map m2, List<Html.TableCellElement> cells){
    assert(cells.length == 3, 'Unexpected list length');
    cells[0].text = m2['string'];
    m[m2['value']] = <Html.TableCellElement>[cells[1], cells[2]];
  });
  return new Map<VRegister, List<Html.TableCellElement>>.unmodifiable(m);
}

void _onVRegInfo(Map<VRegister, int> map) {
  print('debugger/video_registers:\_onVRegInfo($map)');
  map.forEach((VRegister vreg, int v) {
    /* Enums need to be REinstanciated after a SendPort */
    _cells[VRegister.values[vreg.index]][1]
      .text = v.toRadixString(16).toUpperCase();
  });
}

/*
 * Exposed Methods
 */
void init(Emu.Emulator emu) {
  _cells.toString(); /* Tips to instanciate _cells */
  print('debugger/video_registers:\tinit()');
  emu.listener('VRegInfo').listen(_onVRegInfo);
  return ;
}
