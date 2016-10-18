// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   oam.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/17 22:14:53 by jsaglio          ###   ########.fr       //
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

/* OAM ************************************************************************/
class OAM {

  final List<Sprite> _data = new List.generate(40, (i) => new Sprite());

  /* ACCESSORS ****************************************************************/
  int pull8(int memAddr) {
    memAddr -= OAM_FIRST;
    Sprite s = _data[memAddr ~/ 4];
    switch (memAddr % 4) {
      case (0) : return s.posY;
      case (1) : return s.posX;
      case (2) : return s.tileID;
      case (3) : return s.attribute;
      default : assert(false, 'oam_pull8: switch failure');
    }
  }

  void push8(int memAddr, int v) {
    memAddr -= OAM_FIRST;
    Sprite s = _data[memAddr ~/ 4];
    switch (memAddr % 4) {
      case (0) : s.posY = v; break;
      case (1) : s.posX = v; break;
      case (2) : s.tileID = v; break;
      case (3) : s.attribute = v; break;
      default : assert(false, 'oam_pull8: switch failure');
    }
    return ;
  }

  Sprite operator[](int i) => _data[i];

}
