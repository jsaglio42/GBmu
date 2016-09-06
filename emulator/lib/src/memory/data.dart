// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   rom.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:56:08 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/02 15:33:48 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import 'dart:convert' as Convert;

/* Rom Implementation *********************************************************/

abstract class Data  {

  final Uint8List _data;
  final Uint16List _view16;

  Data(Uint8List d) : _data = d, _view16 = d.buffer.asUint16List();

  int get size => _data.length;

}

/* ReadOperation **************************************************************/

abstract class ReadOperation extends Data {

  int pull8(int addr)
  {
    assert(addr >= 0 && addr < _data.length);
    return this._data[addr];
  }

  int pull16(int addr)
  {
    assert(addr % 2 == 0);
    assert(addr >= 0 && addr < _data.length);
    final int addr_View16 = addr ~/ 2;
    return _view16[addr_View16];
  }

  Uint8List pull8List(int addr, int len)
  {
    assert(addr >= 0 && addr + len < _data.length);
    return new Uint8List.view(_data.buffer, addr, len);
  }

}

/* WriteOperation *************************************************************/

abstract class WriteOperation extends Data  {

  void  push8(int addr, int byte)
  {
    assert(addr >= 0 && addr < _data.length);
    assert(byte & ~0xFF == 0);
    this._data[addr] = byte;
    return ;
  }

  void  push16(int addr, int word)
  {
    assert(addr % 2 == 0);
    assert(addr >= 0 && addr < _data.length);
    assert(word & ~0xFFFF == 0);
    final int addr_View16 = addr ~/ 2;
    _view16[addr_View16] = word;
    return ;
  }

}

/* Rom ************************************************************************/

class Rom extends Data
	with ReadOperation, HeaderDecoder {

  Rom(Uint8List d) : super(d);

}

class Ram extends Data
	with ReadOperation, WriteOperation {

  Ram(Uint8List d) : super(d);

}

class VideoRam extends Data
  with ReadOperation, WriteOperation {

  Ram(Uint8List d) : super(d);

}

class WorkingRam extends Data
  with ReadOperation, WriteOperation {

  Ram(Uint8List d) : super(d);

}

class TailRam extends Data
  with ReadOperation, WriteOperation {

  Ram(Uint8List d) : super(d);

}

/* Rom Header *****************************************************************/

// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   rom_header.dart                                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 17:06:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/02 15:33:36 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/* Enums **********************************************************************/

enum RomHeaderField {
  Entry_Point,
  Nintendo_Logo,
  Title,
  Manufacturer_Code,
  CGB_Flag,
  New_Licensee_Code,
  SGB_Flag,
  Cartridge_Type,
  ROM_Size,
  RAM_Size,
  Destination_Code,
  Old_Licensee_Code,
  Mask_ROM_Version_number,
  Header_Checksum,
  Global_Checksum,
}

enum CartridgeType {
  ROM_ONLY,
  MBC1,
  MBC1_RAM,
  MBC1_RAM_BATTERY,
  MBC2,
  MBC2_BATTERY,
  ROM_RAM,
  ROM_RAM_BATTERY,
  MMM01,
  MMM01_RAM,
  MMM01_RAM_BATTERY,
  MBC3_TIMER_BATTERY,
  MBC3_TIMER_RAM_BATTERY,
  MBC3,
  MBC3_RAM,
  MBC3_RAM_BATTERY,
  MBC4,
  MBC4_RAM,
  MBC4_RAM_BATTERY,
  MBC5,
  MBC5_RAM,
  MBC5_RAM_BATTERY,
  MBC5_RUMBLE,
  MBC5_RUMBLE_RAM,
  MBC5_RUMBLE_RAM_BATTERY,
  MBC6,
  MBC7_SENSOR_RUMBLE_RAM_BATTERY,
  POCKET_CAMERA,
  BANDAI_TAMA5,
  HuC3,
  HuC1_RAM_BATTERY,
}

/* Rom Header Info ************************************************************/

class RomHeaderFieldInfo {
  final int address;
  final int size;
  final String name;
  final String description; // <- not used
  final bool displayed; // <- not used
  final _toValueFunc toValue;

  RomHeaderFieldInfo(this.address, this.size, this.name,
      this.description, this.displayed, this.toValue);
}

/* Rom Header Decoder *********************************************************/

abstract class HeaderDecoder extends Data 
  with ReadOperation {

  dynamic pullHeaderValue(RomHeaderField f)
  {
    final info = headerFieldInfos[f];
    if (info == null) {
      throw new Exception('Rom Header: ' + f.toString() + ': getter not implemented');
    }
    return info.toValue(this);
  }

  String pullHeaderString(RomHeaderField f)
  {
    try {
      return this.pullHeaderValue(f).toString();
    } catch (e) {
      return 'unknown';
    }
  }
}

/* Global *********************************************************************/

final cartridgeTypeCodes = <int, CartridgeType>{
  0x00: CartridgeType.ROM_ONLY,
  0x01: CartridgeType.MBC1,
  0x02: CartridgeType.MBC1_RAM,
  0x03: CartridgeType.MBC1_RAM_BATTERY,
  0x05: CartridgeType.MBC2,
  0x06: CartridgeType.MBC2_BATTERY,
  0x08: CartridgeType.ROM_RAM,
  0x09: CartridgeType.ROM_RAM_BATTERY,
  0x0B: CartridgeType.MMM01,
  0x0C: CartridgeType.MMM01_RAM,
  0x0D: CartridgeType.MMM01_RAM_BATTERY,
  0x0F: CartridgeType.MBC3_TIMER_BATTERY,
  0x10: CartridgeType.MBC3_TIMER_RAM_BATTERY,
  0x11: CartridgeType.MBC3,
  0x12: CartridgeType.MBC3_RAM,
  0x13: CartridgeType.MBC3_RAM_BATTERY,
  0x15: CartridgeType.MBC4,
  0x16: CartridgeType.MBC4_RAM,
  0x17: CartridgeType.MBC4_RAM_BATTERY,
  0x19: CartridgeType.MBC5,
  0x1A: CartridgeType.MBC5_RAM,
  0x1B: CartridgeType.MBC5_RAM_BATTERY,
  0x1C: CartridgeType.MBC5_RUMBLE,
  0x1D: CartridgeType.MBC5_RUMBLE_RAM,
  0x1E: CartridgeType.MBC5_RUMBLE_RAM_BATTERY,
  0x20: CartridgeType.MBC6,
  0x22: CartridgeType.MBC7_SENSOR_RUMBLE_RAM_BATTERY,
  0xFC: CartridgeType.POCKET_CAMERA,
  0xFD: CartridgeType.BANDAI_TAMA5,
  0xFE: CartridgeType.HuC3,
  0xFF: CartridgeType.HuC1_RAM_BATTERY,
};

final romSizeCodes = <int, int>{
  0x00: 16384 * 2, // (no ROM banking)
  0x01: 16384 * 4,
  0x02: 16384 * 8,
  0x03: 16384 * 16,
  0x04: 16384 * 32,
  0x05: 16384 * 64,
  0x06: 16384 * 128, // only 125 banks used by MBC1',
  0x07: 16384 * 256, // only 125 banks used by MBC1
  0x52: 16384 * 72,
  0x53: 16384 * 80,
  0x54: 16384 * 96,
};

final ramSizeCodes = <int, int>{
  0x00: 0,
  0x01: 1024 * 2,
  0x02: 1024 * 8,
  0x03: 4 * 8192, // (4 banks of 8KBytes each)
  0x04: 16 * 8192, // (16 banks of 8KBytes each)
  0x05: 8 * 8192, // (8 banks of 8KBytes each)
};

final headerFieldInfos = <RomHeaderField, RomHeaderFieldInfo>{

  RomHeaderField.Entry_Point: new RomHeaderFieldInfo(
      0x0100, 0x4, 'Entry Point', '', true,
      _makeByteListGetterFunction(RomHeaderField.Entry_Point)),

  RomHeaderField.Manufacturer_Code: new RomHeaderFieldInfo(
      0x013F, 0x4, 'Manufacturer Code', '', true,
      _makeDWordGetterFunction(RomHeaderField.Manufacturer_Code)),

  RomHeaderField.CGB_Flag: new RomHeaderFieldInfo(
      0x0143, 0x1, 'CGB Flag', '', true,
      _makeByteGetterFunction(RomHeaderField.CGB_Flag)),

  RomHeaderField.New_Licensee_Code: new RomHeaderFieldInfo(
      0x0144, 0x2, 'New Licensee Code', '', true,
      _makeWordGetterFunction(RomHeaderField.New_Licensee_Code)),

  RomHeaderField.SGB_Flag: new RomHeaderFieldInfo(
      0x0146, 0x1, 'SGB Flag', '', true,
      _makeByteGetterFunction(RomHeaderField.SGB_Flag)),

  RomHeaderField.Cartridge_Type: new RomHeaderFieldInfo(
      0x0147, 0x1, 'Cartridge Type', '', true,
      _makeMapGetterFunction(RomHeaderField.Cartridge_Type, cartridgeTypeCodes)),

  RomHeaderField.ROM_Size: new RomHeaderFieldInfo(
      0x0148, 0x1, 'ROM Size', '', true,
      _makeMapGetterFunction(RomHeaderField.ROM_Size, romSizeCodes)),

  RomHeaderField.RAM_Size: new RomHeaderFieldInfo(
      0x0149, 0x1, 'RAM Size', '', true,
      _makeMapGetterFunction(RomHeaderField.RAM_Size, ramSizeCodes)),

  RomHeaderField.Destination_Code: new RomHeaderFieldInfo(
      0x014A, 0x1, 'Destination Code', '', true,
      _makeByteGetterFunction(RomHeaderField.Destination_Code)),

  RomHeaderField.Old_Licensee_Code: new RomHeaderFieldInfo(
      0x014B, 0x1, 'Old Licensee Code', '', true,
      _makeByteGetterFunction(RomHeaderField.Old_Licensee_Code)),

  RomHeaderField.Mask_ROM_Version_number: new RomHeaderFieldInfo(
      0x014C, 0x1, 'Mask ROM Version number', '', true,
      _makeByteGetterFunction(RomHeaderField.Mask_ROM_Version_number)),

  RomHeaderField.Header_Checksum: new RomHeaderFieldInfo(
      0x014D, 0x1, 'Header Checksum', '', false,
      _makeByteGetterFunction(RomHeaderField.Header_Checksum)),

  RomHeaderField.Global_Checksum: new RomHeaderFieldInfo(
      0x014E, 0x2, 'Global Checksum', '', true,
      _makeWordGetterFunction(RomHeaderField.Global_Checksum)),

  RomHeaderField.Title: new RomHeaderFieldInfo(
    0x0134, 0x10, 'Title', '', true,
    _makeStringGetterFunction(RomHeaderField.Title)),

  RomHeaderField.Nintendo_Logo: new RomHeaderFieldInfo(
    0x0104, 0x30, 'Nintendo Logo', '', false, _isNintendoLogoValid)

};

/* To value functions *********************************************************/

typedef dynamic _toValueFunc(HeaderDecoder rom);

bool _fieldOutOfBound(HeaderDecoder rom, RomHeaderFieldInfo info)
{
  if (info.address + info.size > rom.size)
    return true;
  else
    return false;
}

_toValueFunc _makeMapGetterFunction(RomHeaderField f, Map<int, dynamic> map)
{
  return (HeaderDecoder rom) {
    final info = headerFieldInfos[f];
    if (_fieldOutOfBound(rom, info))
      throw new Exception('Rom Header: Out of bound');
    else {
      final v = rom.pull8(info.address);
      if (map.containsKey(v) == false)
        throw new Exception('Rom Header: ' + info.name + ': Unknown id');
      return map[v];
    }
  };
}

_toValueFunc _makeByteGetterFunction(RomHeaderField f)
{
  return (HeaderDecoder rom) {
    final info = headerFieldInfos[f];
    if (_fieldOutOfBound(rom, info))
      throw new Exception('Rom Header: ' + info.name + ': Out of bound');
    else
      return rom.pull8(info.address);
  };
}

_toValueFunc _makeWordGetterFunction(RomHeaderField f)
{
  return (HeaderDecoder rom) {
    final info = headerFieldInfos[f];
    if (_fieldOutOfBound(rom, info))
      throw new Exception('Rom Header: ' + info.name + ': Out of bound');
    else
      return rom.pull16(info.address);
  };
}
_toValueFunc _makeDWordGetterFunction(RomHeaderField f)
{
  return (HeaderDecoder rom) {
    final info = headerFieldInfos[f];
    if (_fieldOutOfBound(rom, info))
      throw new Exception('Rom Header: ' + info.name + ': Out of bound');
    else
      return
        (rom.pull8(info.address + 0) << 0) |
        (rom.pull8(info.address + 1) << 8) |
        (rom.pull8(info.address + 2) << 16) |
        (rom.pull8(info.address + 3) << 24);
  };
}
_toValueFunc _makeByteListGetterFunction(RomHeaderField f)
{
  return (HeaderDecoder rom) {
    final info = headerFieldInfos[f];
    if (_fieldOutOfBound(rom, info))
      throw new Exception('Rom Header: Out of bound');
    else
      return rom.pull8List(info.address, info.size);
  };
}

_toValueFunc _makeStringGetterFunction(RomHeaderField f)
{
  return (HeaderDecoder rom) {
    final info = headerFieldInfos[f];
    if (_fieldOutOfBound(rom, info))
      throw new Exception('Rom Header: Out of bound');
    final l = rom.pull8List(info.address, info.size);
    return Convert.ASCII.decode(l);
  };
}

/* Custom functions */

bool _isNintendoLogoValid(HeaderDecoder rom)
{
  const ref = const <int>[
    0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83,
    0x00, 0x0C, 0x00, 0x0D, 0x00, 0x08, 0x11, 0x1F, 0x88, 0x89, 0x00, 0x0E,
    0xDC, 0xCC, 0x6E, 0xE6, 0xDD, 0xDD, 0xD9, 0x99, 0xBB, 0xBB, 0x67, 0x63,
    0x6E, 0x0E, 0xEC, 0xCC, 0xDD, 0xDC, 0x99, 0x9F, 0xBB, 0xB9, 0x33, 0x3E];
  final info = headerFieldInfos[RomHeaderField.Nintendo_Logo];
  if (_fieldOutOfBound(rom, info))
      throw new Exception('Rom Header: Out of bound');
  final logo = rom.pull8List(info.address, info.size);
  if (logo.length != ref.length)
    return false;
  for (int i = 0; i < ref.length; i++)
  {
    if (ref[i] != logo[i])
      return false;
  }
  return true;
}

/* Debug **********************************************************************/

void debugRomHeader()
{
  final tetrisHead = new Uint8List.fromList(<int>[
    0xc3, 0x8b, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc3, 0x8b, 0x02, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x87, 0xe1, 0x5f, 0x16, 0x00, 0x19, 0x5e, 0x23,
    0x56, 0xd5, 0xe1, 0xe9, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0xfd, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,

    //Entry point:
    0x00, 0xc3, 0x50, 0x01, 0xce, 0xed, 0x66, 0x66, 0xcc, 0x0d, 0x00, 0x0b, 0x03, 0x73, 0x00, 0x83,
    0x00, 0x0c, 0x00, 0x0d, 0x00, 0x08, 0x11, 0x1f, 0x88, 0x89, 0x00, 0x0e, 0xdc, 0xcc, 0x6e, 0xe6,
    0xdd, 0xdd, 0xd9, 0x99, 0xbb, 0xbb, 0x67, 0x63, 0x6e, 0x0e, 0xec, 0xcc, 0xdd, 0xdc, 0x99, 0x9f,
    0xbb, 0xb9, 0x33, 0x3e, 0x54, 0x45, 0x54, 0x52, 0x49, 0x53, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x0b, 0x89, 0xb5,
    0xc3, 0x8b, 0x02, 0xcd, 0x2b, 0x2a, 0xf0, 0x41, 0xe6, 0x03, 0x20, 0xfa, 0x46, 0xf0, 0x41, 0xe6
  ]);
  final notValid = new Uint8List.fromList(<int>[
    0xc3, 0x8b, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc3, 0x8b, 0x02, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x87, 0xe1, 0x5f, 0x16, 0x00, 0x19, 0x5e, 0x23,
    0x56, 0xd5, 0xe1, 0xe9, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0xfd, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x12, 0x27, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc3, 0x7e, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xc3, 0x8b, 0x02, 0xcd, 0x2b, 0x2a, 0xf0, 0x41, 0xe6, 0x03, 0x20, 0xfa, 0x46, 0xf0, 0x41, 0xe6
  ]);

  final rom = new Rom(tetrisHead);
  for (RomHeaderField f in RomHeaderField.values) {
    print(f.toString());
    try {
      var v = rom.pullHeaderValue(f);
      print('-> <' + v.runtimeType.toString() + '> ' + v.toString());
    } catch (e, st) {
      print(st.toString());
    }
  }

}

main(){
	Rom rom = new Rom(new Uint8List(10));
	Ram ram = new Ram(new Uint8List(10));
	print(rom.pull8(2));
	ram.push8(2,2);
  debugRomHeader();
	return ;
}


