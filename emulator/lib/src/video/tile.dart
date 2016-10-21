// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tile.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/21 14:39:04 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

/* Tile ************************************************************************/
class Tile {

  List<int> _colorIDs = new List.filled(8 * 8, 0);
  List<int> _values = new List.filled(8 * 2, 0);

  int getColorID(int x, int y, bool flipX, bool flipY) {
    if (flipX)
      x = 7 - x;
    if (flipY)
      y = 7 - y;
    // final int low = (_values[2 * y] >> (7 - x)) & 0x1;
    // final int high = (_values[2 * y + 1] >> (7 - x)) & 0x1;
    // return (low | (high << 1));
    return _colorIDs[y * 8 + x];
  }

  int operator[](int i){
    return _values[i];
  }

  int operator[]=(int i, int v){
    _values[i] = v;
    final int row = i ~/ 2;
    int low = _values[2 * row];
    int high = _values[2 * row + 1];
    for (int x = 0; x < 8; ++x)
    {
      _colorIDs[8 * row + (7 - x)] = (low & 0x1) | ((high & 0x1) << 1);
      low >>= 1;
      high >>= 1;
    }
  }

}
