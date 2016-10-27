// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   palettememory.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/26 18:34:11 by jsaglio           #+#    #+#             //
//   Updated: 2016/10/27 15:34:22 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";

import "package:ft/ft.dart" as Ft;

import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;

const int PALETTE_COUNT = 8;
const int COLOR_PER_PALETTE = 4;

class PaletteMemory extends Ser.RecursivelySerializable {

  List<int> _data = new List<int>(PALETTE_COUNT * COLOR_PER_PALETTE);

  /* API **********************************************************************/
  void reset() {
    /* Initialisation to white */
    for (int i = 0; i < _data.length; ++i) {
      _data[i] = 0x1F + (0x1F << 5) + (0x1F << 10);
    }
    /* Just for Debug */
    /* Palette 0 - Grey */
    _data[0x0] = 0x1F + (0x1F << 5) + (0x1F << 10);
    _data[0x1] = 0x14 + (0x14 << 5) + (0x14 << 10);
    _data[0x2] = 0x0A + (0x0A << 5) + (0x0A << 10);
    _data[0x3] = 0x00 + (0x00 << 5) + (0x00 << 10);
    /* Palette 1 - Red */
    _data[0x4] = 0x1F;
    _data[0x5] = 0x14;
    _data[0x6] = 0x0A;
    _data[0x7] = 0x00;
    /* Palette 2 - Green */
    _data[0x8] = (0x1F << 5);
    _data[0x9] = (0x14 << 5);
    _data[0xA] = (0x0A << 5);
    _data[0xB] = (0x00 << 5);
    /* Palette 3 - Blue */
    _data[0xC] = (0x1F << 10);
    _data[0xD] = (0x14 << 10);
    _data[0xE] = (0x0A << 10);
    _data[0xF] = (0x00 << 10);
    return ;
}

  int getColor(int paletteIndex, int colorID) {
    assert(paletteIndex & ~0x7 == 0, 'invalid paletteIndex');
    assert(colorID & ~0x3 == 0, 'invalid colorID');
    return (_data[paletteIndex * 4 + colorID]);
  }

  void setColor(int paletteIndex, int colorID, int v) {
    assert(paletteIndex & ~0x7 == 0, 'invalid paletteIndex');
    assert(colorID & ~0x3 == 0, 'invalid colorID');
    _data[paletteIndex * 4 + colorID] = v;
    return ;
  }

  int pull8(int offset) {
    assert(offset & ~0x3F == 0, 'invalid offset $offset');
    final int paletteIndex = offset ~/ 8;
    final int colorID = (offset % 8) ~/ 2;
    if (offset % 2 == 0)
      return this.getColor(paletteIndex, colorID) & 0xFF;
    else
      return (this.getColor(paletteIndex, colorID) >> 8) & 0x7F;
  }

  void push8(int offset, int v) {
    assert(v & ~0xFF == 0, 'invalid color $v');
    assert(offset & ~0x3F == 0, 'invalid offset $offset');
    final int paletteIndex = offset ~/ 8;
    final int colorID = (offset % 8) ~/ 2;
    final int currentColor = this.getColor(paletteIndex, colorID);
    final int newColor = (offset % 2 == 0)
      ? (currentColor & 0x1F00) | v
      : (currentColor & 0x00FF) | (v << 8);
    _data[paletteIndex * 4 + colorID] = newColor & 0x7FFF;
    return ;
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('_data', () => _data,
          (v) => this._data = new List<int>.from(_data)),
    ];
  }
}
