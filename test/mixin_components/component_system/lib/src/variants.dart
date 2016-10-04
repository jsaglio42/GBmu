// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   variants.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 12:12:05 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/04 14:34:50 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

abstract class Chip implements Component{}

abstract class Component {
  static const Iterable<Component> values =
    const <Component>[Rom.v, Ram.v, Ss.v];
}

class Rom implements Component {
  const Rom._();
  static const Rom v = const Rom._();
  String toString() => 'Rom';
}

class Ram implements Chip {
  const Ram._();
  static const Ram v = const Ram._();
  String toString() => 'Ram';
}

class Ss implements Chip {
  const Ss._();
  static const Ss v = const Ss._();
  String toString() => 'Ss';
}

// Locations **************************************************************** **
abstract class CartLocation {
  static const Iterable<CartLocation> values =
    const <CartLocation>[None.v, Detached.v, GameBoy.v];
}

abstract class ChipLocation {
  static const Iterable<ChipLocation> values =
    const <ChipLocation>[None.v, Detached.v, Cart.v];
}

class None implements CartLocation, ChipLocation {
  const None._();
  static const None v = const None._();
  String toString() => 'None';
}

class Detached implements CartLocation, ChipLocation {
  const Detached._();
  static const Detached v = const Detached._();
  String toString() => 'Detached';
}

class GameBoy implements CartLocation {
  const GameBoy._();
  static const GameBoy v = const GameBoy._();
  String toString() => 'GameBoy';
}

class Cart implements ChipLocation {
  const Cart._();
  static const Cart v = const Cart._();
  String toString() => 'Cart';
}

// Cart movements *********************************************************** **
enum _CartMoveEvent {
  New, Load, Unload, GameBoyDelete, DetachedDelete,
}

const _cartMoveTargets = const <_CartMoveEvent, List<CartLocation>>{
  _CartMoveEvent.New: const <CartLocation>[None.v, Detached.v],
  _CartMoveEvent.Load: const <CartLocation>[Detached.v, GameBoy.v],
  _CartMoveEvent.Unload: const <CartLocation>[GameBoy.v, Detached.v],
  _CartMoveEvent.GameBoyDelete: const <CartLocation>[GameBoy.v, None.v],
  _CartMoveEvent.DetachedDelete: const <CartLocation>[Detached.v, None.v],
};

class CartMoveEvent {
  final DomCart cart;
  final _CartMoveEvent _ev;

  CartMoveEvent.New(this.cart) : _ev = _CartMoveEvent.New;
  CartMoveEvent.Load(this.cart) : _ev = _CartMoveEvent.Load;
  CartMoveEvent.Unload(this.cart) : _ev = _CartMoveEvent.Unload;
  CartMoveEvent.GameBoyDelete(this.cart) : _ev = _CartMoveEvent.GameBoyDelete;
  CartMoveEvent.DetachedDelete(this.cart) : _ev = _CartMoveEvent.DetachedDelete;

  bool get isNew => _ev == _CartMoveEvent.New;
  bool get isLoad => _ev == _CartMoveEvent.Load;
  bool get isUnload => _ev == _CartMoveEvent.Unload;
  bool get isGameBoyDelete => _ev == _CartMoveEvent.GameBoyDelete;
  bool get isDetachedDelete => _ev == _CartMoveEvent.DetachedDelete;
  bool get isMove => isLoad || isUnload;
  bool get isDelete => isGameBoyDelete || isDetachedDelete;

  CartLocation get src => _cartMoveTargets[_ev][0];
  CartLocation get dst => _cartMoveTargets[_ev][1];

}

// Life ********************************************************************* **
class Alive implements Life {
  const Alive._();
  static const Alive v = const Alive._();
  String toString() => 'Alive';
}

class Dead implements Life {
  const Dead._();
  static const Dead v = const Dead._();
  String toString() => 'Dead';
}

abstract class Life {
  factory Life.ofString(String s) {
    switch (s) {
      case ('Alive'): return Alive.v;
      case ('Dead'): return Dead.v;
      default: throw new Exception('Life.ofString($s)');
    }
  }
}

// SlotAction event ********************************************************* **
enum _SlotEvent {
  Arrival, Dismissal,
}

class SlotEvent<T> {
  final T value;
  final _SlotEvent _ev;

  SlotEvent.Arrival(this.value) : _ev = _SlotEvent.Arrival;
  SlotEvent.Dismissal(this.value) : _ev = _SlotEvent.Dismissal;

  bool get isArrival => _ev == _SlotEvent.Arrival;
  bool get isDismissal => _ev == _SlotEvent.Dismissal;

}

// Update event ************************************************************* **
class Update<T> {
  final T newValue;
  final T oldValue;
  Update({T oldValue, T newValue})
    : oldValue = oldValue
    , newValue = newValue;
}
