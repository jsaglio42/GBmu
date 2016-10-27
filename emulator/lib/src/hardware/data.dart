// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   data.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 11:42:23 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/27 23:45:09 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

library gbmu_data;

import "dart:typed_data";
import "dart:convert";
import "package:ft/ft.dart" as Ft;

import 'package:emulator/src/enums.dart';
import 'package:emulator/src/constants.dart';
import 'package:emulator/src/variants.dart' as V;
import "package:emulator/src/hardware/headerdecoder.dart" as Headerdecoder;
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;
import 'package:emulator/src/gameboy.dart' as GameBoy;

part 'package:emulator/src/hardware/file_repr.dart';
part 'package:emulator/src/hardware/save_state.dart';

/* Data Implementation ********************************************************/
abstract class AData {

  int _memOffset;
  Uint8List _data;

  AData(this._memOffset, this._data);

  /* API */
  int get memOffset => _memOffset;
  int get size => _data.length;
  String toString() => '[${memOffset} - ${memOffset + this.size}]';

}

/* ReadOperation **************************************************************/
abstract class AReadOperation implements AData {

  int pull8(int addr) {
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
abstract class AWriteOperation implements AData {

  void push8(int addr, int v) {
    assert ((v & ~0xFF) == 0, "Write Operation: data limited to 1byte");
    addr -= memOffset;
    if (addr < 0 || addr >= this.size)
      throw new Exception("Write Operation: $addr out of ${this.toString()}");
    else
      this._data[addr] = v;
  }

}

// Rom ********************************************************************** **
class Rom extends AData
  with AReadOperation, Headerdecoder.HeaderDecoder, FileRepr, FileReprData {

  // CONSTRUCTION *********************************************************** **
  // Only called once in DOM, when an external file is loaded
  Rom.ofFile(String fileName, Uint8List data)
    : super(0, data) {
    _frd_init(fileName);
    Ft.log('Rom', 'ctor.ofFile', [this.fileName, this.terseData]);
  }

  // Only called from Emulator, on emulation start request, with data from Idb
  Rom.unserialize(Map<String, dynamic> serialization)
    : super(0, serialization['data'] as Uint8List) {
    _frd_init(serialization['fileName'] as String);
    Ft.log('Rom', 'ctor.unserialize', [this.fileName, this.terseData]);
  }

  // FROM FILEREPRDATA ****************************************************** **
  V.Component get type => V.Rom.v;
  Map<String, dynamic> get terseData => <String, dynamic>{
    'ramSize': this.pullHeaderValue(RomHeaderField.RAM_Size),
    'globalChecksum': this.pullHeaderValue(RomHeaderField.Global_Checksum),
  };

}

// Ram ********************************************************************** **
class Ram extends AData
  with AReadOperation, AWriteOperation, FileRepr, FileReprData
  , Ser.RecursivelySerializable
{

  // CONSTRUCTION *********************************************************** **
  // Only called in DOM, when an external file is loaded
  Ram.ofFile(String fileName, Uint8List data)
    : super(0, data) {
    _frd_init(fileName);
    Ft.log('Ram', 'ctor.ofFile', [this.fileName, this.terseData]);
  }

  // Only called from Emulator, on emulation start request, with data from Idb
  Ram.unserialize(Map<String, dynamic> serialization)
    : super(0, serialization['data'] as Uint8List) {
    _frd_init(serialization['fileName'] as String);
    Ft.log('Ram', 'ctor.unserialize', [this.fileName, this.terseData]);
  }

  // Only called from Emulator, on emulation start request, with no data
  Ram.empty(Rom rom)
    : super(0, new Uint8List(rom.pullHeaderValue(RomHeaderField.RAM_Size))) {
    _frd_init(FileRepr.ramNameOfRomName(rom.fileName));
    Ft.log('Ram', 'ctor.empty', [this.fileName, this.terseData]);
  }

  // Only called from DOM, when an extraction is requested
  Ram.emptyDetail(String romName, int size)
    : super(0, new Uint8List(size)) {
    _frd_init(FileRepr.ramNameOfRomName(romName));
    Ft.log('Ram', 'ctor.emptyDetail', [this.fileName, this.terseData]);
  }

  // FROM FILEREPRDATA ****************************************************** **
  V.Component get type => V.Ram.v;
  Map<String, dynamic> get terseData => <String, dynamic>{
    'size': this.size,
  };

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('_data', () => new Uint8List.fromList(_data), (v) {
            _data = new Uint8List.fromList(v);
          }),
      new Ser.Field('_memOffset', () => _memOffset, (v) => _memOffset = v),
      new Ser.Field('fileName', () => fileName, (v) => _frd_init(v)),
    ];
  }

}
