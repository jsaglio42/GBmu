// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   public_classes.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 11:27:55 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/22 17:34:39 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

/*
 * This file should be fully imported for convenience
 */

export 'cpu_registers.dart';
export 'memory/mem_registers.dart';

enum DebStatus {
  ON, OFF
}

enum DebStatusRequest {
  TOGGLE, DISABLE, ENABLE
}
