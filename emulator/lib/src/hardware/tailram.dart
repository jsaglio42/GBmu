// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   tailram.dart                                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 11:42:23 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 11:45:47 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:ft/ft.dart" as Ft;

import 'package:emulator/src/enums.dart';

import "package:emulator/src/hardware/data.dart" as Data;

class TailRam extends Data.AData
  with Data.AReadOperation, Data.AWriteOperation {

  TailRam(int start, Uint8List d) : super(start, d);

  @override int pull8(int addr) => this.pull8_unsafe(addr);
  @override void push8(int addr, int v) => this.push8_unsafe(addr, v);

  /* DO SOME SPECIAL STUFFFFFF */

}
