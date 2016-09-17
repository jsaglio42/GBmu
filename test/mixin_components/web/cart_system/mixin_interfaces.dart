// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_interfaces.dart                              :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 18:19:17 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/17 18:32:39 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:html' as Html;

abstract class HtmlElement_intf {
  Html.Element get elt;
  Js.JsObject get jsElt;
  Js.JsObject get jqElt;
}