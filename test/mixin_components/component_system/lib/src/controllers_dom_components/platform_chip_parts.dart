// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_chip_parts.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/06 14:35:06 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/06 16:24:37 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of platform_chip;

abstract class _Super {
  PlatformComponentEvents get _pce;
}

abstract class _Actions implements _Super {
  void _actionNew(DomChip that) =>
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.New(that));
  void _actionDeleteDetached(DomChip that) =>
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.DeleteDetached(that));

  void _actionDeleteAttached(DomChip that, DomCart c) =>
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.DeleteAttached(that, c));
  void _actionAttach(DomChip that, DomCart c) =>
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.Attach(that, c));
  void _actionDetach(DomChip that, DomCart c) =>
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.Detach(that, c));

  void _actionMoveAttach(DomChip that, {DomCart oldCart, DomCart newCart}) =>
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.MoveAttach(
            that, oldCart: oldCart, newCart: newCart));

}