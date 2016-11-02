// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   key_map.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 16:00:11 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/02 20:48:04 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class KeyMap {

  // ATTRIBUTES ************************************************************* **
  final StoreEvents _se;

  final String name;
  final Html.ButtonElement b;
  final Key fallback;
  final pressActionOpt;
  final releaseActionOpt;

  bool _pushed = false;

  // CONSTRUCTION *********************************************************** **
  KeyMap(this._se, this.name, this.b, this.fallback,
      this.pressActionOpt, this.releaseActionOpt) {
    b.onClick.forEach(_onClick);
    b.onDoubleClick.forEach(_onDoubleClick);
    b.text = "\u00A0";
  }

  // PUBLIC ***************************************************************** **
  // Inner key ****************************************** **
  void assign(Key kOpt) {
    print(kOpt);
    if (kOpt == null)
      b.text = "\u00A0";
    else
      b.text = kOpt.toString();
  }

  // Button style *************************************** **
  void push() {
    assert(!_pushed);
    _pushed = true;
    b.classes.remove('btn-info');
    b.classes.add('btn-success');
  }

  void unpush() {
    assert(_pushed);
    _pushed = false;
    b.classes.remove('btn-success');
    b.classes.add('btn-info');
  }

  // CALLBACKS ************************************************************** **
  void _onClick(_) {
    _se.click(this);
  }

  void _onDoubleClick(_) {
    _se.doubleClick(this);
  }

  String toString() {
    return name;
  }

}
