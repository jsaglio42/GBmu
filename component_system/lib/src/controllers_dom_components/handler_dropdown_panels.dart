// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_dropdown_panels.dart                       :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/06 17:27:41 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/06 18:56:21 by ngoguey          ###   ########.fr       //
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

class HandlerDropdownPanels {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;

  DomComponent _opened;

  // CONSTRUCTION *********************************************************** **
  HandlerDropdownPanels(this._pde, this._pce, this._pdcs) {
    Ft.log('HandlerDropdownPanels', 'contructor');

    _pde.onDropDownClick.forEach(_onDropDownClick);
    _pce.onCartEvent.forEach(_onComponentEvent);
    _pce.onChipEvent.forEach(_onComponentEvent);
    _pce.onDraggedChange.forEach(_onComponentEvent);
    Html.window.onClick.forEach(_onDomClick);
    Html.window.onKeyDown.forEach(_onComponentEvent);
  }

  // CALLBACKS ************************************************************** **
  void _onDropDownClick(DomComponent c) {
    if (_opened == null) {
      if (c is DomChip)
        _openChipPanel(c as DomChip);
      else
        _openCartPanel(c as DomCart);
    }
    else if (_opened == c)
      _closePanel();
    else {
      _closePanel();
      if (c is DomChip)
        _openChipPanel(c as DomChip);
      else
        _openCartPanel(c as DomCart);
    }
  }

  void _onComponentEvent(_) {
    if (_opened != null)
      _closePanel();
  }

  void _onDomClick(Html.MouseEvent ev) {
    if (!(ev.target as Html.Element).classes.contains('ft-dropdown-button'))
      _onComponentEvent(42);
 }

  // PRIVATE **************************************************************** **
  void _openChipPanel(DomChip ch) {
    final DomCart caOpt = _pdcs.cartOfChipOpt(ch);

    _opened = ch;
    if (caOpt == null)
      ch.showDetachedPanel();
    else if (caOpt == _pdcs.gbCart.v)
      ch.showGameBoyPanel();
    else
      ch.showAttachedPanel();
  }

  void _openCartPanel(DomCart c) {
    _opened = c;
    if (c == _pdcs.gbCart.v)
      c.showGameBoyPanel();
    else if (c == _pdcs.openedCart.v)
      c.showOpenedPanel();
    else
      c.showClosedPanel();
  }

  void _closePanel() {
    (_opened as HtmlDropDown).hdd_hide();
    _opened = null;
  }

}
