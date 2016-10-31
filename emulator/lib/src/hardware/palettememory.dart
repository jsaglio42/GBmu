// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   palettememory.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jsaglio <jsaglio@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/26 18:34:11 by jsaglio           #+#    #+#             //
//   Updated: 2016/10/28 18:59:27 by jsaglio          ###   ########.fr       //
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
    _data.fillRange(0, _data.length, 0x1F + (0x1F << 5) + (0x1F << 10));
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
