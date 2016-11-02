// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_mapper.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 17:22:15 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 20:09:12 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class PlatformMapper {

  // ATTRIBUTES ************************************************************* **
  final StoreEvents _se;
  final StoreMappings _sm;
  KeyMap _pushedOpt = null;

  // CONSTRUCTION *********************************************************** **
  PlatformMapper(this._se, this._sm) {
    _se.onClick.forEach(_onClick);
    _se.onDoubleClick.forEach(_onDoubleClick);
  }

  // PUBLIC ***************************************************************** **
  bool useKeyPress(Key k) {
    KeyMap tmp;

    if (_pushedOpt != null) {
      tmp = _sm.getClaimerOpt(k);
      if (tmp != null) {
        _sm.updateClaim(tmp, null);
        tmp.assign(null);
      }
      _sm.updateClaim(_pushedOpt, k);
      _pushedOpt.assign(k);
      _unpush();
      return true;
    }
    return false;
  }

  bool useKeyRelease(_) {
    return false;
  }

  // CALLBACKS ************************************************************** **
  void _onClick(KeyMap m) {
    if (_pushedOpt == m) {
      _unpush();
    }
    else if (_pushedOpt != null) {
      _unpush();
      _push(m);
    }
    else {
      _push(m);
    }
  }

  void _onDoubleClick(KeyMap m) {
    if (_pushedOpt != null)
      _unpush();
    _sm.updateClaim(m, null);
    m.assign(null);
 }

  // PRIVATE **************************************************************** **
  void _unpush() {
    assert(_pushedOpt != null);
    _pushedOpt.unpush();
    _pushedOpt = null;
  }

  void _push(KeyMap m) {
    assert(_pushedOpt == null);
    _pushedOpt = m;
    _pushedOpt.push();
  }
}