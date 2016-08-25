// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   cartridge.dart                                     :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:30:40 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 11:44:37 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "package:emulator/src/memory/ram.dart" as Ram;
import "package:emulator/src/memory/rom.dart" as Rom;
import "package:emulator/src/memory/imbc.dart" as Imbc;

abstract class Cartridge implements Imbc.IMbc {

  final Rom.Rom rom;
  final Ram.Ram ram;

  Cartridge(this.rom, this.ram);

}