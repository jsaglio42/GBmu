// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_element_chip.dart                             :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/26 14:15:54 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/06 13:28:30 by ngoguey          ###   ########.fr       //
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

/*
 *                              SSgb   SSatt  SSdet  RAMgb  RAMatt RAMdet
 * Refresh savestate            X      O      O      O      O      O
 * Install savestate            X      O      O      O      O      O
 * Save to file                 X      X      X      X      X      X
 * Detach from cartridge        X      X      O      X      X      O
 * Delete                       X      X      X      X      X      X
 * Duplicate                    X      X      X      X      X      X
 *
 */

enum _Loc {
  Gb, Att, Det,
}

enum _PanelEntry {
  InstallSs, RefreshSs, SaveToFile, Detach, Duplicate, Delete,
}

class _PanelEntryData {
  final String name;
  final Map<Chip, Map<_Loc, bool>> combos;

  const _PanelEntryData(this.name, this.combos);
}

const Map<_PanelEntry, _PanelEntryData> _panelData = const {
  _PanelEntry.InstallSs: const _PanelEntryData('Install savestate', const {
    Ss.v:  const {_Loc.Gb: true , _Loc.Att: false, _Loc.Det: false},
    Ram.v: const {_Loc.Gb: false, _Loc.Att: false, _Loc.Det: false},
  }),
  _PanelEntry.RefreshSs: const _PanelEntryData('Refresh savestate', const {
    Ss.v:  const {_Loc.Gb: true , _Loc.Att: false, _Loc.Det: false},
    Ram.v: const {_Loc.Gb: false, _Loc.Att: false, _Loc.Det: false},
  }),
  _PanelEntry.SaveToFile: const _PanelEntryData('Save to file', const {
    Ss.v:  const {_Loc.Gb: true , _Loc.Att: true , _Loc.Det: true },
    Ram.v: const {_Loc.Gb: true , _Loc.Att: true , _Loc.Det: true },
  }),
  _PanelEntry.Detach: const _PanelEntryData('Detach from cartridge', const {
    Ss.v:  const {_Loc.Gb: true , _Loc.Att: true , _Loc.Det: false},
    Ram.v: const {_Loc.Gb: true , _Loc.Att: true , _Loc.Det: false},
  }),
  _PanelEntry.Duplicate: const _PanelEntryData('Duplicate', const {
    Ss.v:  const {_Loc.Gb: true , _Loc.Att: true , _Loc.Det: true },
    Ram.v: const {_Loc.Gb: true , _Loc.Att: true , _Loc.Det: true },
  }),
  _PanelEntry.Delete: const _PanelEntryData('Delete', const {
    Ss.v:  const {_Loc.Gb: true , _Loc.Att: true , _Loc.Det: true },
    Ram.v: const {_Loc.Gb: true , _Loc.Att: true , _Loc.Det: true },
  }),
};

abstract class HtmlElementChip implements DomComponent {

  // ATTRIBUTES ************************************************************* **
  Html.Element _elt;
  Html.DivElement _txt;
  Html.ButtonElement _ddBtn;
  Html.Element _panelGameBoy;
  Html.Element _panelAttached;
  Html.Element _panelDetached;

  // CONSTRUCTION *********************************************************** **
  void hech_init() {

    // Ft.log('HtmlElementChip', 'hec_init');
    _txt = new Html.DivElement()
      ..classes.addAll(["text"])
      ..text = this.data.fileName;

    _ddBtn = new Html.ButtonElement()
      ..type = 'button'
      ..classes.add('ft-dropdown-button')
      ..onClick.forEach((_) => this.pde.chipDropDownClick(this));

    _panelGameBoy = _panelOfTypes(this.data.type, _Loc.Gb);
    _panelAttached = _panelOfTypes(this.data.type, _Loc.Att);
    _panelDetached = _panelOfTypes(this.data.type, _Loc.Det);

    _elt = new Html.DivElement()
      ..nodes = [_txt, _ddBtn,
        _panelGameBoy, _panelAttached, _panelDetached];
    if (this.data.type is Ram)
      _elt.classes.addAll(["cart-ram-bis", "ui-widget-content", 'ft-chip']);
    else
      _elt.classes.addAll(["cart-ss-bis", "ui-widget-content", 'ft-chip']);
    _ddBtn.onMouseOver.forEach((_) => _elt.classes.add('over'));
    _ddBtn.onMouseOut.forEach((_) => _elt.classes.remove('over'));
  }

  // PUBLIC ***************************************************************** **
  Html.Element get elt => _elt;
  Js.JsObject get jsElt => new Js.JsObject.fromBrowserObject(_elt);
  Js.JsObject get jqElt => Js.context.callMethod(r'$', [this.jsElt]);

  Html.DivElement get txt => _txt;
  Js.JsObject get jsBtnText => new Js.JsObject.fromBrowserObject(_txt);
  Js.JsObject get jqBtnText => Js.context.callMethod(r'$', [this.jsBtnText]);

  Html.ButtonElement get ddBtn => _ddBtn;
  Js.JsObject get jsDdBtn => new Js.JsObject.fromBrowserObject(_ddBtn);
  Js.JsObject get jqDdBtn => Js.context.callMethod(r'$', [this.jsDdBtn]);

  Html.Element get panelGameBoy => _panelGameBoy;
  Html.Element get panelAttached => _panelAttached;
  Html.Element get panelDetached => _panelDetached;

  // PRIVATE **************************************************************** **
  Html.Element _panelOfTypes(Chip c, _Loc l) {
    final List<Html.Element> liList = [];

    _panelData.forEach((e, eData){
      if (eData.combos[c][l]) {
        liList.add(_lineOfData(eData.name, _requestFunctionOfType(e)));
      }
    });
    return new Html.UListElement()
      ..nodes = liList
      ..style.display = 'none'
      ..classes.add('list-group');
  }

  Html.Element _lineOfData(String name, var f) {
    return new Html.LIElement()
      ..text = name
      // ..href = '#'
      ..onClick.forEach((_) => f(this))
      ..classes.add('list-group-item');
  }

  dynamic _requestFunctionOfType(_PanelEntry e) {
    switch (e) {
      case (_PanelEntry.InstallSs): return this.pde.requestInstallSaveState;
      case (_PanelEntry.RefreshSs): return this.pde.requestExtractSaveState;
      case (_PanelEntry.SaveToFile): return this.pde.requestSaveToFile;
      case (_PanelEntry.Detach): return this.pde.requestDetach;
      case (_PanelEntry.Duplicate): return this.pde.requestDuplicate;
      case (_PanelEntry.Delete): return this.pde.requestDelete;
    }
  }

}
