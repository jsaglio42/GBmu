// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_component_storage_parts.dart          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 11:54:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 13:51:51 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of platform_dom_component_storage;

abstract class _TopLevelBankStorage implements _super {

  DomGameBoySocket _dgbs;

  void _tlbs_init() {
    _dgbs = new DomGameBoySocket(_pde, Html.querySelector('#gb-slot'));
  }

  DomGameBoySocket get dgbs => _dgbs;

}

abstract class _OpenedCartStorage implements _super {

  Ft.Option<DomCart> _openedCart;

  void openedCartDismissal() {
    final DomCart c = _openedCart.v;

    assert(_openedCart.isSome, "from: openedCartDismissal");
    _openedCart = new Ft.Option<DomCart>.none();
    _pde.openedCartChange(new SlotEvent<DomCart>.dismissal(c));
  }

  void openedCartArrival(DomCart c) {
    assert(_openedCart.isNone, "from: openedCartArrival");
    _openedCart = new Ft.Option<DomCart>.some(c);
    _pde.openedCartChange(new SlotEvent<DomCart>.arrival(c));

  }

  Ft.Option<DomCart> get openedCart => _openedCart;

}

abstract class _GbCartStorage implements _super {

  Ft.Option<DomCart> _gbCart;

  void gbCartDismissal() {
    final DomCart c = _gbCart.v;

    assert(_gbCart.isSome, "from: gbCartDismissal");
    _gbCart = new Ft.Option<DomCart>.none();
    _pde.gbCartChange(new SlotEvent<DomCart>.dismissal(c));
  }

  void gbCartArrival(DomCart c) {
    assert(_gbCart.isNone, "from: gbCartArrival");
    _gbCart = new Ft.Option<DomCart>.some(c);
    _pde.gbCartChange(new SlotEvent<DomCart>.arrival(c));

  }

  Ft.Option<DomCart> get gbCart => _gbCart;

}

abstract class _DraggedStorage implements _super {

  Ft.Option<DomComponent> _dragged;

  void draggedDismissal() {
    final DomComponent c = _dragged.v;

    assert(_dragged.isSome, "from: draggedDismissal");
    _dragged = new Ft.Option<DomComponent>.none();
    _pde.draggedChange(new SlotEvent<DomComponent>.dismissal(c));
  }

  void draggedArrival(DomComponent c) {
    assert(_dragged.isNone, "from: draggedArrival");
    _dragged = new Ft.Option<DomComponent>.some(c);
    _pde.draggedChange(new SlotEvent<DomComponent>.arrival(c));

  }

  Ft.Option<DomComponent> get dragged => _dragged;

}
