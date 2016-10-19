// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   platform_emulator_contacts.dart                    :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2016/10/18 15:59:47 by ngoguey           #+#    #+#             //
//   Updated: 2016/10/19 18:49:23 by ngoguey          ###   ########.fr       //
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
import 'package:emulator/enums.dart';
import 'package:emulator/emulator.dart' as Emulator;
import 'package:emulator/constants.dart';

import 'package:component_system/src/include_cs.dart';
import 'package:component_system/src/include_ccs.dart';
import 'package:component_system/src/include_dc.dart';
import 'package:component_system/src/include_cdc.dart';

/* External events involving RAM that affect the emulator
 * EventEmu 			RequestsEvent 			Scope
 * ********************************************************** **
 * GbCartRamDelete              		Start	Local Storage(ok)
 * GbCartRamDetach		Extract   		Start	Local Storage(ok)
 * GbCartRamAttach             			Start	Local Storage(ok)
 * GbCartRamExtraction	Extract					Local storage(ok)

 * GbCartLoad              				Start	Tab(ok)
 * GbCartRestart		Extract   		Start	Tab(ok)
 * GbCartUnload			Extract	Eject			Tab(ok)
 * GbCartDelete			Extract Eject			Local storage

 * TabClose				Extract					Tab
 */

// TODO: on `GbCartDelete` implement GbCart's chips deletion
// TODO: Implement TabClose event

class PlatformEmulatorContacts {

  // ATTRIBUTES ************************************************************* **
  final PlatformDomEvents _pde;
  final PlatformComponentEvents _pce;
  final PlatformDomComponentStorage _pdcs;
  final Emulator.Emulator _emu;

  // CONTRUCTION ************************************************************ **
  PlatformEmulatorContacts(this._pde, this._pce, this._pdcs, this._emu) {
    Ft.log('PlatformEC', 'contructor');
    _pce.onChipEvent.forEach(_onChipEvent);
  }

  // PUBLIC ***************************************************************** **
  void requestEject() {
    _emu.send('EmulationEject', 42);
  }

  void requestStart(DomCart cart) {
    final LsRom dataRom = cart.data;
    LsRam dataRamOpt;

    dataRamOpt = _pdcs.chipOfCartOpt(cart, Ram.v)?.data;
    _emu.send('EmulationStart', new Emulator.RequestEmuStart(
            idb:'GBmu_db',
            romStore: Rom.v.toString(),
            ramStore: Ram.v.toString(),
            romKey: dataRom.idbid,
            ramKeyOpt: dataRamOpt?.idbid));
  }

  void requestRamExtraction(int idbid) {
    _emu.send('ExtractRam', new Emulator.EventIdb(
            'GBmu_db', Ram.v.toString(), idbid));
  }

  void requestSsExtraction(int idbid) {
    _emu.send('ExtractSs', new Emulator.EventIdb(
            'GBmu_db', Ss.v.toString(), idbid));
  }

  void requestSsInstallation(int idbid) {
    _emu.send('InstallSs', new Emulator.EventIdb(
            'GBmu_db', Ss.v.toString(), idbid));
  }

  // CALLBACKS ************************************************************** **
  void _onChipEvent(ChipEvent<DomChip, DomCart> ev) {
    if (ev.chip.data.type is Ram && _pdcs.gbCart.isSome) {
      if (_pdcs.gbCart.v == ev.dstCartOpt) {
        if (ev.isNewAttached)
          ; //Don't act, must be from an `Extract chip`
        else if (ev.isAttach || ev.isMoveAttach)
          this.requestStart(ev.dstCartOpt);
      }
      else if (_pdcs.gbCart.v == ev.srcCartOpt) {
        if (ev.isDeleteAttached)
          this.requestStart(ev.srcCartOpt);
        else if (ev.isDetach || ev.isMoveAttach) {
          this.requestRamExtraction(ev.chip.data.idbid);
          this.requestStart(ev.srcCartOpt);
        }
      }
    }
  }

}