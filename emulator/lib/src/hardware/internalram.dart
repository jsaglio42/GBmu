// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   internalram.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/07 11:42:23 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/24 10:27:25 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:ft/ft.dart" as Ft;

import 'package:emulator/src/enums.dart';

class InternalRam extends AData
  with AReadOperation, AWriteOperation {

  InternalRam(int start, Uint8List d) : super(start, d);

  @override int pull8(int addr) => this.pull8_unsafe(addr);
  @override void push8(int addr, int v) => this.push8_unsafe(addr, v);

}
