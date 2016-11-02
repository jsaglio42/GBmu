// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_keyboard.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 17:59:46 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 22:42:52 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class HandlerKeyboard {

  // ATTRIBUTES ************************************************************* **
  final PlatformMapper _pm;
  final PlatformActivator _pa;

  // CONSTRUCTION *********************************************************** **
  HandlerKeyboard(this._pm, this._pa) {

    Html.window.onKeyDown.forEach(_onKeyDown);
    Html.window.onKeyUp.forEach(_onKeyUp);
  }

  // CALLBACKS ************************************************************** **
  void _onKeyDown(Html.KeyboardEvent ev){
    final Key k = new Key.ofKeyboardEvent(ev);

    // print(k);
    // print(ev.repeat);
    if (!ev.repeat
        && !_is_modifier(ev)
        && Html.document.activeElement is! Html.InputElement) {
      if (_pm.useKeyPress(k) || _pa.useKeyPress(k))
        ev.preventDefault();
    }
    return ;
  }

  void _onKeyUp(Html.KeyboardEvent ev){
    final Key k = new Key.ofKeyboardEvent(ev);

    if (!_is_modifier(ev)
        && Html.document.activeElement is! Html.InputElement) {
      if (_pm.useKeyRelease(k) || _pa.useKeyRelease(k))
        ev.preventDefault();
    }
    return ;
  }

  // PRIVATE **************************************************************** **

  bool _is_modifier(Html.KeyboardEvent ev) {
    final int k = ev.which;

    if (k == 20 /* Caps lock */
        || k == 16 /* Shift */
        || k == 9 /* Tab */
        // || k == 27 /* Escape Key */
        || k == 17 /* Control Key */
        || k == 91 /* Windows Command Key */
        // || k == 19 /* Pause Break */
        || k == 18 /* Alt Key */
        // || k == 93 /* Right Click Point Key */
        // || ( k >= 35 && k <= 40 ) /* Home, End, Arrow Keys */
        // || k == 45 /* Insert Key */
        // || ( k >= 33 && k <= 34 ) /*Page Down, Page Up */
        // || (k >= 112 && k <= 123) /* F1 - F12 */
        // || (k >= 144 && k <= 145 ) /* Num Lock, Scroll Lock */
        )
      return true;
    else
      return false;
  }
}
  // Private ****************************************************************** **
  /* Store the status of button: (false = released, true = pressed) */
  // Map<int, dynamic> _keySettings = <int, dynamic>{
  //   75 : JoypadKey.A,
  //   76 : JoypadKey.B,
  //   16 : JoypadKey.Select,
  //   13 : JoypadKey.Start,
  //   70 : JoypadKey.Right,
  //   83 : JoypadKey.Left,
  //   69 : JoypadKey.Up,
  //   68 : JoypadKey.Down,
  // }
  //   ..addAll(Cs.g_keyMapping);

  // Map<dynamic, int> _reverseKeySettings;

  // Map<JoypadKey, bool> _keyState = new Map<dynamic, bool>.fromIterable(
  //     _keySettings.values.where((v) => v is JoypadKey),
  //     key:(v) => v, value: (_) => false);

  // ************************************************************************** **

  // void _updateRevMap() {
  //   _reverseKeySettings = new Map<dynamic, int>.fromIterables(
  //       _keySettings.values, _keySettings.keys);
  // }

  // void _updateKey(JoypadKey k, int code) { //Unused yet
  //   final key = _keySettings[eventKeyCode];

  //   if (key != null) {
  //     // TODO: issue error
  //   }
  //   else {
  //     if (!_keySettings.removeValue(k))
  //       assert(false, "from: _updateKey");
  //     _keySettings[code] = k;
  //     _keyState[k] = false;
  //     _updateRevMap();
  //   }
  // }

  // ************************************************************************** **

  // void init(Emulator.Emulator emu, Cs.Cs cs) {
  //   _emu = emu;
  //   _cs = cs;
  //   _updateRevMap();
  //   Html.window.onKeyDown.forEach(_onKeyDown);
  //   Html.window.onKeyUp.forEach(_onKeyUp);
  //   return ;
  // }
