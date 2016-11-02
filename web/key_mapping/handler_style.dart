// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_style.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 20:45:11 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 20:46:54 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class HandlerStyle {

  // ATTRIBUTES ************************************************************* **
  final StoreEvents _se;
  final StoreMappings _sm;

  // CONSTRUCTION *********************************************************** **
  HandlerStyle(this._se, this._sm) {
    _se.onKeyMapUpdate.forEach(_onKeyMapUpdate);
  }

  // CALLBACKS ************************************************************** **
  void _onKeyMapUpdate(KeyMap m) {
    m.assign(_sm.getClaimedOpt(m));
  }

}