// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tile.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/21 18:31:14 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

/* Tile ************************************************************************/
class Tile {

  Uint8List _colorIDs = new Uint8List(8 * 8);
  Uint8List _values = new Uint8List(8 * 2);

  /* API */
  int getColorID(int x, int y, bool flipX, bool flipY) {
    if (flipX)
      x = 7 - x;
    if (flipY)
      y = 7 - y;
    return _colorIDs[y * 8 + x];
  }

  int operator[](int i){
    return _values[i];
  }

  void operator[]=(int i, int v){
    _values[i] = v;
    _updateLine(i ~/ 2);
    return ;
  }

  /* Private */
  void _updateLine(int line) {
    int low = _values[2 * line];
    int high = _values[2 * line + 1];
    for (int x = 0; x < 8; ++x)
    {
      _colorIDs[8 * line + (7 - x)] = (low & 0x1) | ((high & 0x1) << 1);
      low >>= 1;
      high >>= 1;
    }
    return ;
  }

}
