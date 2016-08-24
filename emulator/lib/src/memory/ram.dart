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

class Ram {

  final		Uint8List _data;
  
  Ram(this._data);

  int	pull(int ramAddr) => 0x42;
  void	push(int ramAddr, int v) {}
  int	get size => _data.length;

}