// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_component_storage_parts.dart          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 11:54:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 17:12:51 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of platform_dom_component_storage;

abstract class _OpenedCartStorage implements _Super {

  Ft.Option<DomCart> _openedCart = new Ft.Option<DomCart>.none();

  void openedCartDismissal() {
    final DomCart c = _openedCart.v;

    assert(_openedCart.isSome, "from: openedCartDismissal");
    _openedCart = new Ft.Option<DomCart>.none();
    _pce.openedCartChange(new SlotEvent<DomCart>.dismissal(c));
  }

  void openedCartArrival(DomCart c) {
    assert(_openedCart.isNone, "from: openedCartArrival");
    _openedCart = new Ft.Option<DomCart>.some(c);
    _pce.openedCartChange(new SlotEvent<DomCart>.arrival(c));

  }

  Ft.Option<DomCart> get openedCart => _openedCart;

}

abstract class _GbCartStorage implements _Super {

  Ft.Option<DomCart> _gbCart = new Ft.Option<DomCart>.none();

  void gbCartDismissal() {
    final DomCart c = _gbCart.v;

    assert(_gbCart.isSome, "from: gbCartDismissal");
    _gbCart = new Ft.Option<DomCart>.none();
    _pce.gbCartChange(new SlotEvent<DomCart>.dismissal(c));
  }

  void gbCartArrival(DomCart c) {
    assert(_gbCart.isNone, "from: gbCartArrival");
    _gbCart = new Ft.Option<DomCart>.some(c);
    _pce.gbCartChange(new SlotEvent<DomCart>.arrival(c));

  }

  Ft.Option<DomCart> get gbCart => _gbCart;

}

abstract class _DraggedStorage implements _Super {

  Ft.Option<DomComponent> _dragged = new Ft.Option<DomComponent>.none();

  void draggedDismissal() {
    final DomComponent c = _dragged.v;

    assert(_dragged.isSome, "from: draggedDismissal");
    _dragged = new Ft.Option<DomComponent>.none();
    _pce.draggedChange(new SlotEvent<DomComponent>.dismissal(c));
  }

  void draggedArrival(DomComponent c) {
    assert(_dragged.isNone, "from: draggedArrival");
    _dragged = new Ft.Option<DomComponent>.some(c);
    _pce.draggedChange(new SlotEvent<DomComponent>.arrival(c));

  }

  Ft.Option<DomComponent> get dragged => _dragged;

}
