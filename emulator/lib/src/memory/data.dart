// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   data.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 11:42:23 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/07 11:42:23 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:emulator/src/memory/headerdecoder.dart" as Headerdecoder;

/* Rom Implementation *********************************************************/

abstract class AData {

  final Uint8List _data;
  final Uint16List _view16;

  AData(Uint8List d) :
    _data = d,
    _view16 = d.buffer.asUint16List();

  int get size => this.size;

}

/* ReadOperation **************************************************************/

abstract class AReadOperation implements AData {

  int pull8(int addr)
  {
    assert(addr >= 0 && addr < this.size);
    return this._data[addr];
  }

  int pull16(int addr)
  {
    assert(addr % 2 == 0);
    assert(addr >= 0 && addr < this.size);
    final int addr_View16 = addr ~/ 2;
    return _view16[addr_View16];
  }

  Uint8List pull8View(int addr, int len)
  {
    assert(addr >= 0 && addr + len < this.size);
    return new Uint8List.view(_data.buffer, addr, len);
  }

}

/* WriteOperation *************************************************************/

abstract class AWriteOperation implements AData  {

  void  push8(int addr, int byte)
  {
    assert(addr >= 0 && addr < this.size);
    assert(byte & ~0xFF == 0);
    this._data[addr] = byte;
    return ;
  }

  void  push16(int addr, int word)
  {
    assert(addr % 2 == 0);
    assert(addr >= 0 && addr < this.size);
    assert(word & ~0xFFFF == 0);
    final int addr_View16 = addr ~/ 2;
    _view16[addr_View16] = word;
    return ;
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
