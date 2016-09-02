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

import 'dart:convert' as Convert;
import 'dart:typed_data';
import "package:emulator/src/memory/rom_new.dart" as Rom;

/*
 * Page3 : https://docs.google.com/spreadsheets/d/1ffcl5dd_Q12Eqf9Zlrho_ghUZO5lT-gIpRi392XHU10
 */

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

// Maps ********************************************************************* **

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

// To value functions ******************************************************* **

typedef dynamic _toValueFunc(Rom.IRom rom);

bool _fieldOutOfBound(Rom.IRom rom, RomHeaderFieldInfo dat)
{
  if (dat.address + dat.size > rom.size)
    return true;
  else
    return false;
}

// CartridgeType _cartridgeTypeOfRom(Rom.IRom rom)
// {
//   final dat = headerFieldInfos[RomHeaderField.Cartridge_Type];
//   int v;

//   if (_fieldOutOfBound(rom, dat))
//     throw new Exception('Rom Header: Out of bound');
//   else {
//     v = rom.pull8(dat.address);
//     if (cartridgeTypeCodes.containsKey(v) == false)
//       throw new Exception('Rom Header: unknown id');
//     return cartridgeTypeCodes[v];
//   }
// }

// int _romSizeOfRom(Rom.IRom rom)
// {
//   final dat = headerFieldInfos[RomHeaderField.ROM_Size];
//   int v;

//   if (_fieldOutOfBound(rom, dat))
//     throw new Exception('Rom Header: Out of bound');
//   else {
//     v = rom.pull8(dat.address);
//     if (romSizeCodes.containsKey(v) == false)
//       throw new Exception('Rom Header: unknown id');
//     return romSizeCodes[v];
//   }
// }

// int _ramSizeOfRom(Rom.IRom rom)
// {
//   final dat = headerFieldInfos[RomHeaderField.RAM_Size];
//   int v;

//   if (_fieldOutOfBound(rom, dat))
//     throw new Exception('Rom Header: Out of bound');
//   else {
//     v = rom.pull8(dat.address);
//     if (ramSizeCodes.containsKey(v) == false)
//       throw new Exception('Ram Header: unknown id');
//     return ramSizeCodes[v];
//   }
// }

_toValueFunc _makeMapGetterFunction(RomHeaderField f, Map<int, dynamic> map)
{
  return (Rom.IRom rom) {
    final dat = headerFieldInfos[f];
    int v;

    if (_fieldOutOfBound(rom, dat))
      throw new Exception('Rom Header: Out of bound');
    else {
      v = rom.pull8(dat.address);
      if (map.containsKey(v) == false)
        throw new Exception('Ron Header: Unknown id');
      return map[v];
    }
  };
}

_toValueFunc _makeByteGetterFunction(RomHeaderField f)
{
  return (Rom.IRom rom) {
    final dat = headerFieldInfos[f];
    if (_fieldOutOfBound(rom, dat))
      throw new Exception('Rom Header: Out of bound');
    else
      return rom.pull8(dat.address);
  };
}

_toValueFunc _makeWordGetterFunction(RomHeaderField f)
{
  return (Rom.IRom rom) {
    final dat = headerFieldInfos[f];
    if (_fieldOutOfBound(rom, dat))
      throw new Exception('Rom Header: Out of bound');
    else
      return rom.pull16(dat.address);
  };
}
_toValueFunc _makeDWordGetterFunction(RomHeaderField f)
{
  return (Rom.IRom rom) {
    final dat = headerFieldInfos[f];
    if (_fieldOutOfBound(rom, dat))
      throw new Exception('Rom Header: Out of bound');
    else
      return
        rom.pull8(dat.address + 0) << 8 * 3 |
        rom.pull8(dat.address + 1) << 8 * 2 |
        rom.pull8(dat.address + 2) << 8 * 1 |
        rom.pull8(dat.address + 3) << 8 * 0;
  };
}
_toValueFunc _makeByteListGetterFunction(RomHeaderField f)
{
  return (Rom.IRom rom) {
    final dat = headerFieldInfos[f];
    if (_fieldOutOfBound(rom, dat))
      throw new Exception('Rom Header: Out of bound');
    else
      return new Uint8List.fromList(
          rom.data.skip(dat.address).take(dat.size).toList());
  };
}

// To string functions ****************************************************** **

// String _destinationCodeToString(Uint8List l)
// {
//   switch (l[0]) {
//     case 0:
//       return 'Japanese';
//     case 1:
//       return 'Non-Japanese';
//     default:
//       throw new FormatException('Destination Code: unknown id');
//   }
// }

// bool _nintendoLogoValid(Uint8List l)
// {
//   const ref = const <int>[
//     0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83,
//     0x00, 0x0C, 0x00, 0x0D, 0x00, 0x08, 0x11, 0x1F, 0x88, 0x89, 0x00, 0x0E,
//     0xDC, 0xCC, 0x6E, 0xE6, 0xDD, 0xDD, 0xD9, 0x99, 0xBB, 0xBB, 0x67, 0x63,
//     0x6E, 0x0E, 0xEC, 0xCC, 0xDD, 0xDC, 0x99, 0x9F, 0xBB, 0xB9, 0x33, 0x3E];

//   if (l.length != ref.length)
//     throw new FormatException('Nintendo Logo: not valid');
//   for (int i = 0; i < ref.length; i++)
//     {
//       if (ref[i] != l[i])
//         throw new FormatException('Nintendo Logo: not valid');
//     }
//   return true;
// }

// Rom Header Info ********************************************************** **

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

final headerFieldInfos = <RomHeaderField, RomHeaderFieldInfo>{

  RomHeaderField.Entry_Point: new RomHeaderFieldInfo(
      0x0100, 0x4, 'Entry Point', '', true,
      _makeByteListGetterFunction(RomHeaderField.Entry_Point)),


  //   new RomHeaderFieldInfo(0x0100, 0x4, 'Entry Point', '', false, (_)=>42); //(l) => l),
  //   new RomHeaderFieldInfo(0x0104, 0x30, 'Nintendo Logo', '', false, (_)=>42); //(l) => _nintendoLogoValid(l)),
  //   new RomHeaderFieldInfo(0x0134, 0x10, 'Title', '', true, (_)=>42); //(l) => Convert.ASCII.decode(l)),

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

};

// Rom Header *************************************************************** **

class RomHeader implements Rom.IRom {

  dynamic pullHeaderValue(RomHeaderField f)
  {
    final info = headerFieldInfos[f];

    return info.toValue(this);
  }

  String pullHeaderString(RomHeaderField f)
  {
    try {
      return this.pullHeaderValue(f).toString();
    } catch (e) {
      return e.toString();
    }
  }
}

/* Debug Rom Header ***********************************************************/

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

  final rom = new Rom.Rom(tetrisHead);
  var v;
  var str;

  headerFieldInfos.toString();

  print(rom);

  for (RomHeaderField f in RomHeaderField.values) {
    str = f.toString();
    try {
      v = rom.pullHeaderValue(f);
      str += ' val:[<' + v.runtimeType.toString() + '> ' + v.toString() + ']';
    } catch (e, st) {
      str += ' exn:[' + e.toString() + st.toString() + ']';
    }
    str += '\n\n';
    print(str);
  }

}
