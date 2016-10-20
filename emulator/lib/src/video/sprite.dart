// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   sprite.dart                                        :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/20 11:29:50 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

/* Sprites ********************************************************************/
class Sprite {

  Sprite();

  int posY = 0;
  int posX = 0;
  int tileID = 0;
  
  int _attribute = 0;
  bool _priorityIsBG = false;
  bool _flipY = false;
  bool _flipX = false;
  int _OBP_DMG = 0;
  int _tileBank_CGB = 0;
  int _OBP_CGB = 0;

  int get attribute => _attribute;
  void set attribute(int v) {
    _priorityIsBG = (v >> 7) & 0x1 == 1;
    _flipY = (v >> 6) & 0x1 == 1;
    _flipX = (v >> 5) & 0x1 == 1;
    _OBP_DMG = (v >> 4) & 0x1;
    _tileBank_CGB = (v >> 3) & 0x1;
    _OBP_CGB = v & 0x7;
    _attribute = v;
    return ;
  }

  bool get priorityIsBG => _priorityIsBG;
  bool get flipY => _flipY;
  bool get flipX => _flipX;
  int get OBP_DMG => _OBP_DMG;
  int get tileBank_CGB => _tileBank_CGB;
  int get OBP_CGB => _OBP_CGB;

}
