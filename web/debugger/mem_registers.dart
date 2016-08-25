// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 16:57:32 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 20:17:13 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

/*
 * Global Variable
 */
class _ValueCell {
  final Html.TableCellElement elt;
  int value = 0;
  bool highlighted = false;

  _ValueCell(this.elt);
}

class _DomData {
  final Map<MemReg, _ValueCell> valueCells = _createValueCells();

  static trListOfTbodyId(String domId)
  {
    final Html.TableSectionElement tbody = Html.querySelector(domId);
    assert(tbody != null, "Could not retrieve $domId");
    return tbody.rows;
  }

  static _initTr(
      MemReg reg, Emulator.MemRegInfo reginfo, Html.TableRowElement tr)
  {
    final Html.TableCellElement td1 = tr.cells?.elementAt(0);
    assert(td1 != null, "Could not retrieve td");
    final nameA = td1.children?.elementAt(0);
    assert(td1 != null, "Could not retrieve name container <a>");
    final cgbLabel = td1.children?.elementAt(1);
    assert(td1 != null, "Could not retrieve cgb label");

    if (reginfo.cgb)
      cgbLabel.style.display = '';
    else
      cgbLabel.style.display = 'none';
    nameA.text = reginfo.name;
    nameA.title =
      ((new StringBuffer())
          ..write('address: 0x')
          ..write(reginfo.address
              .toUnsigned(16)
              .toRadixString(16)
              .toUpperCase()
              .padLeft(4, "0"))
          ..write('\ncategory: ')
          ..write(reginfo.category)
          ..write('\n')
          ..write(reginfo.description)
       ).toString();
    switch (reginfo.category) {
      case 'Port/Mode':
        tr.style.backgroundColor = 'DarkSeaGreen';
        // tr.style.backgroundColor = 'SeaShell';
        break ;
      case 'Interrupt':
        tr.style.backgroundColor = 'Thistle';
        break ;
      case 'LCD Display':
        tr.style.backgroundColor = 'Cornsilk';
        break ;
      case 'Bank Control':
        tr.style.backgroundColor = 'LightBlue';
        break ;
      default:
        break ;
    }
    return ;
  }

  static _createValueCells() {
    final m = {};
    final rowList = <Html.TableRowElement>[]
      ..addAll(trListOfTbodyId('#debTbody0MemRegisters'))
      ..addAll(trListOfTbodyId('#debTbody1MemRegisters'));
    final it = new Ft.TripleIterable(
        MemReg.values, Emulator.memRegInfos, rowList);
    Html.TableCellElement cell;

    it.forEach((MemReg reg, Emulator.MemRegInfo reginfo
            , Html.TableRowElement tr){
      _initTr(reg, reginfo, tr);
      cell = tr.cells?.elementAt(1);
      assert(cell != null, "Could not retrieve value cell");
      m[reg] = new _ValueCell(cell);
    });
    return new Map<MemReg, _ValueCell>.unmodifiable(m);
  }
}

final _data = new _DomData();

/*
 * Internal Methods
 */

void _onMemRegInfo(List<int> values) {
  // print('debugger/mem_registers:\_onMemRegInfo($values)');
  int i = 0;

  _data.valueCells.forEach((MemReg reg, _ValueCell cell){
    final int cur = values[i++];

    if (cell.value == cur) {
      if (cell.highlighted) {
        cell.elt.style.color = 'black';
        _data.valueCells[reg].highlighted = false;
      }
    }
    else {
      if (!cell.highlighted) {
        cell.elt.style.color = 'blue';
        _data.valueCells[reg].highlighted = true;
      }
      cell.elt.text = cur
        .toUnsigned(16)
        .toRadixString(16)
        .toUpperCase()
        .padLeft(2, "0");
      _data.valueCells[reg].value = cur;
    }
  });
  return ;
}

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  print('debugger/memory_registers:\tinit()');
  _data.toString(); /* Tips to instanciate _cells */
  emu.listener('MemRegInfo').listen(_onMemRegInfo);
  return ;
}
