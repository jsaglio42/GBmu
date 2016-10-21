// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   sprite.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/21 14:57:44 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

import "package:emulator/src/video/tileinfo.dart";

/* Sprites ********************************************************************/
class Sprite {

  Sprite();

  int posY = 0;
  int posX = 0;
  int tileID = 0;
  TileInfo info = new TileInfo();

}
