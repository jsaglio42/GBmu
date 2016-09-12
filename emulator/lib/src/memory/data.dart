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
  // final Uint16List _view16;

  AData(Uint8List d) : _data = d;
    // _view16 = d.buffer.asUint16List();

  int get size => _data.length;

  String toString()
    => '\{len: $size\}';

}

/* ReadOperation **************************************************************/

abstract class AReadOperation implements AData {

  int pull(int addr, DataType t)
  {
    switch(t)
    {
      case (DataType.BYTE) :
        assert(addr >= 0 && addr < this.size,
          Ft.loc2Str('ReadOp: $this', 'pull8', p:[addr]));
        return _data[addr];
      case (DataType.WORD) :
        assert(addr >= 0 && addr + 1 < this.size,
          Ft.loc2Str('ReadOp: $this', 'pull16', p:[addr]));
        return (_data[addr] + (_data[addr + 1] << 8));
      default : 
        assert(false, 'ReadOp: switch(dataType): failure');
    }
  }

  Uint8List pull8View(int addr, int len)
  {
    assert(addr >= 0 && addr + len < this.size,
        Ft.loc2Str('ReadOp: $this', 'pull8View', p:[addr, len]));
    return new Uint8List.view(_data.buffer, addr, len);
  }

  // int pull8(int addr)
  // {
  // assert(addr >= 0 && addr < this.size,
        // Ft.loc2Str('ReadOp: $this', 'pull8', p:[addr]));
    // return this._data[addr];
  // }
  
  // int pull16(int addr)
  // {
  // assert(addr % 2 == 0);
  // assert(addr >= 0 && addr + 1 < this.size,
  //       Ft.loc2Str('ReadOp: $this', 'pull16', p:[addr]));
  //   return (_data[addr] + (_data[addr + 1] << 8));
  // }

}

/* WriteOperation *************************************************************/

abstract class AWriteOperation implements AData  {

  void clear() { _data.fillRange(0, _data.length, 0); }

  void push(int addr, int v, DataType t)
  {
    assert(addr >= 0 && addr < this.size);
    switch(t)
    {
      case (DataType.BYTE) :
        assert(v & ~0xFF == 0,
          Ft.loc2Str('WriteOp: $this', 'push8', p:[addr]));
        assert(addr >= 0 && addr < this.size,
          Ft.loc2Str('WriteOp: $this', 'push8', p:[addr]));
        this._data[addr] = v;
        break ;
      case (DataType.WORD) :
        assert(v & ~0xFFFF == 0,
          Ft.loc2Str('WriteOp: $this', 'push16', p:[addr]));
        assert(addr >= 0 && addr + 1 < this.size,
          Ft.loc2Str('WriteOp: $this', 'push16', p:[addr]));
        _data[addr] = v & 0x00FF;
        _data[addr + 1] = v >> 8;
        break ;
      default :
        assert(false, 'WriteOp: switch(dataType): failure');
    }
  }

  // void push8(int addr, int v, DataType t)
  // {
  //   assert(addr >= 0 && addr < this.size);
  //   assert(byte & ~0xFF == 0);
  //   this._data[addr] = byte;
  //   return ;
  // }

  // void push16(int addr, int word)
  // {
  //   assert(addr % 2 == 0);
    // assert(addr >= 0 && addr + 1 < this.size);
    // assert(word & ~0xFFFF == 0);
    // _data[addr] = word & 0x00FF;
    // _data[addr + 1] = word >> 8;
  //   return ;
  // }

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
