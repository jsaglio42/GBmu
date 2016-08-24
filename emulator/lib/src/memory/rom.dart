// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   rom.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:56:08 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/23 14:59:52 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import "dart:typed_data";
import "rom_header.dart";



class Rom {

  final Uint8List _data;

  Rom(this._data);

  int		pull(int romAddr) => 0x42;
  dynamic	pullHeader(RomHeaderField f) {} //sucr
  int		get size => _data.length;

}

