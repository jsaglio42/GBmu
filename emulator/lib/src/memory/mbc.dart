// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mmu.dart                                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/23 14:53:50 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/23 14:53:50 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

abstract class Mbc
{
  
  Uint8List _rom;
  Uint8List _ram;

  int   readByte(int addr);
  int   writeByte(int addr, int value);

}
