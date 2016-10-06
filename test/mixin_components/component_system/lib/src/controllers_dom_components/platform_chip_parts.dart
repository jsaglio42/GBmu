// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_chip_parts.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/06 14:35:06 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/06 15:12:27 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of platform_chip;

abstract class _Super {
  PlatformComponentEvents get _pce;
}

abstract class _Actions implements _Super {
  void _actionNew(DomChip that);
  void _actionAttach(DomChip that);
  void _actionDetach(DomChip that);
  void _actionDeleteAttached(DomChip that);
  void _actionDeleteDetached(DomChip that);

}