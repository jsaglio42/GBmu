// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_mapper.dart                               :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 17:22:15 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/03 11:43:06 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class PlatformMapper {

  // ATTRIBUTES ************************************************************* **
  final StoreEvents _se;
  final StoreMappings _sm;
  final List<Html.ButtonElement> _buts = [
    Html.querySelector('#mapping-button-container .ft-cancel'),
    Html.querySelector('#mapping-button-container .ft-default'),
    Html.querySelector('#mapping-button-container .ft-remove'),
  ];
  KeyMap _pushedOpt = null;

  // CONSTRUCTION *********************************************************** **
  PlatformMapper(this._se, this._sm) {
    _se.onClick.forEach(_onClick);
    _se.onDoubleClick.forEach(_onDoubleClick);
    _buts[0].onClick.forEach(_onClickCancel);
    _buts[1].onClick.forEach(_onClickDefault);
    _buts[2].onClick.forEach(_onClickRemove);
  }

  // PUBLIC ***************************************************************** **
  bool useKeyPress(Key k) {
    KeyMap tmp;

    if (_pushedOpt != null) {
      _unbindOptClaimer(k);
      _sm.updateClaim(_pushedOpt, k);
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
  }

  void _onClickCancel(_) {
    _unpush();
  }

  void _onClickDefault(_) {
    _unbindOptClaimer(_pushedOpt.fallback);
    _sm.updateClaim(_pushedOpt, _pushedOpt.fallback);
    _unpush();
  }

  void _onClickRemove(_) {
    _sm.updateClaim(_pushedOpt, null);
    _unpush();
  }

  // PRIVATE **************************************************************** **
  void _unbindOptClaimer(Key k) {
    KeyMap tmp;

    tmp = _sm.getClaimerOpt(k);
    if (tmp != null)
      _sm.updateClaim(tmp, null);
  }

  void _unpush() {
    assert(_pushedOpt != null);
    _pushedOpt.unpush();
    _pushedOpt = null;
    _buts.forEach((b) => b.style.visibility = 'hidden');
  }

  void _push(KeyMap m) {
    assert(_pushedOpt == null);
    _pushedOpt = m;
    _pushedOpt.push();
    _buts.forEach((b) => b.style.visibility = 'visible');
  }

}
