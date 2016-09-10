// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   registers.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/17 15:53:33 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 11:10:12 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

/*
 * Global Variable
 */

class _HtmlLabel {
  final Html.Element elt;
  bool value = false;

  _HtmlLabel(this.elt);
}
class _HtmlElement {
  final Html.TableCellElement elt;
  int value = 0;
  bool highlighted = false;

  _HtmlElement(this.elt);
}

class _DomData {
  final Map<Reg1, _HtmlLabel> flagLabels;
  final Map<Reg16, _HtmlElement> reg16Cells;

  _DomData(): this.table(_getTableElement());
  _DomData.table(Html.TableElement table)
    : flagLabels = _flagsElementsOfTable(table)
    , reg16Cells = _reg16ElementsOfTable(table);

  static _getTableElement()
  {
    final Html.Element body = Html.querySelector("#debColRegisters");
    assert(body != null, 'Could not find element in DOM');
    final Html.TableElement table = body.children?.first;
    assert(table != null, 'Could not table in element');
    return table;
  }

  static _reg16ElementsOfTable(Html.TableElement table)
  {
    var m = {};
    final it = new Ft.DoubleIterable(
        Ft.iterEnumData(Reg16, Reg16.values),
        Ft.iterTableRows(table).skip(2).take(6));

    it.forEach((Map m2, List<Html.TableCellElement> cells){
      assert(cells.length == 2, 'Unexpected list length');
      cells[0].text = m2['string']; //Side effect
      m[m2['value']] = new _HtmlElement(cells[1]);
    });
    return new Map<Reg16, _HtmlElement>.unmodifiable(m);
  }

  static _flagsElementsOfTable(Html.TableElement table)
  {
    final Html.TableRowElement row = table.rows?.elementAt(1);
    assert(row != null, "Could not find labels row");
    final Html.TableCellElement cell = row.cells[0];
    assert(cell != null, "Could not find labels cell");
    final List<Html.Element> labels = cell.children;
    assert(labels != null, "Could not find labels");
    final it = new Ft.DoubleIterable(
        Ft.iterEnumData(Reg1, Reg1.values),
        labels.reversed);
    var m = {};

    it.forEach((Map m2, Html.Element label){
      label.text = m2['string']; //Side effect
      m[m2['value']] = new _HtmlLabel(label);
    });

    return new Map<Reg1, _HtmlLabel>.unmodifiable(m);
  }
}

final _DomData _data = new _DomData();

/*
 * Internal Methods
 */

void _onRegInfo(Emulator.CpuRegs cpur) {
  toggleReg16Element(Reg16 reg, _HtmlElement cell){
    final int cur = cpur.pull16(reg);

    if (cell.value == cur) {
      if (cell.highlighted) {
        cell.elt.style.color = '#005B79';
        _data.reg16Cells[reg].highlighted = false;
      }
    }
    else {
      if (!cell.highlighted) {
        cell.elt.style.color = '#FF1E00';
        _data.reg16Cells[reg].highlighted = true;
      }
      cell.elt.text = Ft.toHexaString(cur, 4);
      _data.reg16Cells[reg].value = cur;
    }
    return ;
  };
  toggleFlagLabels(Reg1 reg, _HtmlLabel cell){
    final bool cur = cpur.pull1(reg);

    if (cell.value != cur) {
      _data.flagLabels[reg].value = cur;
      cell.elt.classes.toggle('label-default');
      cell.elt.classes.toggle('label-success');
    }
    return ;
  };
  _data.reg16Cells.forEach(toggleReg16Element);
  _data.flagLabels.forEach(toggleFlagLabels);
  return ;
}

/*
 * Exposed Methods
 */

void init(Emulator.Emulator emu) {
  Ft.log('registers.dart', 'init', [emu]);
  _data.toString(); /* Tips to instanciate _data */
  emu.listener('RegInfo').listen(_onRegInfo);
  return ;
}
