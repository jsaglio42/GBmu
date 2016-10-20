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

  List<int> _data = new List.filled(8 * 8, 0);

  int getColorID(int x, int y, bool flipX, bool flipY) {
    if (flipX)
      x = 7 - x;
    if (flipY)
      y = 7 - y;
    return _data[y * 8 + x];
  }

  // push DATA

}
