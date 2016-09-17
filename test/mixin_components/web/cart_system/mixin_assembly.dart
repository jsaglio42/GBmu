// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_assembly.dart                                :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/17 16:38:35 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/17 17:11:49 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:math' as Math;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:typed_data';

import 'package:ft/ft.dart' as Ft;

import './cart_html.dart';
import './cart_collapsing.dart';
// import './cart.dart';
// import './cart.dart';
// import './cart.dart';
// import './cart.dart';
// import './cart.dart';
// import './cart.dart';

// Caution: Mixins are partially ordered. Concerns imports/implements/init
class Cart extends Object
  with CartHtml
  , ClosableCart {

  Cart(String cartHtml, Html.NodeValidator v)
  {
    Ft.log('cart', 'constructor');
    this.ch_init(cartHtml, v);
    this.cc_init();

  }


}
