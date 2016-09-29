// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   mixin_banks.dart                                   :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 13:58:47 by ngoguey           #+#    #+#             //
//   Updated: 2016/09/29 18:35:56 by ngoguey          ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

import 'dart:js' as Js;
import 'dart:async' as Async;
import 'dart:html' as Html;
import 'dart:indexed_db' as Idb;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ft/ft.dart' as Ft;

import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

abstract class Bank {

  // PUBLIC ***************************************************************** **
  // bool get full;
  // bool get empty;

}

abstract class CartBank implements Bank {
}

abstract class ChipBank implements Bank {
}

// abstract class TopLevelBank implements Bank {

// }

abstract class ListBank<T> implements Bank {

  // ATTRIBUTES ************************************************************* **
  final List<T> _components = <DomComponent>[];

  // CONSTRUCTION *********************************************************** **
  void lb_init(Async.Stream<T> onArrive, Async.Stream<T> onLeave) {
    Ft.log('ListBank<$T>', 'lb_init');
    // this.pde..forEach(_handleDrop);
  }

  // PUBLIC ***************************************************************** **
  bool get full => false;
  bool get empty => _components.isEmpty;

}

abstract class SingleElementBank<T> implements Bank {

  // ATTRIBUTES ************************************************************* **
  Ft.Option<T> _component = new Ft.Option<T>.none();

  // CONSTRUCTION *********************************************************** **
  void seb_init() {
    Ft.log('SingleElementBank<$T>', 'seb_init');
    // this.pde..forEach(_handleDrop);
  }

  // PUBLIC ***************************************************************** **
  bool get full => _component.isSome;
  bool get empty => _components.isNone;

}
