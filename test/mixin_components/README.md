<!-- *********************************************************************** -->
<!--                                                                         -->
<!--                                                      :::      ::::::::  -->
<!-- README.md                                          :+:      :+:    :+:  -->
<!--                                                  +:+ +:+         +:+    -->
<!-- By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+       -->
<!--                                              +#+#+#+#+#+   +#+          -->
<!-- Created: 2016/09/19 11:54:15 by ngoguey           #+#    #+#            -->
<!-- Updated: 2016/09/29 13:18:21 by ngoguey          ###   ########.fr      -->
<!--                                                                         -->
<!-- *********************************************************************** -->

# Glossary
- Component: Data entity, `class LsEntry`
- Dom Element: Entity visible in the Dom, `class DomElement`
- Dom Component: DomElement holding a single Data, `class DomComponent`
- A `class Handler* {...}` is a singleton class that does not expose public methods, other than construction ones.
- A `class Platform* {...}` is a singleton class that exposes many attributes and methods, but does not hold complex code.
- A `class Transformer* {...}` is a singleton class that exposes streams, filtered and/or mapped from an other controller.

# List of classes

### Components
##### Glossary
- ramdomInt: ramdomly generated int
- entryType: one of {Rom | Ram | Ss}
- lsKey: String of the form '$ramdomInt$entryType'
- lsValue: Lightweight stringified object of type LsEntry

### Dom Element mixin list
- HtmlElementCart
- HtmlElementChip
- HtmlElementChipSocket
- HtmlElementGameBoySocket
- HtmlElementDetachedCartBank
- HtmlElementDetachedChipBank
- HtmlCartClosable
- HtmlDraggable
- HtmlDropZone
- ChipSocketContainer
- ChipBank
- CartBank

### Dom Components `Class(->Super->SuperSuper, mixin1, mixin2)`
##### Dynamic quantity
- DomCart(->DomComponent->DomElement, HtmlElementCart, HtmlCartClosable, HtmlDraggable, ChipSocketContainer)
- DomChip(->DomComponent->DomElement, HtmlElementChip, HtmlDraggable)
- DomChipSocket(->DomElement, HtmlElementChipSocket, HtmlDropZone, ChipBank)

##### Singletons
- DomGameBoySocket(->DomElement, HtmlElementGameBoySocket, HtmlDropZone, CartBank)
- DomDetachedCartBank(->DomElement, HtmlElementDetachedCartBank, HtmlDropZone, CartBank)
- DomDetachedChipBank(->DomElement, HtmlElementDetachedChipBank, HtmlDropZone, ChipBank)

### Controllers for Dom Components
- PlatformDomComponentStorage
- PlatformDomEvents

### Controllers for Components
- PlatformIndexedDb
- PlatformLocalStorage
- PlatformComponentStorage
- TransformerLseUnserializer
- TransformerLseDataCheck
- TransformerLseIdbCheck

# Detail of Dom controllers (Mostly deprecated or not yet implemented)

##### ControllerData:
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
