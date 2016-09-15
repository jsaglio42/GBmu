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

  final Uint8List _data;

  AData(Uint8List d) : _data = d;

  int get size => _data.length;

  String toString() => '\{len: ${this.size}\}';

}

/* ReadOperation **************************************************************/

abstract class AReadOperation implements AData {

  int pull8(int addr)
  {
    if (addr < 0 || addr >= this.size)
      throw new Exception("Read Operation: $addr out of [0 - ${this.size}[");
    else
      return _data[addr];
  }

  Uint8List pull8View(int addr, int len)
  {
    if (addr < 0 || addr + len >= this.size)
      throw new Exception("Read Operation: ($addr + $len) out of [0 - ${this.size}[");
    else
      return new Uint8List.view(_data.buffer, addr, len);
  }

}

/* WriteOperation *************************************************************/

abstract class AWriteOperation implements AData  {

  void clear() { _data.fillRange(0, this.size, 0); }

  void push8(int addr, int v)
  {
    assert ((v & ~0xFF) == 0, "Write Operation: data limited to 1byte");
    if (addr < 0 || addr >= this.size)
      throw new Exception("Write Operation: $addr out of [0 - ${this.size}[");
    else
      this._data[addr] = v;
  }

}

/* Memory Classes *************************************************************/

class Rom extends AData
	with AReadOperation, Headerdecoder.AHeaderDecoder {

  Rom(Uint8List d) : super(d);

}

class Ram extends AData
	with AReadOperation, AWriteOperation {

  Ram(Uint8List d) : super(d);

}

class VideoRam extends AData
  with AReadOperation, AWriteOperation {

  VideoRam(Uint8List d) : super(d);

}

class WorkingRam extends AData
  with AReadOperation, AWriteOperation {

  WorkingRam(Uint8List d) : super(d);

}

class TailRam extends AData
  with AReadOperation, AWriteOperation {

  TailRam(Uint8List d) : super(d);

}
