// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   builder_dom.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 18:04:45 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 22:59:15 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class BuilderDom {

  // ATTRIBUTES ************************************************************* **
  final Emulator.Emulator _emu;
  final StoreEvents _se;
  final StoreMappings _sm;
  final PlatformLocalStorage _pls;
  final Html.TableSectionElement _joypadTbody =
    Html.querySelector('#joypad-table tbody');

  // CONSTRUCTION *********************************************************** **
  BuilderDom(this._emu, this._se, this._sm, this._pls) {

    joypadInfo.forEach((JoypadKey jk, JoypadKeyInfo i) {
      _makeJoypadRow(jk, i);
    });
  }

  // PRIVATE **************************************************************** **
  void _makeJoypadRow(JoypadKey jk, JoypadKeyInfo info) {
    final Html.TableRowElement row = _createJoypadRow(info);
    KeyMap m;

    callback(JoypadActionType type, bool press) {
      return () {
        _emu.send('RequestJoypad', new Emulator.RequestJoypad(jk, type, press));
      };
    };

    _makeJoypadCell(
        jk, info, JoypadActionType.PressRelease, row, info.defaultMapping[0],
        callback(JoypadActionType.PressRelease, true),
        callback(JoypadActionType.PressRelease, false));
    _makeJoypadCell(
        jk, info, JoypadActionType.Tap, row, info.defaultMapping[1],
        callback(JoypadActionType.Tap, true),
        null);
    _makeJoypadCell(
        jk, info, JoypadActionType.SpamToggle, row, info.defaultMapping[2],
        callback(JoypadActionType.SpamToggle, true),
        null);
    _joypadTbody.nodes.add(row);
  }

  void _makeJoypadCell(
      JoypadKey jk, JoypadKeyInfo info, JoypadActionType type,
      Html.TableRowElement row, Key fallback,
      onPress, onRelease) {
    final Html.TableCellElement cell = new Html.TableCellElement();
    final Html.ButtonElement but = new Html.ButtonElement();
    final String name = info.name + "." + type.toString();
    final KeyMap m = new KeyMap(_se, name, but, fallback, onPress, onRelease);
    final Key kOpt = _pls.getKeyOpt(m, fallback);

    _sm.updateClaim(m, kOpt);
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
    t.nodes = [leftmost];
    return t;
  }

}
