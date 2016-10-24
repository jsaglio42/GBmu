// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_explorer.dart                                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/27 11:58:59 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/24 17:30:04 by jsaglio          ###   ########.fr       //
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

const MEMORY_ROWS = 16;
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

  int _currentAddress = 0;

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
  _updateAddrCells(map['addr']);
  _updateMemCells(map['data']);
  return ;
}

void _updateAddrCells(int addr) {
  assert(addr != null , "_updateAddrCells($addr)");
  assert(addr >= 0x0000 && addr <= 0xFFFF, "_updateAddrCells($addr)");
  _data._currentAddress = addr;
  for (var i = 0; i < _data.addrCells.length; ++i) {
    _data.addrCells[i].elt.text = Ft.toAddressString(addr + i * 0x10, 4);
  }
  return ;
}

void _updateMemCells(List<int> data) {
  assert(data != null, "_updateMemCells($data)");
  assert(data.length == _data.memCells.length, "_updateMemCells($data)");
  for (var i = 0; i < _data.memCells.length; ++i) {
    _data.memCells[i].elt.text = (data[i] == null)
      ? '--'
      : Ft.toHexaString(data[i], 2);
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
  // Side - effect
  _sendMemoryAddr(parsedValue);
  _memAddrInput.value = '';
  _memAddrInput.blur();
  return ;
}

void _sendMemoryAddr(int addr) {
  final maxValue = 0x10000 - MEMORY_CELLS_COUNT;
  if (addr >= 0)
    _emu.send('DebMemAddrChange', addr.clamp(0, maxValue));
  return ;
}

/*
** Global
*/

final _data = new _Data();
final Html.InputElement _memAddrInput = Html.querySelector('#memory-addr-input');
final Html.ButtonElement _JumpPREV = Html.querySelector('#memExpJumpPREV');
final Html.ButtonElement _JumpBGDATA0 = Html.querySelector('#memExpJumpBGDATA0');
final Html.ButtonElement _JumpBGDATA1 = Html.querySelector('#memExpJumpBGDATA1');
final Html.ButtonElement _JumpBGMAP0 = Html.querySelector('#memExpJumpBGMAP0');
final Html.ButtonElement _JumpGBMAP1 = Html.querySelector('#memExpJumpGBMAP1');
final Html.ButtonElement _JumpOAM = Html.querySelector('#memExpJumpOAM');
final Html.ButtonElement _JumpNEXT = Html.querySelector('#memExpJumpNEXT');
Emulator.Emulator _emu;

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  Ft.log('mem_explorer.dart', 'init');
  _emu = emu;
  _data.toString();

  /* Browser side */
  _memAddrInput.onChange.forEach(_onMemAddrUpdate);
  _JumpPREV.onClick.forEach(
    (_) { _sendMemoryAddr(_data._currentAddress - 0x100); });
  _JumpNEXT.onClick.forEach(
    (_) { _sendMemoryAddr(_data._currentAddress + 0x100); });
  _JumpBGDATA0.onClick.forEach((_) { _sendMemoryAddr(0x8000); });
  _JumpBGDATA1.onClick.forEach((_) { _sendMemoryAddr(0x8800); });
  _JumpBGMAP0.onClick.forEach((_) { _sendMemoryAddr(0x9800); });
  _JumpGBMAP1.onClick.forEach((_) { _sendMemoryAddr(0x9C00); });
  _JumpOAM.onClick.forEach((_) { _sendMemoryAddr(0xFE00); });

  /* Emulator Side */
  _emu.listener('MemInfo').forEach(_onMemInfo);

  /* init memory cells */
  _onMemInfo({
      'addr' : 0x0000,
      'data' : new List<int>(MEMORY_CELLS_COUNT)
  });
  return ;
}
