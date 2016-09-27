// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tmp_emulator_types.dart                            :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/27 15:48:07 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/27 16:06:29 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:typed_data';
import "package:ft/ft.dart" as Ft;

import './tmp_emulator_enums.dart';
// import 'package:emulator/src/enums.dart';
// import "package:emulator/src/hardware/headerdecoder.dart" as Headerdecoder;

abstract class Serializable {
  dynamic serialize();
}

abstract class SerializableData implements AData {
  dynamic serialize() =>
    <String, dynamic>{
      'data': _data,
      // TODO: filename
    };
}

/* Data Implementation ********************************************************/
abstract class AData {

  final int memOffset;
  final Uint8List _data;

  AData(this.memOffset, this._data);

  /* API */
  int get size => _data.length;
  String toString() => '[${memOffset} - ${memOffset + this.size}]';

}

/* ReadOperation **************************************************************/
abstract class AReadOperation implements AData {

  int pull8_unsafe(int addr) {
    addr -= memOffset;
    if (addr < 0 || addr >= this.size)
      throw new Exception("Read Operation: $addr out of ${this.toString()}");
    else
      return _data[addr];
  }

  Uint8List pull8View_unsafe(int addr, int len) {
    addr -= memOffset;
    if (addr < 0 || addr + len >= this.size)
      throw new Exception("Read Operation: $addr out of ${this.toString()}");
    else
      return new Uint8List.view(_data.buffer, addr, len);
  }

}

/* WriteOperation *************************************************************/
abstract class AWriteOperation implements AData  {

  void clear() { _data.fillRange(0, this.size, 0); }

  void push8_unsafe(int addr, int v) {
    assert ((v & ~0xFF) == 0, "Write Operation: data limited to 1byte");
    addr -= memOffset;
    if (addr < 0 || addr >= this.size)
      throw new Exception("Write Operation: $addr out of ${this.toString()}");
    else
      this._data[addr] = v;
  }

}

/* Rom ************************************************************************/
class Rom extends AData
  with AReadOperation
  , SerializableData
  implements Serializable {

  Rom.ofUint8List(int memOffset, Uint8List l)
    : super(memOffset, l);

  Rom(int memOffset, int size)
    : super(memOffset, new Uint8List(size));

  dynamic pullHeaderValue(RomHeaderField _) {
    return 42;
  }

}

/* Ram ************************************************************************/
class Ram extends AData
  with AReadOperation, AWriteOperation
  , SerializableData
  implements Serializable {

  Ram.ofUint8List(int memOffset, Uint8List l)
    : super(memOffset, l);

  Ram(int memOffset, int size)
    : super(memOffset, new Uint8List(size));

}
