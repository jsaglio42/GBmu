// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   data.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 11:42:23 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 11:56:29 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:ft/ft.dart" as Ft;

import 'package:emulator/src/enums.dart';
import "package:emulator/src/memory/headerdecoder.dart" as Headerdecoder;

/* Rom Implementation *********************************************************/

abstract class AData {

  final int start;
  final Uint8List _data;

  AData(int start, int len)
    : this.startAddress = start
    , _data = new Uint8List(len);

  /* API */
  int get size => _data.length;
  String toString() => '[${startAddress} - ${startAddress + this.size}]';

  /* Virtual */
  int pull8(int addr);
  void push8(int addr, int v);

}

/* ReadOperation **************************************************************/

abstract class AReadOperation implements AData {

  int pull8_unsafe(int addr) {
    addr -= startAddress;
    if (addr < 0 || addr >= this.size)
      throw new Exception("Read Operation: $addr out of ${this.toString()}");
    else
      return _data[addr];
  }

  Uint8List pull8View_unsafe(int addr, int len) {
    addr -= startAddress;
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
    addr -= startAddress;
    if (addr < 0 || addr >= this.size)
      throw new Exception("Write Operation: $addr out of ${this.toString()}");
    else
      this._data[addr] = v;
}
