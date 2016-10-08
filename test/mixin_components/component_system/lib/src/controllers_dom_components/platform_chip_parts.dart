// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_chip_parts.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/06 14:35:06 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/08 12:46:46 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of platform_chip;

abstract class _Super {
  PlatformComponentEvents get _pce;
  PlatformDomComponentStorage get _pdcs;
}

abstract class _Actions implements _Super {

  void _actionNewDetached(DomChip that) =>
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.NewDetached(that));

  void _actionNewAttached(DomChip that)  {
    final LsChip data = that.data as LsChip;
    final DomCart c = _pdcs.componentOfUid(data.romUid.v);

    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.NewAttached(that, c));
  }

  void _actionDeleteDetached(DomChip that) =>
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.DeleteDetached(that));

  void _actionDeleteAttached(DomChip that) {
    final LsChip data = that.data as LsChip;
    final DomCart c = _pdcs.componentOfUid(data.romUid.v);

    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.DeleteAttached(that, c));
  }

  void _actionMoveAttach(DomChip that, DomCart o, DomCart n) {
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.MoveAttach(
            that, oldCart:o, newCart:n));
  }

  void _actionDetach(DomChip that, DomCart c) {
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.Detach(that, c));
  }

  void _actionAttach(DomChip that, DomCart c) {
    _pce.chipEvent(new ChipEvent<DomChip, DomCart>.Attach(that, c));
  }


  // PUBLIC ***************************************************************** **

}