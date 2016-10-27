// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   oam.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 15:47:02 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";
import "package:emulator/src/hardware/recursively_serializable.dart" as Ser;
import "package:emulator/src/video/sprite.dart";

/* OAM ************************************************************************/
class OAM extends Ser.RecursivelySerializable {

  List<Sprite> _data = new List.generate(40, (i) => new Sprite());

  /* ACCESSORS ****************************************************************/
  int pull8(int addr) {
    assert(addr & ~0xFF == 0, 'pull8: invalid addr $addr');
    assert(addr < 0xA0, 'pull8: invalid addr $addr');
    Sprite s = _data[addr ~/ 4];
    switch (addr % 4) {
      case (0) : return s.posY;
      case (1) : return s.posX;
      case (2) : return s.tileID;
      case (3) : return s.info.value;
      default : assert(false, 'oam_pull8: switch failure');
    }
  }

  void push8(int addr, int v) {
    assert(addr & ~0xFF == 0, 'push8: invalid addr $addr');
    assert(addr < 0xA0, 'push8: invalid addr $addr');
    Sprite s = _data[addr ~/ 4];
    switch (addr % 4) {
      case (0) : s.posY = v; break;
      case (1) : s.posX = v; break;
      case (2) : s.tileID = v; break;
      case (3) : s.info.value = v; break;
      default : assert(false, 'oam_pull8: switch failure');
    }
    return ;
  }

  Sprite operator[](int i) => _data[i];

  // FROM RecursivelySerializable ******************************************* **
  Iterable<Ser.RecursivelySerializable> get serSubdivisions {
    return _data;
  }

  Iterable<Ser.Field> get serFields {
    return <Ser.Field>[];
  }

}
