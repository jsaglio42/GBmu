// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   public_classes.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 11:27:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 11:27:56 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
 * This file should be fully imported for convenience
 */

export 'registers.dart';

enum VRegister {
  LCDC, STAT, SCY, SCX, LY, LYC, DMA, BGP,
  OBP0, OBP1, WY, WX, BCPS, BCPD, OCPS, OCPD,
}

enum ORegister {
  P1, SB, SC, DIV, TIMA, TMA, TAC, KEY1, VBK,
  HDMA1, HDMA2, HDMA3, HDMA4, HDMA5, SVBK, IF, IE,
}

enum DebStatus {
  ON, OFF
}

enum DebStatusRequest {
  TOGGLE, DISABLE, ENABLE
}
