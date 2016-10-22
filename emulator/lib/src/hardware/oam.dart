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

import "package:emulator/src/video/sprite.dart";

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
      case (3) : return s.info.value;
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
      case (3) : s.info.value = v; break;
      default : assert(false, 'oam_pull8: switch failure');
    }
    return ;
  }

  Sprite operator[](int i) => _data[i];

}
