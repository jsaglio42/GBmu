// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   data.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 11:42:23 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/26 18:37:46 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:ft/ft.dart" as Ft;

import 'package:emulator/src/enums.dart';
import "package:emulator/src/hardware/headerdecoder.dart" as Headerdecoder;

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
  with AReadOperation, Headerdecoder.HeaderDecoder{

  Rom.ofUint8List(int memOffset, Uint8List l)
    : super(memOffset, l);

  Rom(int memOffset, int size)
    : super(memOffset, new Uint8List(size));

}

/* Ram ************************************************************************/
class Ram extends AData
  with AReadOperation, AWriteOperation {

  Ram.ofUint8List(int memOffset, Uint8List l)
    : super(memOffset, l);

  Ram(int memOffset, int size)
    : super(memOffset, new Uint8List(size));

}
