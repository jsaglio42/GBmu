// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_local_storage.dart                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 20:26:24 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 20:40:39 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class PlatformLocalStorage {

  // ATTRIBUTES ************************************************************* **
  final StoreEvents _se;
  final StoreMappings _sm;

  // CONSTRUCTION *********************************************************** **
  PlatformLocalStorage(this._se, this._sm) {
    _se.onKeyMapUpdate.forEach(_onKeyMapUpdate);
  }

  // CALLBACKS ************************************************************** **
  void _onKeyMapUpdate(KeyMap m) {
    print('_onKeyMapUpdate');
    final Key k = _sm.getClaimedOpt(m);

    if (k == null)
      Html.window.localStorage[m.name] = 'null';
    else
      Html.window.localStorage[m.name] = k.toJson();
  }

  // PUBLIC ***************************************************************** **
  Key getKeyOpt(KeyMap m, Key fallback) {
    if (Html.window.localStorage[m.name] == 'null')
      return null;
    else if (Html.window.localStorage[m.name] == null)
      return fallback;
    try {
      return new Key.ofJson(Html.window.localStorage[m.name]);
    }
    catch (_) {
      return fallback;
    }
  }

}