// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tile.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 12:05:15 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;

/* Tile ************************************************************************/
class Tile extends Ser.RecursivelySerializable {

  Uint8List _colorIDs = new Uint8List(8 * 8);
  Uint8List _values = new Uint8List(8 * 2);

  /* API */
  int getColorID(int x, int y, bool flipX, bool flipY) {
    if (flipX)
      x = 7 - x;
    if (flipY)
      y = 7 - y;
    return _colorIDs[y * 8 + x];
  }

  int operator[](int i){
    return _values[i];
  }

  void operator[]=(int i, int v){
    _values[i] = v;
    _updateLine(i ~/ 2);
    return ;
  }

  String toString() {
    return _values.toString();
  }

  /* Private */
  void _updateLine(int line) {
    int low = _values[2 * line];
    int high = _values[2 * line + 1];
    for (int x = 0; x < 8; ++x)
    {
      _colorIDs[8 * line + (7 - x)] = (low & 0x1) | ((high & 0x1) << 1);
      low >>= 1;
      high >>= 1;
    }
    return ;
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('_colorIDs', () => _colorIDs, (v) {
            _colorIDs = new Uint8List.fromList(v);
          }),
      new Ser.Field('_values', () => _values, (v) {
            _values = new Uint8List.fromList(v);
          }),
    ];
  }

}
