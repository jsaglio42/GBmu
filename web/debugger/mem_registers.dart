// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 16:57:32 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 11:09:59 by ngoguey          ###   ########.fr       //
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
'''address: ${Ft.toAddressString(reginfo.address, 4)}
category: ${reginfo.category}
${reginfo.description}''';
    switch (reginfo.category) {
      case 'Port/Mode':
        // tr.style.backgroundColor = 'DarkSeaGreen';
        tr.style.backgroundColor = '#91cf91';
        break ;
      case 'Interrupt':
        // tr.style.backgroundColor = 'Thistle';
        tr.style.backgroundColor = '#e7908e';
        break ;
      case 'LCD Display':
        // tr.style.backgroundColor = 'Cornsilk';
        tr.style.backgroundColor = '#f6ce95';
        break ;
      case 'Bank Control':
        // tr.style.backgroundColor = 'LightBlue';
        tr.style.backgroundColor = '#7eb0db';
        break ;
      case 'Timer':
        // tr.style.backgroundColor = 'Thistle';
        tr.style.backgroundColor = '#9bd8eb';
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
        MemReg.values, Emulator.g_memRegInfos, rowList);
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
  int i = 0;

  _data.valueCells.forEach((MemReg reg, _ValueCell cell){
    final int cur = values[i++];

    if (cell.value == cur) {
      if (cell.highlighted) {

        cell.elt.style.color = '#005B79';
        _data.valueCells[reg].highlighted = false;
      }
    }
    else {
      if (!cell.highlighted) {
        cell.elt.style.color = '#FF1E00';
        _data.valueCells[reg].highlighted = true;
      }
      cell.elt.text = Ft.toHexaString(cur, 2);
      _data.valueCells[reg].value = cur;
    }
  });
  return ;
}

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  Ft.log('mem_registers.dart', 'init', [emu]);
  _data.toString(); /* Tips to instanciate _cells */
  emu.listener('MemRegInfo').listen(_onMemRegInfo);
  return ;
}
