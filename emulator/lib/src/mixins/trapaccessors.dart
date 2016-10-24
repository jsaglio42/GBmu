// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   trapaccessors.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/25 11:10:38 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/24 21:24:39 by jsaglio          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

abstract class VideoTrap {
  int vr_pull8(int memAddr);
  void vr_push8(int memAddr, int v);
}

abstract class TailTrap {
  int tr_pull8(int memAddr);
  void tr_push8(int memAddr, int v);
  void updateCoincidence(bool coincidence);
}
