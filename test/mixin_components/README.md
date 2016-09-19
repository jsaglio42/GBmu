<!-- *********************************************************************** -->
<!--                                                                         -->
<!--                                                      :::      ::::::::  -->
<!-- README.md                                          :+:      :+:    :+:  -->
<!--                                                  +:+ +:+         +:+    -->
<!-- By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+       -->
<!--                                              +#+#+#+#+#+   +#+          -->
<!-- Created: 2016/09/19 11:54:15 by ngoguey           #+#    #+#            -->
<!-- Updated: 2016/09/19 19:17:06 by ngoguey          ###   ########.fr      -->
<!--                                                                         -->
<!-- *********************************************************************** -->

### Dynamic quantity elements with html repr:
- DomCart(HtmlElementCart, HtmlCartClosable, HtmlDraggable, ChipSocketContainer, DataHolder)
- DomChip(HtmlElementChip, HtmlDraggable, DataHolder)
- DomChipSocket(HtmlElementChipSocket, HtmlDropZone, ChipBank)

### Fixed quantity elements with html repr:
- DomGameBoySocket(HtmlElementGameBoySocket, HtmlDropZone, CartBank)
- DomDetachedCartBank(HtmlElementDetachedCartBank, HtmlDropZone, CartBank)
- DomDetachedChipBank(HtmlElementDetachedChipBank, HtmlDropZone, ChipBank)

### Level ordering:
- lower - Html < Controllers < IndexedDatabase - high

### Events:
- htmlEvents:
  - Unprocessed event triggered by html, broadcasted by HtmlElement
- event:
  - Intermediate level events
- dbEvent
  - From Database Controller
- domDataEvent

```dart
// Polymorphic variants pleeeeeease
abstract class SlotEventEnum {
  const SlotEventEnum();
}

class Arrival extends SlotEventEnum {
  const Arrival();
  static const Arrival v = const Arrival();
}

class Dismissal extends SlotEventEnum {
  const Dismissal();
  static const Dismissal v = const Dismissal();
}

class CartSlotEvent<Event extends SlotEventEnum> {
  final Event event;
  final DomCart cart;
  CartSlotEvent._dismissal(this.cart) : event = Dismissal.v {
    assert(Event != dynamic && event is Event, "CartSlotEvent.constructor");
  }
  CartSlotEvent._arrival(this.cart) : event = Arrival.v {
    assert(Event != dynamic && event is Event, "CartSlotEvent.constructor");
  }
}

CartSlotEvent<Arrival> makeCartSlotArrival(DomCart cart) =>
  new CartSlotEvent<Arrival>._arrival(cart);

CartSlotEvent<Dismissal> makeCartSlotDismissal(DomCart cart) =>
  new CartSlotEvent<Dismissal>._dismissal(cart);

```

```dart
// Polymorphic variants pleeeeeease

// Slot Event
abstract class SlotEvent {
  const SlotEvent();
}

class Arrival extends SlotEvent {
  const Arrival();
  Arrival get event => const Arrival();
}

class Dismissal extends SlotEvent {
  const Dismissal();
  Dismissal get event => const Dismissal();
}

// Slot Event for Cart
abstract class CartSlotEvent {}

class CartArrivalEvent extends Arrival implements CartSlotEvent {
  final int cart;
  CartArrivalEvent(this.cart);
}

class CartDismissalEvent extends Dismissal implements CartSlotEvent {
  final int cart;
  CartDismissalEvent(this.cart);
}

// Slot Event for Draggable
abstract class DraggableSlotEvent {}

class DraggableArrivalEvent extends Arrival implements DraggableSlotEvent {
  final int draggable;
  DraggableArrivalEvent(this.draggable);
}

class DraggableDismissalEvent extends Dismissal implements DraggableSlotEvent {
  final int draggable;
  DraggableDismissalEvent(this.draggable);
}
```

### ControllerData:
- Wraps some combersome tasks
- Ensures correct mutation of variable
 - e.g.: Two successive openedCartDismissal() is an error
- Ensures access of variables with a monadic storage
 - With type Ft.Option
- Ensures propagation of high-level events on variable change
- Ensures variables consistency on component deletion.
 - e.g.: Deletion of `openedCart` after a drop
 - e.g.: Deletion of `gbCart` after a dbVersionUpdate
- openedCart
 - openedCartDismissal();
 - openedCartArrival(DomCart c);
 - Ft.Option<Cart> get openedCart;
 - Async.StreamController<CartSlotEvent> _openedCartController;
 - Async.Stream<CartSlotEvent> onOpenedCartChange;
- gbCart
 - gbCartDismissal();
 - gbCartArrival(DomCart c);
 - Ft.Option<Cart> get gbCart;
 - Async.StreamController<CartSlotEvent> _gbCartController;
 - Async.Stream<CartSlotEvent> onGbCartChange;
- dragged
 - draggedDismissal();
 - draggedArrival(HtmlDraggable c);
 - Ft.Option<HtmlDraggable> get dragged;
 - Async.StreamController<DraggableSlotEvent> _draggedController;
 - Async.Stream<DraggableSlotEvent> onDraggedChange;
- ????cart
 - ????Iterable<Cart> get carts;
 - ????delete dart
- ????chips
 - ????Iterable<Chip> get chips;
 - ????delete chip
- ????3 top-level banks
<!-- - chip-sockets -->
<!--  - chipSocketsOfCart(Cart c) -->

### Controllers (partial ordering): Controllers' CONTENT DEPRECATED
##### ControllerCartOpen
- __**this**->**DomCart(HtmlCartClosable)(lower-level)** communication:__ HtmlCartClosable method(s)
- __**lower-levels**->**this** communication:__ Listens stream(s)
  - htmlEvent.cartButtonClicked<DomCart>
  - htmlEvent.cartDoneOpening<DomCart>
- __**higher-levels**->**this** communication:__ Listens stream(s)
  - event.cartNew<DomCart>
  - event.cartInGb<DomCart>
- __to higher-levels:__ Notify variable-controller:
  - cartOpenedOpt<DomCart>

##### ControllerCartsLocation
- __**lower-levels**->**this** communication:__ Listens stream(s)
  - htmlEvent.dragStart filtered<DomCart>
  - htmlEvent.onDrop filtered<DomCartBank>
  - event.cartOpenedOpt<DomCart>
- __**this**->**higher-levels** communication:__ Broadcasts stream(s)
  - event.cartInGbOpt<DomCart>

##### ControllerCartsDragCapability
- __**this**->**DomCart(Draggable)(lower-level)** communication:__ Draggable method(s)
- __**lower-levels**->**this** communication:__ Listens stream(s)
  - event.cartOpenedOpt<DomCart>
  - event.cartInGbOpt<DomCart>
- __**this**->**higher-levels** communication:__ NONE

##### ControllerCartBanksStyle
- __**this**->**DropZone(CartBank)(lower-level)** communication:__ DropZone method(s)
- __**lower-levels**->**this** communication:__ Listens x stream(s)
  - event.cartOpenedOpt<DomCart>
  - event.cartInGbOpt<DomCart>
  - htmlEvent.dragStart filtered<DomCart>
  - htmlEvent.dragStop filtered<DomCart>
  - htmlEvent.dropZoneEntered filtered<DomCartBank>
  - htmlEvent.dropZoneLeft filtered<DomCartBank>
- __**this**->**higher-levels** communication:__ NONE

##### ControllerChipSocketsDropCapability
- __**this**->**DropZone(DomChipSocket)(lower-level)** communication:__ DropZone method(s)
- __**lower-levels**->**this** communication:__ Listens x stream(s)
  - event.cartOpenedOpt<DomCart>
  - event.cartInGbOpt<DomCart>
- __**this**->**higher-levels** communication:__ NONE

##### ControllerChipsDragCapability
##### ControllerChipsLocations
##### ControllerChipBanksStyle




##### ControllerDatabase (is ControllerVariableData it's only out interlocutor?)
- __**dom**->**this** communication:__ Exposes 9 method(s)
  - startup()
  - new{Rom, Ram, Ss}(SerializableComponent c)
  - delete{Rom, Ram, Ss}(EntryProxy p)
  - location{Ram, Ss}(EntryProxy p)
- __**other-tabs**->**this** communication:__ Listens 1 idb stream(s)
  - onVersionChange
- __**this**->**other-tabs** communication:__ idb method(s)
  - db.close(), dbf.open(version: ++)
- __**this**->**Dom communication:__ Broadcasts 8 stream(s)
  - dbEvent.new{Rom, Ram, Ss}Detached<EntryProxy>
  - dbEvent.location{Ram, Ss}<EntryProxy>
  - dbEvent.delete{Rom, Ram, Ss}<EntryProxy>
