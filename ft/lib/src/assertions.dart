// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   assertions.dart                                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/22 15:28:46 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/22 15:40:31 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

class BinaryToggle {

  bool _state;
  bool get state => _state;

  BinaryToggle._(this._state);

  bool toggleTrueValid() {
    if (_state == true)
      return false;
    else {
      _state = true;
      return true;
    }
  }

  bool toggleFalseValid() {
    if (_state == false)
      return false;
    else {
      _state = false;
      return true;
    }
  }
}

BinaryToggle checkedOnlyBinaryToggle(bool value) {
  BinaryToggle ret;

  assert((){
    ret = new BinaryToggle._(value);
    return true;
  }());
  return ret;
}
