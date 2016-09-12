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
import 'dart:html' as Html;

import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';

import 'package:emulator/emulator.dart' as Emulator;
import 'package:emulator/src/z80/instructions.dart' as Instructions;

/*
** Classes
*/

const INST_ROWS = 7;

class _Cell {

  final Html.TableCellElement elt;
  int value = 0;

  _Cell(this.elt);

}

class _Data {

  final List<_Cell> addrCells = _createAddrCells();
  final List<_Cell> instCells = _createInstCells();
  final List<_Cell> opcodeCells = _createOpCodeCells();
  final List<_Cell> dataCells = _createDataCells();

  static _createAddrCells() {
    final Html.TableSectionElement tbody = Html.querySelector('#debTbodyInstFlow');
    final lst = tbody.rows
      .map((tr) => new _Cell(tr.cells[0]))
      .toList();
    assert(lst != null, "_createAddrCells: addrList is null");
    assert(lst.length == INST_ROWS, "_createAddrCells: Invalid number of rows");
    return lst;
  }

  static _createOpCodeCells() {
    final Html.TableSectionElement tbody = Html.querySelector('#debTbodyInstFlow');
    final lst = tbody.rows
      .map((tr) => new _Cell(tr.cells[1]))
      .toList();
    assert(lst != null, "_createOpCodeCells: dataList is null");
    assert(lst.length == INST_ROWS, "_createOpCodeCells: Invalid number of rows");
    return lst;
  }

  static _createDataCells() {
    final Html.TableSectionElement tbody = Html.querySelector('#debTbodyInstFlow');
    final lst = tbody.rows
      .map((tr) => new _Cell(tr.cells[2]))
      .toList();
    assert(lst != null, "_createDataCells: dataList is null");
    assert(lst.length == INST_ROWS, "_createDataCells: Invalid number of rows");
    return lst;
  }

  static _createInstCells() {
    final Html.TableSectionElement tbody = Html.querySelector('#debTbodyInstFlow');
    final lst = tbody.rows
      .map((tr) => new _Cell(tr.cells[3]))
      .toList();
    assert(lst != null, "_createInstCells: InstList is null");
    assert(lst.length == INST_ROWS, "_createInstCells: Invalid number of rows");
    return lst;
  }

}

/*
** Update Cells according to Event
*/

void _onInstInfo(List<Instructions.Instruction> instList) {
  assert(instList != null && instList.length == INST_ROWS, "_onInstInfo($instList)");
  for (var i = 0; i < INST_ROWS; ++i) {
    _data.addrCells[i].elt.text = Ft.toAddressString(instList[i].addr, 4);
    _data.instCells[i].elt.text = instList[i].info.name;
    _data.opcodeCells[i].elt.text = Ft.toAddressString(instList[i].info.opCode, 2);
    switch (instList[i].info.dataSize)
    {
      case (0):
        _data.dataCells[i].elt.text = '--';
        break ;
      case (1):
        _data.dataCells[i].elt.text = '${Ft.toHexaString(instList[i].dataOpt, 2)}';
        break;
      case (2):
        _data.dataCells[i].elt.text = '${Ft.toHexaString(instList[i].dataOpt, 4)}';
        break;
      default : assert(false, 'onInstInfo: swith(datasize): failure');
    }
  }
  return ;
}

/*
** Global
*/

final _data = new _Data();
Emulator.Emulator _emu;

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  Ft.log('instruction_flow.dart', 'init');
  _emu = emu;
  _data.toString(); /* Tips to instanciate _cells */
  _onInstInfo(new List.generate(INST_ROWS, (i) {
      return new Instructions.Instruction(i, Instructions.instInfos[0], null);
    }));
  _emu.listener('InstInfo').forEach(_onInstInfo);
  return ;
}
