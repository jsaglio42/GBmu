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
import 'dart:math' as Math;
import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

/*
** Classes
*/

const MEMORY_ROWS = 9;
const MEMORY_COLS = 16;
final MEMORY_CELLS_COUNT = MEMORY_COLS * MEMORY_ROWS;

class _Cell {

  final Html.TableCellElement elt;
  int value = 0;

  _Cell(this.elt);
}

class _Data {

  final List<_Cell> addrCells = _createAddressCells();
  final List<_Cell> memCells = _createMemoryCells();

  static _createAddressCells() {
    final Html.TableSectionElement tbody = Html.querySelector('#debTbodyMemExplorer');
    final addrList = tbody.rows
      .map((tr) => new _Cell(tr.cells.first))
      .toList();
    assert(addrList != null, "_createAddressCells: addrList is null");
    assert(addrList.length == MEMORY_ROWS, "_createAddressCells: Invalid number of rows");
    return addrList;
  }

  static _createMemoryCells() {
    final Html.TableSectionElement tbody = Html.querySelector('#debTbodyMemExplorer');
    final memList = tbody.rows
      .map((tr) => tr.cells.skip(1))
      .expand((i) => i)
      .map((td) => new _Cell(td))
      .toList();
    assert(memList != null, "_createAddressCells");
    assert(memList.length == MEMORY_CELLS_COUNT, "Invalid number of cells");
    return memList;
  }

}

/*
** Update Cells according to memory
*/

void _onMemInfo(Map<String, dynamic> map) {
  assert(map['addr'] != null && map['addr'] is int);
  final addr = map['addr'];
  assert(addr >= 0x0000 && addr <= 0xFFFF);
  assert(map['data'] != null && map['data'] is Uint8List);
  final data = map['data'];
  assert(data.length == _data.memCells.length);
  for (var i = 0; i < _data.addrCells.length; ++i)
    _data.addrCells[i].elt.text = (addr + i * 0x10)
      .toRadixString(16)
      .toUpperCase()
      .padLeft(4, "0");
  for (var i = 0; i < _data.memCells.length; ++i)
    _data.memCells[i].elt.text = data[i]
      .toRadixString(16)
      .toUpperCase()
      .padLeft(2, "0");
  return ;
}

/*
 * Sending Addr to worker
 */

void _onMemAddrUpdate(_) {  
  final int parsedValue = int.parse(_memAddrInput.value,
    radix:16,
    onError: (s) => -1);
  if (parsedValue >= 0x0000 && parsedValue <= 0xFFFF) {
    final maxRange = 0x10000 - MEMORY_CELLS_COUNT;
    final adjustedAddr = Math.min(maxRange, parsedValue & 0xFFF0);
    _emu.send('DebMemAddrChange', adjustedAddr);
  }
  // Side - effect
  _memAddrInput.value = '';
  _memAddrInput.blur();
  return ;
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
      'addr' : 0x0000,
      'data' : new Uint8List(MEMORY_CELLS_COUNT)
  });
  _emu.listener('MemInfo').forEach(_onMemInfo);
  _memAddrInput.onChange.forEach(_onMemAddrUpdate);
  return ;
}
