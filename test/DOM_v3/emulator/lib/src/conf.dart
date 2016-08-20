// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   conf.dart                                          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/17 16:10:16 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/17 17:25:11 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
 * This file should be fully imported for convenience
 */

enum Register {
  PC, AF, BC, DE, HL, SP
}

enum DebStatus {
  ON, OFF
}

enum DebStatusRequest {
  TOGGLE, DISABLE, ENABLE
}
