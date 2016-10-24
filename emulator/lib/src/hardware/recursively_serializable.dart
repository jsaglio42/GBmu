// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   recursively_serializable.dart                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/22 18:33:06 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/24 18:31:49 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'package:ft/ft.dart' as Ft;

class Field {

  final String _name;
  final _get;
  final _set;

  Field(this._name, this._get, this._set);

}

abstract class RecursivelySerializable {

  // ABSTRACT *************************************************************** **
  Iterable<RecursivelySerializable> get serSubdivisions;
  Iterable<Field> get serFields;

  // PUBLIC ***************************************************************** **
  Map recSerialize() {
    final Map m = {};
    int i = 0;

    // Ft.log('$runtimeType', 'recSerialize');
    for (Field f in this.serFields) {
      m[f._name] = f._get();
    }
    for (RecursivelySerializable sub in this.serSubdivisions) {
      m['__subdivision$i'] = sub.recSerialize();
      i++;
    }
    return m;
  }
  void recUnserialize(Map m) {
    int i = 0;

    // Ft.log('$runtimeType', 'recUnserialize');
    if (!_fieldsPresent(m))
      throw new Exception(
          '$runtimeType.unserialialize($m) missing field');
    if (!_subdivisionsPresent(m))
      throw new Exception(
          '$runtimeType.unserialialize($m) missing subdivision');

    for (Field f in this.serFields)
      f._set(m[f._name]);
    for (RecursivelySerializable sub in this.serSubdivisions) {
      sub.recUnserialize(m['__subdivision$i']);
      i++;
    }
  }

  // PRIVATE **************************************************************** **
  bool _fieldsPresent(Map m) =>
    this.serFields.every((Field f) => m.containsKey(f._name));

  bool _subdivisionsPresent(Map m) {
    int i = this.serSubdivisions.length;
    while (i-- > 0) {
      if (!m.containsKey('__subdivision$i'))
        return false;
    }
    return true;
  }

}