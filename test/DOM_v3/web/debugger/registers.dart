// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   registers.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/17 15:53:33 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/17 18:16:50 by ngoguey          ###   ########.fr       //
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
class IterData {
  IterData(this.r, this.name, this.lhs, this.rhs);
  final Register r;
  final String name;
  final Html.TableCellElement lhs;
  final Html.TableCellElement rhs;
}

Iterable<IterData> _iterTableRows() sync* {
  const String prefix = "Register.";
  final Html.Element body = Html.querySelector("#debColRegisters");
  assert(body != null);
  final Html.TableElement table = body.children?.first;
  assert(table != null);
  final List<Html.TableRowElement> rows = table.rows;
  assert(rows != null);

  Html.TableRowElement row = null;
  List<Html.TableCellElement> cells = null;
  String regName = null;
  int i = 1;

  for (Register r in Register.values) {
    regName = r.toString().substring(prefix.length);
    row = rows[i];
    assert(row != null);
    cells = row.cells;
    assert(cells != null);
    assert(cells.length == 2);
    yield new IterData(r, regName, cells[0], cells[1]);
    i++;
  }
  return ;
}

Map<Register, Html.Element> _initTable()
{
  var m = {};

  for (IterData data in _iterTableRows()) {
    data.lhs.text = data.name;
    m[data.r] = data.rhs;
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
    cell.text = v.toRadixString(16).toUpperCase();
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
