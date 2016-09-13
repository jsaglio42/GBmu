// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_explorer.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/27 11:58:59 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 11:13:48 by ngoguey          ###   ########.fr       //
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
** Update Cells according to Event
*/

void _onMemInfo(Map<String, dynamic> map) {
  assert(map['addr'] != null && map['addr'] is int, "_onMemInfo($map)");
  final addr = map['addr'];
  assert(addr >= 0x0000 && addr <= 0xFFFF, "_onMemInfo($map)");
  assert(map['data'] != null && map['data'] is List<int>);
  final data = map['data'];
  assert(data.length == _data.memCells.length, "_onMemInfo($map)");
  for (var i = 0; i < _data.addrCells.length; ++i)
    _data.addrCells[i].elt.text = Ft.toAddressString(addr + i * 0x10, 4);
  for (var i = 0; i < _data.memCells.length; ++i)
  {
    if (data[i] == null)
      _data.memCells[i].elt.text = '--';
    else
      _data.memCells[i].elt.text = Ft.toHexaString(data[i], 2);
  }
  return ;
}

/*
 * Sending Addr to worker
 */

void _onMemAddrUpdate(_) {
  final String parsedString = _memAddrInput.value.startsWith('0x') ?
    _memAddrInput.value.substring(2):
    _memAddrInput.value;
  final int parsedValue = int.parse(parsedString,
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
  Ft.log('mem_explorer.dart', 'init');
  _emu = emu;
  _data.toString(); /* Tips to instanciate _cells */
  _onMemInfo({
      'addr' : 0x0000,
      'data' : new List<int>(MEMORY_CELLS_COUNT)
  });
  _emu.listener('MemInfo').forEach(_onMemInfo);
  _memAddrInput.onChange.forEach(_onMemAddrUpdate);
  return ;
}
