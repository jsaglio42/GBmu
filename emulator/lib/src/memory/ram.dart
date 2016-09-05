// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   ram.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 16:24:33 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 16:25:03 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "package:emulator/src/memory/rom.dart" as Rom;

/* Ram Implementation *********************************************************/

class Ram extends Rom.Rom {

  Ram(Uint8List d) : super(d);

  void	push8(int ramAddr, int byte)
  {
    assert(ramAddr >= 0 && ramAddr < data.length);
    assert(word | ~0xFF == 0);
    this.data[ramAddr] = byte;
    return ;
  }

  void	push16(int ramAddr, int word)
  {
    assert(ramAddr % 2 == 0);
    assert(ramAddr >= 0 && ramAddr < data.length);
    assert(word | ~0xFFFF == 0);
    final int addrView16 = ramAddr ~/ 2;
    view16[addrView16] = word;
    return ;
  }

}