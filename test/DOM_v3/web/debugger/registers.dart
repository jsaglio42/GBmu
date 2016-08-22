// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   registers.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/17 15:53:33 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 11:43:44 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'package:emulator/emulator.dart' as Emu;
import 'package:emulator/emulator_classes.dart';
import 'package:ft/ft.dart' as ft;

/*
 * Global Variable
 */
final Map<Reg16, Html.TableCellElement> _cells = _initTable();

/*
 * Internal Methods
 */
Map<Reg16, Html.TableCellElement> _initTable()
{
  final Html.Element body = Html.querySelector("#debColRegisters");
  assert(body != null, 'Could not find element in DOM');
  final Html.TableElement table = body.children?.first;
  assert(table != null, 'Could not table in element');
  final it = new ft.DoubleIterable(
      ft.iterEnumData(Reg16, Reg16.values),
      ft.iterTableRows(table, 1));
  var m = {};

  it.forEach((Map m2, List<Html.TableCellElement> cells){
    assert(cells.length == 2, 'Unexpected list length');
    cells[0].text = m2['string'];
    m[m2['value']] = cells[1];
  });
  return new Map<Reg16, Html.TableCellElement>.unmodifiable(m);
}

void _onRegInfo(RegisterBank rb) {
  print('debugger/registers:\_onRegInfo($rb)');
  _cells.forEach((Reg16 reg, Html.TableCellElement elt){
    final cur = rb.value16(reg)
      .toUnsigned(16)
      .toRadixString(16)
      .toUpperCase();

    if (elt.text == cur)
      elt
        ..style.color = 'black';
    else
      elt
        ..text = cur
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
