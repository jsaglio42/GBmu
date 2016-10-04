// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   variants.dart                                      :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/24 12:12:05 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/04 15:10:17 by ngoguey          ###   ########.fr       //
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
abstract class CartState {}

class None implements CartState {
  const None._();
  static const None v = const None._();
  String toString() => 'None';
}

class Closed implements CartState {
  const Closed._();
  static const Closed v = const Closed._();
  String toString() => 'Closed';
}

class Opened implements CartState {
  const Opened._();
  static const Opened v = const Opened._();
  String toString() => 'Opened';
}

class GameBoy implements CartState {
  const GameBoy._();
  static const GameBoy v = const GameBoy._();
  String toString() => 'GameBoy';
}

// Cart movements *********************************************************** **
enum _CartEvent {
  New, Open, Close, Load,
  UnloadOpened, UnloadClosed,
  DeleteDetached, DeleteGameBoy,
}

const _cartEventTargets = const <_CartEvent, List<CartState>>{
  _CartEvent.New: const <CartState>[None.v, Closed.v],
  _CartEvent.Open: const <CartState>[Closed.v, Opened.v],
  _CartEvent.Close: const <CartState>[Opened.v, Closed.v],
  _CartEvent.Load: const <CartState>[Opened.v, GameBoy.v],
  _CartEvent.UnloadOpened: const <CartState>[GameBoy.v, Opened.v],
  _CartEvent.UnloadClosed: const <CartState>[GameBoy.v, Closed.v],
  _CartEvent.DeleteGameBoy: const <CartState>[GameBoy.v, None.v],
  _CartEvent.DeleteDetached: const <CartState>[Opened.v, None.v],
};

class CartEvent {
  final DomCart cart;
  final _CartEvent _ev;

  CartEvent.New(this.cart) : _ev = _CartEvent.New;
  CartEvent.Open(this.cart) : _ev = _CartEvent.Open;
  CartEvent.Close(this.cart) : _ev = _CartEvent.Close;
  CartEvent.Load(this.cart) : _ev = _CartEvent.Load;
  CartEvent.UnloadOpened(this.cart) : _ev = _CartEvent.UnloadOpened;
  CartEvent.UnloadClosed(this.cart) : _ev = _CartEvent.UnloadClosed;
  CartEvent.DeleteGameBoy(this.cart) : _ev = _CartEvent.DeleteGameBoy;
  CartEvent.DeleteDetached(this.cart) : _ev = _CartEvent.DeleteDetached;

  bool get isNew => _ev == _CartEvent.New;
  bool get isOpen => _ev == _CartEvent.Open;
  bool get isClose => _ev == _CartEvent.Close;
  bool get isLoad => _ev == _CartEvent.Load;
  bool get isUnloadOpened => _ev == _CartEvent.UnloadOpened;
  bool get isUnloadClosed => _ev == _CartEvent.UnloadClosed;
  bool get isDeleteGameBoy => _ev == _CartEvent.DeleteGameBoy;
  bool get isDeleteDetached => _ev == _CartEvent.DeleteDetached;

  bool get isUnload => UnloadOpened || UnloadClosed;
  bool get isMove => isLoad || isUnload;
  bool get isDelete => isDeleteGameBoy || isDeleteDetached;

  CartState get src => _cartEventTargets[_ev][0];
  CartState get dst => _cartEventTargets[_ev][1];

  bool get isOpenedChange => src is Opened || dst is Opened;
  bool get isGbChange => src is GameBoy || dst is GameBoy;

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
