// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_dropdown.dart                                 :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/11/06 16:30:34 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/06 17:18:07 by ngoguey          ###   ########.fr       //
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

abstract class HtmlDropDown implements DomComponent {

  // ATTRIBUTES ************************************************************* **
  final Html.ButtonElement _ddBtn = new Html.ButtonElement()
    ..type = 'button'
    ..classes.add('ft-dropdown-button');

  final Html.UListElement _ddPanel = new Html.UListElement()
    ..style.display = 'none'
    ..classes.add('ft-dropdown')
    ..classes.add('list-group');

  final Map<dynamic, List<Html.LIElement>> _stateLines =
    <dynamic, List<Html.LIElement>>{};

  var _activeStateOpt = null;

  // CONSTRUCTION *********************************************************** **
  void hdd_init() {
    _ddBtn.onClick.forEach((_) => this.pde.chipDropDownClick(this));
    _ddBtn.onMouseOver.forEach((_) => this.elt.classes.add('over'));
    _ddBtn.onMouseOut.forEach((_) => this.elt.classes.remove('over'));
  }

  void hdd_addLine(String name, bool title) {
    _ddPanel.nodes.add(_makeLine(name, title));
  }

  void hdd_addStateLine(state, String name, onClickOpt) {
    Html.LIElement l;

    if (_stateLines[state] == null)
      _stateLines[state] = <Html.LIElement>[];
    if (onClickOpt != null)
      l = _makeClickableLine(name, onClickOpt);
    else
      l = _makeLine(name, false);
    _stateLines[state].add(l);
    _ddPanel.nodes.add(l);
  }

  // PUBLIC ***************************************************************** **
  Html.ButtonElement get ddBtn => _ddBtn;
  Html.UListElement get ddPanel => _ddPanel;

  void hdd_show(state) {
    if (_activeStateOpt != null)
      _stateLines[_activeStateOpt].forEach((Html.Element l){
        l.style.display = 'none';
      });
    else
      _ddPanel.style.display = '';
    _activeStateOpt = state;
      _stateLines[_activeStateOpt].forEach((Html.Element l){
        l.style.display = '';
      });
  }

  void hdd_hide() {
    assert(_activeStateOpt != null);
    _stateLines[_activeStateOpt].forEach((Html.Element l){
      l.style.display = 'none';
    });
    _activeStateOpt = null;
    _ddPanel.style.display = 'none';
  }

  // PRIVATE **************************************************************** **
  Html.LIElement _makeLine(String name, bool title) {
    final Html.LIElement l = new Html.LIElement()
      ..classes.add('list-group-item')
      ..text = name;

    if (title)
      l.classes.add('ft-title');
    return l;
  }

  Html.LIElement _makeClickableLine(String name, onClick) {
    final Html.LIElement l = new Html.LIElement()
      ..classes.add('list-group-item')
      ..style.display = 'none'
      ..text = name;

    l.classes.add('ft-clickable');
    l.onClick.forEach((_) => onClick(this));
    return l;
  }

}
