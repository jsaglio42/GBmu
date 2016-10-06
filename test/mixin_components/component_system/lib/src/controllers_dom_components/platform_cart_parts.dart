// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_cart_parts.dart                           :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/04 18:26:32 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/06 14:36:17 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

part of platform_cart;

abstract class _Super {
  Ft.Option<DomCart> _openedCart;
  Ft.Option<DomCart> _gbCart;
  PlatformComponentEvents get _pce;
}

abstract class _Actions implements _Super {

  void _actionNew(DomCart that) =>
    _pce.cartEvent(new CartEvent<DomCart>.New(that));

  void _actionOpen(DomCart that) {
    Ft.log('_Actions', '_actionOpen', [that]);
    assert(_openedCart.isNone, 'from: cartOpen');
    _openedCart = new Ft.Option<DomCart>.some(that);
    _pce.cartEvent(new CartEvent<DomCart>.Open(that));
  }

  void _actionClose() {
    Ft.log('_Actions', '_actionClose');
    assert(_openedCart.isSome, "from: cartClose");
    _pce.cartEvent(new CartEvent<DomCart>.Close(_openedCart.v));
    _openedCart = new Ft.Option<DomCart>.none();
  }

  void _actionLoad() {
    Ft.log('_Actions', '_actionLoad');
    assert(_gbCart.isNone, "from: cartLoad");
    assert(_openedCart.isSome, "from: cartLoad");
    _gbCart = _openedCart;
    _pce.cartEvent(new CartEvent<DomCart>.Load(_openedCart.v));
    _openedCart = new Ft.Option<DomCart>.none();
  }

  void _actionUnloadOpened() {
    Ft.log('_Actions', '_actionUnloadOpened');
    assert(_gbCart.isSome, "from: cartUnloadOpened");
    assert(_openedCart.isNone, "from: cartUnloadOpened");
    _openedCart = _gbCart;
    _gbCart = new Ft.Option<DomCart>.none();
    _pce.cartEvent(new CartEvent<DomCart>.UnloadOpened(_openedCart.v));
  }

  void _actionUnloadClosed() {
    Ft.log('_Actions', '_actionUnloadClosed');
    assert(_gbCart.isSome, "from: cartUnloadOpened");
    _pce.cartEvent(new CartEvent<DomCart>.UnloadClosed(_gbCart.v));
    _gbCart = new Ft.Option<DomCart>.none();
  }

  void _actionDeleteGameBoy() {
    Ft.log('_Actions', '_actionDeleteGameBoy');
    assert(_gbCart.isSome, "from: _actionDeleteGameBoy");
    _pce.cartEvent(new CartEvent<DomCart>.DeleteGameBoy(_gbCart.v));
    _gbCart = new Ft.Option<DomCart>.none();
  }

  void _actionDeleteOpened() {
    Ft.log('_Actions', '_actionDeleteOpened');
    assert(_openedCart.isSome, "from: _actionDeleteOpened");
    _pce.cartEvent(new CartEvent<DomCart>.DeleteOpened(_openedCart.v));
    _openedCart = new Ft.Option<DomCart>.none();
  }

  void _actionDeleteClosed(DomCart that) =>
    _pce.cartEvent(new CartEvent<DomCart>.DeleteClosed(that));

}
