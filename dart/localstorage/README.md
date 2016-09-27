<!-- *********************************************************************** -->
<!--                                                                         -->
<!--                                                      :::      ::::::::  -->
<!-- README.md                                          :+:      :+:    :+:  -->
<!--                                                  +:+ +:+         +:+    -->
<!-- By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+       -->
<!--                                              +#+#+#+#+#+   +#+          -->
<!-- Created: 2016/09/24 10:13:08 by ngoguey           #+#    #+#            -->
<!-- Updated: 2016/09/27 13:06:03 by ngoguey          ###   ########.fr      -->
<!--                                                                         -->
<!-- *********************************************************************** -->

### LsKey
```dart
class LsKey {
  final int uid;
  final TODO type;

  LsKey(this.uid, this.type);

  String toString();
}
```

### LsValue
```dart
abstract class LsValue {

  LsValue();
  factory LsValue.unserialize_null(String keyRepr, String valueRepr);

  String key();
  String value();

}
```

### Glossary:
- ramdomInt: ramdomly generated int
- entryType: one of {Rom | Ram | Ss}
- lsKey: String of the form '$ramdomInt$entryType'
- lsValue: Lightweight stringified object of type LsEntry

#### Controllers:
- A `class Handler* {...}` is a singleton class that does not expose public methods, other than construction ones.
- A `class Platform* {...}` is a singleton class that exposes many attributes and methods, but does not hold complex code.
- A `class Transformer* {...}` is a singleton class that exposes streams, filtered and/or mapped from an other controller.

### DbController external input interactions:
- New rom request
- New ram request
- New ss request
- Move ram request
- Move ss request
- Remove rom request
- Remove ram request
- Remove ss request

### DbController external output interactions:
- New rom notification
- New ram notification
- New ss notification
- Move ram notification
- Move ss notification
- Remove rom notification
- Remove ram notification
- Remove ss notification

### Localstorage input interactions:
- New entry: localStorage[lsKey] = lsValue;
- Update entry: localStorage[lsKey] = lsValue;

### Localstorage output interactions:
- Direct read: localStorage[lsKey]
- Event stream: EventStreamProvider<StorageEvent>
- Entries iteration: localStorage.forEach()
- Delete events
 - Filtered out
- Any other event
 - Filtered out, Reverted, thus creating a new Delete event.

### Data Races among tabs:
##### Different entries:
- 2 New at the same time:
 - `uid` prevents key collision
 - `Event stream` updates both tabs
- Any other operations
 - `Event stream` updates both tabs

##### Same entry, local version is `Dead`
- No races

##### Same entry, local version is `Alive`
- 2 Move at the same time
  - First event is normaly processed
  - Second event is normaly processed
- 1 Move and 1 Delete at the same time
  - First event is normaly processed
  - Second event is normaly processed
- 2 Delete at the same time
  - First event is normaly processed, updating the local version to `Dead`
  - The second event has no effect
- 1 Delete and 1 Move at the same time
  - First event is normaly processed
  - The second event has no effect, and is reverted
