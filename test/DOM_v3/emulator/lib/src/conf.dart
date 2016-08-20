// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   conf.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/17 16:10:16 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/20 13:12:02 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
 * This file should be fully imported for convenience
 */

enum Register {
  PC, AF, BC, DE, HL, SP
}

enum VRegister {
  LCDC, STAT, SCY, SCX, LY, LYC, DMA, BGP,
  OBP0, OBP1, WY, WX, BCPS, BCPD, OCPS, OCPD,
}

enum DebStatus {
  ON, OFF
}

enum DebStatusRequest {
  TOGGLE, DISABLE, ENABLE
}
