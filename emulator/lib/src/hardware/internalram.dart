// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   internalram.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/14 17:13:21 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 20:36:02 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/constants.dart";
import "package:emulator/src/globals.dart";
import "package:emulator/src/enums.dart";

class InternalRam {

  final Uint8List _data = new Uint8List(INTERNAL_RAM_SIZE);

  /* API *********************************************************************/
  void push8(int memAddr, int v) {
    memAddr -= INTERNAL_RAM_FIRST;
  	_data[memAddr] = v;
  }

  int pull8(int memAddr) {
    memAddr -= INTERNAL_RAM_FIRST;
  	return _data[memAddr];
  }

}
