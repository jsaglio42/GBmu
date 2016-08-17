// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   registers.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/17 15:53:33 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/17 17:23:42 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'dart:async' as As;
import '../emulator/emulator.dart' as Emu;
import '../emulator/conf.dart';

/*
 * Global Variable
 */
final Map<Register, Html.Element> _cells = _initTable();

/*
 * Internal Methods
 */
Map<Register, Html.Element> _initTable()
{
  const String prefix = "Register.";
  var m = {};
  String regName = null;
  Html.TableRowElement row = null;
  List<Html.TableCellElement> cells = null;

  for (Register r in Register.values) {
    regName = r.toString().substring(prefix.length);
    row = Html.querySelector("#debReg$regName");
    assert(row != null);
    cells = row.cells;
    assert(cells != null);
    assert(cells.length == 2);
    cells[0].text = regName;
    m[r] = cells[1];
  }
  return new Map<Register, Html.Element>.unmodifiable(m);
}

void _onRegInfo(Map<Register, int> map) {
  Html.TableCellElement cell;
  print('debugger/registers:\_onRegInfo($map)');
  map.forEach((reg, v) {
    /* Enums need to be REinstanciated after a SendPort */
    cell = _cells[Register.values[reg.index]];
    assert(cell != null);
    print('$reg -> $v  $cell');
    cell.text = v.toString();
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
