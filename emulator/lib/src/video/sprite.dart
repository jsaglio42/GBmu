// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   sprite.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/24 18:25:35 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;
import "package:emulator/src/video/tileinfo.dart";

/* Sprites ********************************************************************/
class Sprite extends Ser.RecursivelySerializable {

  Sprite();

  int posY = 0;
  int posX = 0;
  int tileID = 0;
  TileInfo info = new TileInfo();

  int adjustedTileID(int spriteSize, int row) {
    if (spriteSize == 16)
    {
      if(row < 8)
        return tileID & 0xFE;
      else
        return tileID | 0x01;
    }
    else
      return tileID;
  }

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return <Ser.RecursivelySerializable>[
      info
    ];
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[
      new Ser.Field('posY', () => posY, (v) => posY = v),
      new Ser.Field('posX', () => posX, (v) => posX = v),
      new Ser.Field('tileID', () => tileID, (v) => tileID = v),
    ];
  }

}
