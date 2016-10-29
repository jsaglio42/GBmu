// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   registers.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/17 15:53:33 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/29 15:38:44 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:html' as Html;
import 'package:ft/ft.dart' as Ft;
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;

/*
 * Global Variable
 */

const List<String> _SPECIAL_FLAGS_LIST = const <String>['ime',  'halt', 'stop'];

bool _speFlagValueOfName(Emulator.CpuRegs cpur, String name) {
  switch (name) {
    case ('ime'): return cpur.ime;
    case ('halt'): return cpur.halt;
    case ('stop'): return cpur.stop;
  }
}

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
  final Map<String, _HtmlLabel> speFlagLabels;

  _DomData(): this.table(_getTableElement());
  _DomData.table(Html.TableElement table)
    : flagLabels = _flagsElementsOfTable(table)
    , reg16Cells = _reg16ElementsOfTable(table)
    , speFlagLabels = _speFlagsElementsOfTable(table);

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
    final List<Html.Element> labels = table.querySelectorAll('.cpur-flag');
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

  static _speFlagsElementsOfTable(Html.TableElement table)
  {
    final it = new Ft.DoubleIterable(
        _SPECIAL_FLAGS_LIST, table.querySelectorAll('.cpur-spe-flag'));
    var m = {};

    it.forEach((String name, Html.Element label){
      label.text = name;
      m[name] = new _HtmlLabel(label);
    });
    return m;
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
        cell.highlighted = false;
      }
    }
    else {
      if (!cell.highlighted) {
        cell.elt.style.color = '#FF1E00';
        cell.highlighted = true;
      }
      cell.elt.text = Ft.toHexaString(cur, 4);
      cell.value = cur;
    }
    return ;
  };
  toggleFlagLabels(Reg1 reg, _HtmlLabel cell){
    final bool cur = (cpur.pull1(reg) == 1);

    if (cell.value != cur) {
      cell.value = cur;
      cell.elt.classes.toggle('label-default');
      cell.elt.classes.toggle('label-success');
    }
    return ;
  };
  toggleSpeFlagLabels(String name, _HtmlLabel cell){
    final bool cur = (_speFlagValueOfName(cpur, name));

    if (cell.value != cur) {
      cell.value = cur;
      cell.elt.classes.toggle('label-default');
      cell.elt.classes.toggle('label-success');
    }
    return ;
  };
  _data.reg16Cells.forEach(toggleReg16Element);
  _data.flagLabels.forEach(toggleFlagLabels);
  _data.speFlagLabels.forEach(toggleSpeFlagLabels);
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
