// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mem_registers.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/08/22 15:32:25 by ngoguey           #+#    #+#             //
//   Updated: 2016/08/25 20:31:14 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

abstract class IMbc {

  int	pullMem8(int memAddr);
  void	pushMem8(int memAddr, int byte);
  int	pullMem16(int memAddr);
  void	pushMem16(int memAddr, int word);

}