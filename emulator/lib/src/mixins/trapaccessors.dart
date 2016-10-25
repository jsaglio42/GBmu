// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   trapaccessors.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/25 15:00:12 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

abstract class TVideoRam {
  int vr_pull8(int memAddr);
  void vr_push8(int memAddr, int v);
}

abstract class TInternalRam {
  int ir_pull8(int memAddr);
  void ir_push8(int memAddr, int v);
}

abstract class TTailRam {
  int tr_pull8(int memAddr);
  void tr_push8(int memAddr, int v);
  void updateCoincidence(bool coincidence);
}
