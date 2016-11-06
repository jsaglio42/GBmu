// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   html_element_chip.dart                             :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/26 14:15:54 by ngoguey           #+#    #+#             //
//   Updated: 2016/11/06 18:48:32 by ngoguey          ###   ########.fr       //
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

// CHIP CONFIGURATION ******************************************************* **
/*
 *                              SSgb   SSatt  SSdet  RAMgb  RAMatt RAMdet
 * Refresh savestate            X      O      O      O      O      O
 * Install savestate            X      O      O      O      O      O
 * Save to file                 X      X      X      X      X      X
 * Detach from cartridge        X      X      O      X      X      O
 * Delete                       X      X      X      X      X      X
 * Duplicate                    X      X      X      X      X      X
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

abstract class HtmlElementChip implements DomComponent, HtmlDropDown {

  // ATTRIBUTES ************************************************************* **
  Html.Element _elt;
  Html.DivElement _txt;

  // CONSTRUCTION *********************************************************** **
  void hech_init() {
    // Ft.log('HtmlElementChip', 'hec_init');
    _txt = new Html.DivElement()
      ..classes.addAll(["text"])
      ..text = this.data.fileName;

    _elt = new Html.DivElement()
      ..nodes = [_txt, this.ddBtn, this.ddPanel]
      ..classes.addAll(["ui-widget-content", 'ft-chip']);
    this.ddBtn.onMouseOver.forEach((_) => _elt.classes.add('over'));
    this.ddBtn.onMouseOut.forEach((_) => _elt.classes.remove('over'));
    if (this.data.type is Ram)
      _elt.classes.add("cart-ram-bis");
    else
      _elt.classes.add("cart-ss-bis");

    hdd_addLine(this.data.fileName, true);
    _addDataLines();
    _makeLinesOfTypes(this.data.type, _Loc.Gb);
    _makeLinesOfTypes(this.data.type, _Loc.Att);
    _makeLinesOfTypes(this.data.type, _Loc.Det);
  }

  // PUBLIC ***************************************************************** **
  Html.Element get elt => _elt;
  Js.JsObject get jsElt => new Js.JsObject.fromBrowserObject(_elt);
  Js.JsObject get jqElt => Js.context.callMethod(r'$', [this.jsElt]);

  Html.DivElement get txt => _txt;
  Js.JsObject get jsBtnText => new Js.JsObject.fromBrowserObject(_txt);
  Js.JsObject get jqBtnText => Js.context.callMethod(r'$', [this.jsBtnText]);

  void showGameBoyPanel() {
    hdd_show(_Loc.Gb);
  }

  void showAttachedPanel() {
    hdd_show(_Loc.Att);
  }

  void showDetachedPanel() {
    hdd_show(_Loc.Det);
  }

  // PRIVATE **************************************************************** **
  void _addDataLines() {
    this.data.data.forEach((String k, dynamic v) {
      switch (k) {
        case ('fileName'):
        case ('romUid'):
        case ('slot'):
        case ('idbid'):
          break;
        default:
          hdd_addLine('$k: $v', false);
      }
    });
  }

  void _makeLinesOfTypes(Chip c, _Loc l) {
    _panelData.forEach((_PanelEntry e, _PanelEntryData eData){
      if (eData.combos[c][l])
        hdd_addStateLine(l, eData.name, _requestFunctionOfType(e));
    });
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
