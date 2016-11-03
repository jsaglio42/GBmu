// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   key.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/02 15:29:03 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/03 13:17:07 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of key_mapping;

class Key {

  // ATTRIBUTES ************************************************************* **
  final String code;
  final int keyCode;
  final bool altKey;
  final bool ctrlKey;
  final bool metaKey;
  final bool shiftKey;

  // CONSTRUCTION *********************************************************** **
  const Key(this.code, this.keyCode,
      this.altKey, this.ctrlKey, this.metaKey, this.shiftKey);

  Key.ofKeyboardEvent(Html.KeyboardEvent ev)
    : code = ev.code
    , keyCode = ev.keyCode
    , altKey = ev.altKey
    , ctrlKey = ev.ctrlKey
    , metaKey = ev.metaKey
    , shiftKey = ev.shiftKey;

  Key.ofJson(String s) : this.ofMap(JSON.decode(s));

  Key.ofMap(Map<String, dynamic> m)
    : code = m['code']
    , keyCode = m['keyCode']
    , altKey = m['altKey']
    , ctrlKey = m['ctrlKey']
    , metaKey = m['metaKey']
    , shiftKey = m['shiftKey'] {
      if (m['code'] == null) throw new Exception('Key.ofMap() missing code field');
      if (m['keyCode'] == null) throw new Exception('Key.ofMap() missing keyCode field');
      if (m['altKey'] == null) throw new Exception('Key.ofMap() missing altKey field');
      if (m['ctrlKey'] == null) throw new Exception('Key.ofMap() missing ctrlKey field');
      if (m['metaKey'] == null) throw new Exception('Key.ofMap() missing metaKey field');
      if (m['shiftKey'] == null) throw new Exception('Key.ofMap() missing shiftKey field');
  }

  // PUBLIC ***************************************************************** **
  bool eventPresses(Html.KeyboardEvent ev) {
    if (keyCode == ev.keyCode
        && altKey == ev.altKey
        && ctrlKey == ev.ctrlKey
        && metaKey == ev.metaKey
        && shiftKey == ev.shiftKey)
      return true;
    else
      return false;
  }

  bool eventReleases(Html.KeyboardEvent ev) {
    if (keyCode == ev.keyCode)
      return true;
    else
      return false;
  }

  Map<String, dynamic> toMap() =>
    <String, dynamic>{
      'code': this.code,
      'keyCode': this.keyCode,
      'altKey': this.altKey,
      'ctrlKey': this.ctrlKey,
      'metaKey': this.metaKey,
      'shiftKey': this.shiftKey,
  };

  String toJson() =>
    JSON.encode(this.toMap());

  String toString() {
    String s = "";

    if (altKey)
      s += "a-";
    if (ctrlKey)
      s += "c-";
    if (metaKey)
      s += "m-";
    if (shiftKey)
      s += "s-";
    return s + code;
  }

  int get hashCode =>
    (altKey ? 1 : 0)
    | (ctrlKey ? 2 : 0)
    | (metaKey ? 4 : 0)
    | (shiftKey ? 8 : 0)
    | (keyCode << 4);

  operator ==(Key that) =>
    keyCode == that.keyCode
    && altKey == that.altKey
    && ctrlKey == that.ctrlKey
    && metaKey == that.metaKey
    && shiftKey == that.shiftKey;

}
