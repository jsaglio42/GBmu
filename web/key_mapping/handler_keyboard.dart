// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_keyboard.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 17:59:46 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/03 13:17:24 by ngoguey          ###   ########.fr       //
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

    // print('$k '
    //     '${ev.repeat} '
    //     '${_is_modifier(ev)} '
    //     '${Html.document.activeElement.runtimeType}');
    if (_is_modifier(ev))
        ev.preventDefault();
    else if (!ev.repeat
        && Html.document.activeElement is! Html.InputElement) {
      if (_pm.useKeyPress(k) || _pa.useKeyPress(k))
        ev.preventDefault();
    }
    return ;
  }

  void _onKeyUp(Html.KeyboardEvent ev){
    final Key k = new Key.ofKeyboardEvent(ev);

    if (_is_modifier(ev))
        ev.preventDefault();
    else if (!ev.repeat
        && Html.document.activeElement is! Html.InputElement) {
      if (_pm.useKeyRelease(k) || _pa.useKeyRelease(k))
        ev.preventDefault();
    }
    return ;
  }

  // PRIVATE **************************************************************** **

  bool _is_modifier(Html.KeyboardEvent ev) {
    final int k = ev.which;

    if (false
        // || k == 20 /* Caps lock */
        || k == 16 /* Shift */
        // || k == 9 /* Tab */
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
