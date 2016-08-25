// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 16:57:32 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 11:53:38 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

/*
** Classes
 */

const MEMORY_ROWS = 9;
const MEMORY_COLS = 16;

class _Cell {
  int value = 0;
  
  final Html.TableCellElement elt;
  _Cell(this.elt);
}

class _Data {

  int addr;

  final List<_Cell> valueCells = _createValueCells();

  static _createValueCells() {
    final Html.TableSectionElement tbody = Html.querySelector('#debTbodyMemExplorer');
    final cellList = tbody.rows.map((tr) {
        assert(tr.cells != null, "Could not retrieve row cells");
        return tr.cells;
      })
      .expand((i) => i)
      .map((td) => new _Cell(td))
      .toList();
    assert(cellList != null, "Could not retrieve cell list from #debTbodyMemExplorer");
    assert(cellList.length == ((MEMORY_COLS + 1) * MEMORY_ROWS), "Invalid number of cells");
    return cellList;
  }

}

/*
** Update Cells according to memory
*/

void _onMemInfo(Map<String, dynamic> map) {
  assert(map['address'] != null && map['address'] is int);
  final addr = map['address'];
  assert(addr >= 0x0000 && addr <= 0xFFFF);
  assert(map['data'] != null && map['data'] is Uint8List);
  final data = map['data'];
  assert(data.length == MEMORY_ROWS * MEMORY_COLS);





  // final addrList = _data.valueCells.where((e) => (cellList.IndexOf(e) % 17 == 0)).toList();
  // final valueList = _data.valueCells.where((e) => (cellList.IndexOf(e) % 17 != 0)).toList();

  // print('debugger/mem_explorer:\_onMemInfo($values)');
  // int i = 0;

  // _data.valueCells.forEach((MemReg reg, _Cell cell){
  //   final int cur = values[i++];

  //   if (cell.value == cur) {
  //     if (cell.highlighted) {
  //       cell.elt.style.color = 'black';
  //       _data.valueCells[reg].highlighted = false;
  //     }
  //   }
  //   else {
  //     if (!cell.highlighted) {
  //       cell.elt.style.color = 'blue';
  //       _data.valueCells[reg].highlighted = true;
  //     }
  //     cell.elt.text = cur
  //       .toUnsigned(16)
  //       .toRadixString(16)
  //       .toUpperCase()
  //       .padLeft(2, "0");
  //     _data.valueCells[reg].value = cur;
  //   }
  // });
  return ;
}

/*
 * Sending Addr to worker
 */

void _onMemAddrUpdate(_) {  
  final int parsedValue = int.parse(_memAddrInput.value, radix:16, onError: (s) => -1);
  if (parsedValue >= 0x0000 && parsedValue <= 0xFFFF) {
    // _data.addr = parsedValue;
    _emu.send('DebMemAddrChange', parsedValue);
  }
  _memAddrInput.value = '';
  _memAddrInput.blur();
}

/*
** Global
*/

final _data = new _Data();
final Html.InputElement _memAddrInput = Html.querySelector('#memory-addr-input');
Emulator.Emulator _emu;

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  print('debugger/mem_explorer:\tinit()');
  _emu = emu;
  _data.toString(); /* Tips to instanciate _cells */
  _onMemInfo({
      'address' : 0x0000,
      'data' : new Uint8List(MEMORY_ROWS * MEMORY_COLS)
  });
  _emu.listener('MemInfo').forEach(_onMemInfo);
  _memAddrInput.onChange.forEach(_onMemAddrUpdate);
  return ;
}
