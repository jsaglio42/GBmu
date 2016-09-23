// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   data.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 11:42:23 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/10 11:56:29 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:ft/ft.dart" as Ft;

import 'package:emulator/src/enums.dart';
import "package:emulator/src/memory/headerdecoder.dart" as Headerdecoder;

class TailRam extends AData
  with AReadOperation, AWriteOperation {

  TailRam(int start, Uint8List d) : super(start, d);

  int pull8(int addr) => this.pull8_unsafe(addr);
  void push8(int addr, int v) => this.push8_unsafe(addr, v);

}
