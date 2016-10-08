<!-- *********************************************************************** -->
<!--                                                                         -->
<!--                                                      :::      ::::::::  -->
<!-- README.md                                          :+:      :+:    :+:  -->
<!--                                                  +:+ +:+         +:+    -->
<!-- By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+       -->
<!--                                              +#+#+#+#+#+   +#+          -->
<!-- Created: 2016/09/19 11:54:15 by ngoguey           #+#    #+#            -->
<!-- Updated: 2016/10/08 14:18:23 by ngoguey          ###   ########.fr      -->
<!--                                                                         -->
<!-- *********************************************************************** -->

# Glossary
- Component: Data entity, `class LsEntry`
- Dom Element: Entity visible in the Dom, `class DomElement`
- Dom Component: DomElement holding a single Data, `class DomComponent`
- A singleton `class Handler* {...}`
  - Construction: other controllers
  - Entry-points: streams
  - Exposes: none
  - Scripting: high
- A singleton `class Platform* {...}`
  - Construction: other controllers
  - Entry-points: streams + methods
  - Exposes: many
  - Scripting: high
- A singleton `class Transformer* {...}`
  - Construction: other controllers
  - Entry-points: streams
  - Exposes: streams
  - Scripting: high
- A singleton `class Store* {...}`
  - Construction: no controllers, independant class
  - Entry-points: methods
  - Exposes: many
  - Scripting: low

# List of classes

### Components
##### Glossary
- ramdomInt: ramdomly generated int
- entryType: one of {Rom | Ram | Ss}
- lsKey: String of the form '$ramdomInt$entryType'
- lsValue: Lightweight stringified object of type LsEntry

### Dom Components
```dart
class DomCart extends DomComponent // 1 per rom
  with HtmlElementCart
  , HtmlCartClosable
  , HtmlDraggable
  , ChipSocketContainer;
class DomChip extends DomComponent // 1 per ram or saveState
  with HtmlElementSimple
  , HtmlDraggable;
class DomChipSocket extends DomElement // 4 per DomCart
  with HtmlElementSimple
  , HtmlDropZone
  , ChipBank;

class DomGameBoySocket extends DomElement // Singleton
  with HtmlElementSimple
  , HtmlDropZone
  , CartBank;
class DomDetachedCartBank extends DomElement // Singleton
  with HtmlElementSimple
  , HtmlDropZone
  , CartBank;
class DomDetachedChipBank extends DomElement // Singleton
  with HtmlElementSimple
  , HtmlDropZone
  , ChipBank;

```

### Controllers
- see closure in init file
