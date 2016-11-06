// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   handler_chip_dropdown_panels.dart                  :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/26 17:11:13 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/06 13:30:07 by ngoguey          ###   ########.fr       //
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

  DomChip _openedPanelChipOpt;
  void _onChipDropDownClick(DomChip c) {
    if (_openedPanelChipOpt == null) {
      _openChipPanel(c);
      _openedPanelChipOpt = c;
    }
    else if (_openedPanelChipOpt == c) {
      _closeChipPanel(c);
      _openedPanelChipOpt = null;
    }
    else {
      _closeChipPanel(_openedPanelChipOpt);
      _openChipPanel(c);
      _openedPanelChipOpt = c;
    }
  }

  void _onComponentEvent(_) {
    if (_openedPanelChipOpt != null) {
      _closeChipPanel(_openedPanelChipOpt);
      _openedPanelChipOpt = null;
    }
  }

  void _onDomClick(Html.MouseEvent ev) {
    if (!(ev.target as Html.Element).classes.contains('ft-dropdown-button'))
      _onComponentEvent(42);
 }

  // PRIVATE **************************************************************** **

  Html.Element _openedPanelOpt;
  void _openChipPanel(DomChip ch) {
    final DomCart caOpt = _pdcs.cartOfChipOpt(ch);

    if (caOpt == null) {
      _openedPanelOpt = ch.panelDetached;
    }
    else {
      if (caOpt == _pdcs.gbCart.v)
        _openedPanelOpt = ch.panelGameBoy;
      else
        _openedPanelOpt = ch.panelAttached;
    }
    _openedPanelOpt.style.display = '';
  }

  void _closeChipPanel(DomChip) {
    _openedPanelOpt.style.display = 'none';
    _openedPanelOpt = null;
  }

}
