<!-- *********************************************************************** -->
<!--                                                                         -->
<!--                                                      :::      ::::::::  -->
<!-- README.md                                          :+:      :+:    :+:  -->
<!--                                                  +:+ +:+         +:+    -->
<!-- By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+       -->
<!--                                              +#+#+#+#+#+   +#+          -->
<!-- Created: 2016/09/19 11:54:15 by ngoguey           #+#    #+#            -->
<!-- Updated: 2016/09/20 20:10:37 by ngoguey          ###   ########.fr      -->
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
 - Iterable<DomCart> get carts;
 <!-- - Iterable<DomChipSocket> chipSocketsOfCart(DomCart); -->
 <!-- - Iterable<DomChip> chipsOfCart(DomCart); -->
 - Stream<DomCart> newClosedCart ;
 - ????delete dart
- ????chips
 - ????Iterable<Chip> get chips;
 - Stream<DomChip> newDetachedChip ;
 - ????delete chip
<!-- - ????3 top-level banks -->
<!-- - chip-sockets -->
<!--  - chipSocketsOfCart(Cart c) -->


### Controllers:
##### ControllerHtmlEvents
- __from html-elements / exposed to higher-levels:__
  - streams:
     - htmlEvent.onCartButtonClicked<DomCart>
     - htmlEvent.onCartDoneOpening<DomCart>
     - htmlEvent.onDrop<DropZone>
     - htmlEvent.dropZoneEntered<DropZone>
     - htmlEvent.dropZoneLeft<DropZone>

### Carts Controllers:
##### ControllerCartOpened
- __from ControllerHtmlEvent:__
  - listens:
     - htmlEvent.onCartButtonClicked<DomCart>
     - htmlEvent.onCartDoneOpening<DomCart>
- __from ControllerData:__
  - subscriptions:
     - data.onGbCartChange<DomCart>
     - data.onNewClosedCart<DomCart>
  - getters:
     - data.gbCart
     - data.openedCart
- __to DomCart instances:__
  - setters:
     - HtmlCartClosable method(s)
- __to ControllerData:__
  - setters:
     - data.openedCart{Arrival, Dismissal}()

##### ControllerCartsLocation
- __from ControllerHtmlEvent:__
  - subscriptions:
	 - htmlEvent.onDrop filtered<CartBank>
- __from ControllerData:__
  - subscriptions:
     - data.onDraggedChange filtered<DomCart>
  - getters:
     - data.dragged
     - data.gbCart
     - data.openedCart
- __to ControllerData:__
  - setters:
     - data.gbCart{Arrival, Dismissal}()

##### ControllerCartsDragCapability
- __from ControllerData:__
  - subscriptions:
     - data.onOpenedCartChange<DomCart>
     - data.onGbCartChange<DomCart>
- __to DomCart instances:__
  - setters:
	 - HtmlDraggable method(s)

##### ControllerCartBanksStyle
- __from ControllerHtmlEvent:__
  - subscriptions:
     - htmlEvent.dropZoneEntered filtered<CartBank>
     - htmlEvent.dropZoneLeft filtered<CartBank>
- __from ControllerData:__
  - subscriptions:
     - data.onDraggedChange filtered<DomCart>
  - getters:
     - data.dragged
     - data.gbCart
     - data.openedCart
- __to CartBank instances:__
  - setters:
     - HtmlDropZone method(s)

### Chips Controllers:
##### ControllerChipSocketsDropCapability
- __from ControllerData:__
  - subscriptions:
     - data.onOpenedCartChange<DomCart>
- __from DomCart instances:__
  - getters:
     - ChipSocketContainer.iterChipSockets()
- __to DomChipSocket instances:__
  - setters:
     - HtmlDropZone method(s)

##### ControllerChipsDragCapability
- __from ControllerData:__
  - subscriptions:
     - data.onOpenedCartChange<DomCart>
     - data.onNewDetachedChip<DomChip>
- __from DomCart instances:__
  - getters:
     - ChipSocketContainer.iterChipSockets()
- __from DomChipSocket instances:__
  - getters:
     - ChipBank.chipOpt()
- __to DomChip instances:__
  - setters:
     - DomChip method(s)

##### ControllerChipsLocations
- __from ControllerHtmlEvent:__
  - subscriptions:
	 - htmlEvent.onDrop filtered<DomChipBank>
- __from ControllerData:__
  - subscriptions:
     - data.onDraggedChange filtered<DomChip>
  - getters:
     - data.dragged
- __to ControllerData:__
  - subscriptions:
     - data.chipLocation(Chip, ChipBank)

##### ControllerChipBanksStyle
- __from ControllerHtmlEvent:__
  - subscriptions:
     - htmlEvent.dropZoneEntered filtered<ChipBank>
     - htmlEvent.dropZoneLeft filtered<ChipBank>
- __from ControllerData:__
  - subscriptions:
     - data.onDraggedChange filtered<DomChip>
  - getters:
     - data.dragged
     - data.openedCart
- __from DomCart instances:__
  - getters:
     - ChipSocketContainer.iterChipSockets()
- __to ChipBank instances:__
  - setters:
     - HtmlDropZone method(s)

### Db Controllers:
##### ControllerDatabase
- __from other-tabs:__
  - idb.onVersionChange
- __to other-tabs:__
  - idb.close(), idbf.open(version: ++)
- __to higher-levels:__
  - streams:
     - dbEvent.new{Rom, Ram, Ss}Detached<EntryProxy>
     - dbEvent.location{Ram, Ss}<EntryProxy>
     - dbEvent.delete{Rom, Ram, Ss}<EntryProxy>
- __from higher-levels:__
  - methods:
     - startup()
     - new{Rom, Ram, Ss}(SerializableComponent c)
     - delete{Rom, Ram, Ss}(EntryProxy p)
     - location{Ram, Ss}(EntryProxy p)
