// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_style.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 20:45:11 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/03 00:05:09 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class HandlerStyle {

  // ATTRIBUTES ************************************************************* **
  final Emulator.Emulator _emu;
  final StoreEvents _se;
  final StoreMappings _sm;
  final List<Html.Element> _labels =
    Html.querySelectorAll('#spamming-label-container > span');

  // CONSTRUCTION *********************************************************** **
  HandlerStyle(this._emu, this._se, this._sm) {
    _se.onKeyMapUpdate.forEach(_onKeyMapUpdate);
    _emu.listener('JoypadSpamState').forEach(_onSpamChange);
  }

  // CALLBACKS ************************************************************** **
  void _onKeyMapUpdate(KeyMap m) {
    m.assign(_sm.getClaimedOpt(m));
  }

  void _onSpamChange(Emulator.EventSpamUpdate ev) {
    if (ev.activation)
      _labels[ev.key.index].style.display = '';
    else
      _labels[ev.key.index].style.display = 'none';
  }
}