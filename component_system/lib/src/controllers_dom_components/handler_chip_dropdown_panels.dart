// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_chip_dropdown_panels.dart                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/26 17:11:13 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/06 14:09:29 by ngoguey          ###   ########.fr       //
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
// import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

class HandlerChipDropdownPanels {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  DomChip _openedChip;

  // CONSTRUCTION *********************************************************** **
  HandlerChipDropdownPanels(this._pde, this._pce, this._pdcs) {
    Ft.log('HandlerChipDropdownPanels', 'contructor');

    _pde.onChipDropDownClick.forEach(_onChipDropDownClick);
    _pce.onCartEvent.forEach(_onComponentEvent);
    _pce.onChipEvent.forEach(_onComponentEvent);
    _pce.onDraggedChange.forEach(_onComponentEvent);
    Html.window.onClick.forEach(_onDomClick);
  }

  // CALLBACKS ************************************************************** **

  void _onChipDropDownClick(DomChip c) {
    if (_openedChip == null)
      _openChipPanel(c);
    else if (_openedChip == c)
      _closeChipPanel();
    else {
      _closeChipPanel();
      _openChipPanel(c);
    }
  }

  void _onComponentEvent(_) {
    if (_openedChip != null)
      _closeChipPanel();
  }

  void _onDomClick(Html.MouseEvent ev) {
    if (!(ev.target as Html.Element).classes.contains('ft-dropdown-button'))
      _onComponentEvent(42);
 }

  // PRIVATE **************************************************************** **

  void _openChipPanel(DomChip ch) {
    final DomCart caOpt = _pdcs.cartOfChipOpt(ch);

    _openedChip = ch;
    if (caOpt == null)
      ch.showDetachedPanel();
    else if (caOpt == _pdcs.gbCart.v)
      ch.showGameBoyPanel();
    else
      ch.showAttachedPanel();
  }

  void _closeChipPanel() {
    _openedChip.hidePanel();
    _openedChip = null;
  }

}
