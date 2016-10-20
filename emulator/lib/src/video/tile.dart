// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tile.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/20 11:53:13 by jsaglio          ###   ########.fr       //
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
    return _colorIDs[y * 8 + x];
  }

  int operator[](int i){
    return _values[i];
  }

  int operator[]=(int i, int v){
    _values[i] = v;
    // ADJUST COLORS HERE
  }

}
