// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_dom_component_storage_parts.dart          :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 11:54:28 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 11:54:45 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of platform_dom_component_storage;

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
