// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_interfaces.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 18:19:17 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/18 17:03:35 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:html' as Html;

abstract class HtmlElement_intf {
  Html.Element get elt;
  Js.JsObject get jsElt;
  Js.JsObject get jqElt;
}

// abstract class Component_intf {
//   ComponentType get type;
// }

// abstract class ComponentBank_intf {
//   Iterable<ComponentType> get typeSet;
// }

// enum ComponentType {
//   Ram, Ss, Cart,
// }


// enum DropZoneState { // DropZoneOpened Boolean
//   Opened, Closed,
// }

// enum DropZoneClosedCause {
//   Disabled, Full,
// }

// enum DropAction { // DropPossible Boolean
//   Possible, Impossible,
// }

// enum DropActionImpossibleCause {
//   Closed, Types, Parentality, Roms,
// }
