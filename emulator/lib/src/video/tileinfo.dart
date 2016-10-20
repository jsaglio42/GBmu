// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tileinfo.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/20 11:32:43 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

/* TileInfo ********************************************************************/
class TileInfo {

  TileInfo();

  int _value = 0;

  bool _priorityIsBG = false;
  bool _flipY = false;
  bool _flipX = false;
  int _OBP_DMG = 0;
  int _bankID = 0;
  int _OBP_CGB = 0;

  int get value => _value;
  void set value(int v) {
    _priorityIsBG = (v >> 7) & 0x1 == 1;
    _flipY = (v >> 6) & 0x1 == 1;
    _flipX = (v >> 5) & 0x1 == 1;
    _OBP_DMG = (v >> 4) & 0x1;
    _bankID = (v >> 3) & 0x1;
    _OBP_CGB = v & 0x7;
    _value = v;
    return ;
  }

  bool get priorityIsBG => _priorityIsBG;
  bool get flipY => _flipY;
  bool get flipX => _flipX;
  int get OBP_DMG => _OBP_DMG;
  int get bankID => _bankID;
  int get OBP_CGB => _OBP_CGB;

}
