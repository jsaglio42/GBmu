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

class Ram {

  final		Uint8List _data;

  Ram(this._data);

  int	pull8(int ramAddr)
  { return 0x42;}

  void	push8(int ramAddr, int byte)
  {}

  int	pull16(int ramAddr)
  { return 0x42;}

  void	push16(int ramAddr, int word)
  {}

  int	get size => _data.length;

}