// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   videoram.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 20:35:56 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

class VideoRam {

  final Uint8List _data = new Uint8List(VIDEO_RAM_SIZE);

  /* API *********************************************************************/
  void push8(int memAddr, int v) {
    memAddr -= VIDEO_RAM_FIRST;
  	_data[memAddr] = v;
  }

  int pull8(int memAddr) {
    memAddr -= VIDEO_RAM_FIRST;
  	return _data[memAddr];
  }

}
