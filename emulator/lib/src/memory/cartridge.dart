// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 15:32:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 17:00:09 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "ram.dart";
import "rom.dart";
import "cartridge.dart";
import "imbc.dart";

abstract class Cartridge implements IMbc {

  final Rom rom;
  final Ram ram;

  Cartridge(this.rom, this.ram);

}