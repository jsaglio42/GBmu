// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_cart_parts.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/04 18:26:32 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/07 14:40:30 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of platform_cart;

abstract class _Super {

  PlatformComponentEvents get _pce;
  PlatformDomComponentStorage get _pdcs;

}

abstract class _Actions implements _Super {

  void _actionNew(DomCart that) =>
    _pce.cartEvent(new CartEvent<DomCart>.New(that));

  void _actionOpen(DomCart that) {
    Ft.log('_Actions', '_actionOpen', [that]);
    assert(_pdcs.openedCart.isNone, 'from: cartOpen');
    _pdcs.openedCart = that;
    _pce.cartEvent(new CartEvent<DomCart>.Open(that));
  }

  void _actionClose() {
    Ft.log('_Actions', '_actionClose');
    assert(_pdcs.openedCart.isSome, "from: cartClose");
    _pce.cartEvent(new CartEvent<DomCart>.Close(_pdcs.openedCart.v));
    _pdcs.unsetOpenedCart();
  }

  void _actionLoad() {
    Ft.log('_Actions', '_actionLoad');
    assert(_pdcs.gbCart.isNone, "from: cartLoad");
    assert(_pdcs.openedCart.isSome, "from: cartLoad");
    _pdcs.gbCart = _pdcs.openedCart.v;
    _pce.cartEvent(new CartEvent<DomCart>.Load(_pdcs.openedCart.v));
    _pdcs.unsetOpenedCart();
  }

  void _actionUnloadOpened() {
    Ft.log('_Actions', '_actionUnloadOpened');
    assert(_pdcs.gbCart.isSome, "from: cartUnloadOpened");
    assert(_pdcs.openedCart.isNone, "from: cartUnloadOpened");
    _pdcs.openedCart = _pdcs.gbCart.v;
    _pdcs.unsetGbCart();
    _pce.cartEvent(new CartEvent<DomCart>.UnloadOpened(_pdcs.openedCart.v));
  }

  void _actionUnloadClosed() {
    Ft.log('_Actions', '_actionUnloadClosed');
    assert(_pdcs.gbCart.isSome, "from: cartUnloadOpened");
    _pce.cartEvent(new CartEvent<DomCart>.UnloadClosed(_pdcs.gbCart.v));
    _pdcs.unsetGbCart;
  }

  void _actionDeleteGameBoy() {
    Ft.log('_Actions', '_actionDeleteGameBoy');
    assert(_pdcs.gbCart.isSome, "from: _actionDeleteGameBoy");
    _pce.cartEvent(new CartEvent<DomCart>.DeleteGameBoy(_pdcs.gbCart.v));
    _pdcs.unsetGbCart;
  }

  void _actionDeleteOpened() {
    Ft.log('_Actions', '_actionDeleteOpened');
    assert(_pdcs.openedCart.isSome, "from: _actionDeleteOpened");
    _pce.cartEvent(new CartEvent<DomCart>.DeleteOpened(_pdcs.openedCart.v));
    _pdcs.unsetOpenedCart;
  }

  void _actionDeleteClosed(DomCart that) =>
    _pce.cartEvent(new CartEvent<DomCart>.DeleteClosed(that));

}
