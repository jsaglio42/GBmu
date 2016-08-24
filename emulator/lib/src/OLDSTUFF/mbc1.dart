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

import './mbc.dart' as MBC;

class Mbc1 extends MBC.Mbc
{

  int readByte(int addr) {
    return 0x42;
  }

  void writeByte(int addr, int value) {
    return ;
  }

}