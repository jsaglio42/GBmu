// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_element_cart.dart                             :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/09/29 13:35:13 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/06 19:10:36 by ngoguey          ###   ########.fr       //
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

import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

// CART CONFIGURATION ******************************************************* **
/*
 *                              gb     open   close
 * Eject                        X      0      0
 * Insert                       0      X      0
 * Delete                       X      X      X
 */

enum _Loc {
  Gb, Open, Close,
}

enum _PanelEntry {
  Eject, Insert, Delete,
    // Add Restart and `Extract Ram`
}

class _PanelEntryData {
  final String name;
  final Map<_Loc, bool> combos;

  const _PanelEntryData(this.name, this.combos);
}

const Map<_PanelEntry, _PanelEntryData> _panelData = const {
  _PanelEntry.Eject: const _PanelEntryData('Eject', const {
    _Loc.Gb: true , _Loc.Open: false, _Loc.Close: false,
  }),
  _PanelEntry.Insert: const _PanelEntryData('Insert', const {
    _Loc.Gb: false , _Loc.Open: true, _Loc.Close: false,
  }),
  _PanelEntry.Delete: const _PanelEntryData('Delete', const {
    _Loc.Gb: true , _Loc.Open: true, _Loc.Close: true,
  }),
};

abstract class HtmlElementCart implements DomComponent, HtmlDropDown {

  // ATTRIBUTES ************************************************************* **
  Html.Element _elt;
  Html.ButtonElement _btn;
  Html.Element _body;
  Html.DivElement _btnText;

  // CONSTRUCTION *********************************************************** **
  void hec_init(String cartHtml, Html.NodeValidator v) {
    // Ft.log('HtmlElementCart', 'hec_init');
    _elt = new Html.Element.html(cartHtml, validator: v);
    this.ddBtn.onMouseOver.forEach((_) => _elt.classes.add('over'));
    this.ddBtn.onMouseOut.forEach((_) => _elt.classes.remove('over'));

    _btn = _elt.querySelector('.bg-head-btn');
    _body = _elt.querySelector('.panel-collapse');
    _btnText = _elt.querySelector('.bg-head-btn .text');
    _btnText.text = this.data.fileName;
    _elt.nodes.addAll([this.ddBtn, this.ddPanel]);

    hdd_addLine(this.data.fileName, true);
    _addDataLines();
    _makeLinesOfTypes(_Loc.Gb);
    _makeLinesOfTypes(_Loc.Open);
    _makeLinesOfTypes(_Loc.Close);
  }

  // PUBLIC ***************************************************************** **
  Html.Element get elt => _elt;
  Js.JsObject get jsElt => new Js.JsObject.fromBrowserObject(_elt);
  Js.JsObject get jqElt => Js.context.callMethod(r'$', [this.jsElt]);

  Html.ButtonElement get btn => _btn;
  Js.JsObject get jsBtn => new Js.JsObject.fromBrowserObject(_btn);
  Js.JsObject get jqBtn => Js.context.callMethod(r'$', [this.jsBtn]);

  Html.ButtonElement get body => _body;
  Js.JsObject get jsBody => new Js.JsObject.fromBrowserObject(_body);
  Js.JsObject get jqBody => Js.context.callMethod(r'$', [this.jsBody]);

  Html.DivElement get btnText => _btnText;
  Js.JsObject get jsBtnText => new Js.JsObject.fromBrowserObject(_btnText);
  Js.JsObject get jqBtnText => Js.context.callMethod(r'$', [this.jsBtnText]);

  void showGameBoyPanel() {
    hdd_show(_Loc.Gb);
  }

  void showOpenedPanel() {
    hdd_show(_Loc.Open);
  }

  void showClosedPanel() {
    hdd_show(_Loc.Close);
  }

  // PRIVATE **************************************************************** **
  void _addDataLines() {
    this.data.data.forEach((String k, dynamic v) {
      switch (k) {
        case ('fileName'):
        case ('idbid'):
          break;
        default:
          hdd_addLine('$k: $v', false);
      }
    });
  }

  void _makeLinesOfTypes(_Loc l) {
    _panelData.forEach((_PanelEntry e, _PanelEntryData eData){
      if (eData.combos[l])
        hdd_addStateLine(l, eData.name, _requestFunctionOfType(e));
    });
  }

  dynamic _requestFunctionOfType(_PanelEntry e) {
    switch (e) {
      case (_PanelEntry.Delete): return this.pde.requestDelete;
      case (_PanelEntry.Insert): return this.pde.requestInsert;
      case (_PanelEntry.Eject): return this.pde.requestEject;
    }
  }

}
