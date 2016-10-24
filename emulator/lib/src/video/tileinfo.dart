// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tileinfo.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/24 18:24:32 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;

/* TileInfo ********************************************************************/
class TileInfo extends Ser.RecursivelySerializable {

  TileInfo();

  int _value = 0;

  bool _priorityIsBG = false;
  bool _flipY = false;
  bool _flipX = false;
  int _OBP_DMG = 0;
  int _bankID = 0;
  int _OBP_CGB = 0;

  int get value => _value;
  void set value(int v) {
    _priorityIsBG = (v >> 7) & 0x1 == 1;
    _flipY = (v >> 6) & 0x1 == 1;
    _flipX = (v >> 5) & 0x1 == 1;
    _OBP_DMG = (v >> 4) & 0x1;
    _bankID = (v >> 3) & 0x1;
    _OBP_CGB = v & 0x7;
    _value = v;
    return ;
  }

  bool get priorityIsBG => _priorityIsBG;
  bool get flipY => _flipY;
  bool get flipX => _flipX;
  int get OBP_DMG => _OBP_DMG;
  int get bankID => _bankID;
  int get OBP_CGB => _OBP_CGB;

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('_value', () => _value, (v) => _value = v),
      new Ser.Field('_priorityIsBG', () => _priorityIsBG, (v) => _priorityIsBG = v),
      new Ser.Field('_flipY', () => _flipY, (v) => _flipY = v),
      new Ser.Field('_flipX', () => _flipX, (v) => _flipX = v),
      new Ser.Field('_OBP_DMG', () => _OBP_DMG, (v) => _OBP_DMG = v),
      new Ser.Field('_bankID', () => _bankID, (v) => _bankID = v),
      new Ser.Field('_OBP_CGB', () => _OBP_CGB, (v) => _OBP_CGB = v),
    ];
  }

}
