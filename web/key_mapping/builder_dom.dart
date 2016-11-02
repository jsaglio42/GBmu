// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   builder_dom.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 18:04:45 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 20:10:49 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class BuilderDom {

  // ATTRIBUTES ************************************************************* **
  final Emulator.Emulator _emu;
  final StoreEvents _se;
  final StoreMappings _sm;
  final Html.TableSectionElement _joypadTbody =
    Html.querySelector('#joypad-table tbody');

  // CONSTRUCTION *********************************************************** **
  BuilderDom(this._emu, this._se, this._sm) {

    joypadInfo.forEach((JoypadKey jk, JoypadKeyInfo i) {
      makeJoypadRow(jk, i);
    });
  }

  // PRIVATE **************************************************************** **
  void makeJoypadRow(JoypadKey jk, JoypadKeyInfo info) {
    final Html.TableRowElement row = _createJoypadRow(info);
    KeyMap m;

    makeJoypadCell(jk, info, "pressrelease", row, info.defaultMapping[0]);
    makeJoypadCell(jk, info, "tap", row, info.defaultMapping[1]);
    makeJoypadCell(jk, info, "spamtoggle", row, info.defaultMapping[2]);

    _joypadTbody.nodes.add(row);
  }

  void makeJoypadCell(
      JoypadKey jk, JoypadKeyInfo info,
      String subType, Html.TableRowElement row, Key fallback) {
    final Html.TableCellElement cell = new Html.TableCellElement();
    final Html.ButtonElement but = new Html.ButtonElement();
    final KeyMap m = new KeyMap(_se, info.name + "." + subType, but, fallback,
        () => _emu.send('KeyDownEvent', jk),
        () => _emu.send('KeyUpEvent', jk));

    _sm.updateClaim(m, fallback); //TODO: remove

    but.text = fallback.toString();
    but.classes.add('btn-block');
    but.classes.add('btn');
    but.classes.add('btn-info');
    cell.nodes = [but];
    row.nodes.add(cell);
  }

  Html.TableRowElement _createJoypadRow(JoypadKeyInfo i) {
    final Html.TableRowElement t = new Html.TableRowElement();
    final Html.TableCellElement leftmost = new Html.TableCellElement();

    leftmost.text = i.name;
    t.nodes = [
      leftmost,
      // new Html.TableCellElement(),
      // new Html.TableCellElement(),
      // new Html.TableCellElement(),
      ];
    return t;
  }

}
